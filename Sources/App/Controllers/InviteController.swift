//
//  InvitationController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-10.
//

import Vapor
import HTTP

public final class InviteController: ResourceRepresentable, EmptyInitializable {
  public init() { }
  
  //create user invitation
  public func createInvite(_ request: Request) throws -> ResponseRepresentable {
    guard let inviterId = request.headers["userId"]?.int,
      let inviteeId = request.json?["userId"]?.int,
      let meetupId = request.json?["meetupId"]?.int else {
        throw Abort.badRequest
    }
    
    guard
      let inviter = try User.find(inviterId),
      let invitee = try User.find(inviteeId) else {
        throw Abort.notFound
    }
    
    guard let meetup = try Meetup.find(meetupId) else { throw Abort.notFound }
    
    let invitations = try meetup.invitations.makeQuery()
      .filter("inviteeId", inviterId)
      .and({ try $0.filter("accepted", true) })
      .first()
    
    guard meetup.userId.int == inviterId || invitations != nil else {
      throw Abort(.forbidden, reason: "Only people who are invited to the meetup can invite other users!")
    }
    
    guard inviterId != inviteeId else {
      throw Abort(.conflict, reason: "You can't invite yourself")
    }
    
    // create invitation
    let invite = Invitation(inviterId: Identifier(inviterId), inviteeId: Identifier(inviteeId), meetupId: Identifier(meetupId))
    try invite.save()
    
    // send email
    guard let config = droplet?.config["sendgrid"] else { throw Abort.serverError }
    let emailController = try EmailController(config: config)
    try emailController.sendInvitationEmail(from: inviter, to: invitee, meetup: meetup.title)
    
    // send out notification
    guard let onesignal = droplet?.config["onesignal"] else { throw Abort.serverError }
    let notificationService = try OneSignalService(config: onesignal)
    try notificationService.sendNotification(user: invitee, content: "\(inviter.displayName) has invited you to join \(meetup.title)! Click to join!", type: .invitation, typeId: invite.id!.int!)
    
    return Response(status: .ok)
  }
  
  // get all inv
  public func getAllInvites(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else { throw Abort.badRequest }
    let invites = try Invitation.makeQuery().filter("inviteeId", userId).all()
    
    // insert meetup in here
    
    return try invites.map { invite -> JSON in
      let meetup = try Meetup.find(invite.meetupId)
      var json = try invite.makeJSON()
      try json.set("meetupName", meetup?.title)
      try json.set("meetupStartDate", meetup?.startDate)
      try json.set("meetupEndDate", meetup?.endDate)
      return json
    }.makeJSON()
  }
  
  // get inv by id
  public func getInvite(_ request: Request, invite: Invitation) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else { throw Abort.badRequest }
    guard let invite = try invite.makeQuery().filter("inviteeId", userId).first() else {
      throw Abort.notFound
    }
    
    let meetup = try Meetup.find(invite.meetupId)
    var inviteJSON = try invite.makeJSON()
    try inviteJSON.set("meetupName", meetup?.title)
    try inviteJSON.set("meetupStartDate", meetup?.startDate)
    try inviteJSON.set("meetupEndDate", meetup?.endDate)
    
    return inviteJSON
  }
  
  // update
  public func updateInvite(_ request: Request, invite: Invitation) throws -> ResponseRepresentable {
    
    guard let userId = request.headers["userId"]?.int, userId == invite.inviteeId.int else {
      throw Abort(.conflict, reason: "You can't change another users invitation")
    }
    
    invite.accepted = request.json?["accepted"]?.bool ?? invite.accepted
    try invite.save()
    
    if invite.accepted {
      guard let invitee = try invite.invitee.get() else { throw Abort.notFound }
      guard let meetup = try invite.meetup.get() else { throw Abort.notFound }
      guard let inviter = try invite.inviter.get() else { throw Abort.notFound }
      // attemp to send email
      guard let config = droplet?.config["sendgrid"] else { throw Abort.serverError }
      let emailController = try EmailController(config: config)
      try emailController.sendInvitationEmail(from: inviter, to: invitee, meetup: meetup.title)
      // attempt to send notification
      guard let onesignal = droplet?.config["onesignal"] else { throw Abort.serverError }
      let notificationService = try OneSignalService(config: onesignal)
      try notificationService.sendNotification(user: inviter, content: "\(invitee.displayName) has joined \(meetup.title)!", type: .invitation, typeId: invite.id!.int!)
    }
    return Response(status: .ok)
  }
  
  // delete
  public func deleteInvite(_ request: Request, invite: Invitation) throws -> ResponseRepresentable {
    
    guard let userId = request.headers["userId"]?.int, userId == invite.inviteeId.int else {
      throw Abort(.conflict, reason: "You can't change another users invitation")
    }
    
    try invite.delete()
    return Response(status: .ok)
  }
  
  public func makeResource() -> Resource<Invitation> {
    return Resource(
      index: getAllInvites,
      store: createInvite,
      show: getInvite,
      update: updateInvite,
      destroy: deleteInvite
    )
  }
}
