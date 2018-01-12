//
//  MeetupController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import HTTP

public final class MeetupController: ResourceRepresentable, EmptyInitializable {
  public init() { }
  
  // create the meetup.
  public func createMeetup(request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard let meetupType = request.json?["meetup"]?.string,
      let meetType = Meetup.MeetType(rawValue: meetupType) else {
        throw Abort(.badRequest, reason: "Invalid meetup type!")
    }
    
    guard
      let title = request.json?["title"]?.string,
      let description = request.json?["description"]?.string,
      let metadata = request.json?["metadata"]?.string else {
        
        throw Abort(.unprocessableEntity, reason: "Missing Fields!")
    }
    
    guard let startDate = request.json?["startDate"]?.date,
      let endDate = request.json?["endDate"]?.date else {
        throw Abort(.unprocessableEntity, reason: "Missing Dates!")
    }
    
    guard endDate >= startDate else {
      throw Abort(.forbidden, reason: "The dates must be diferent!")
    }
    
    // create the model
    let meetup = Meetup(
      meetupTypeId: try meetType.id(),
      userId: Identifier(userId),
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      metadata: metadata
    )
    
    try meetup.save()
    
    // create a scheduled notification for later
    // create a notification for later use
    if meetup.startDate >= Date() {
      guard let config = droplet?.config["onesignal"] else { throw Abort.serverError }
      guard let _ = try meetup.user.get() else { throw Abort.notFound }
      let notificationService = try OneSignalService(config: config)
      // send another one too prior 3 hours
      let invitedUsers = try meetup.invitations.all().map { try $0.invitee.get() }.flatMap { $0 }
      try notificationService.sendBatchedScheduledNotification(
        users: invitedUsers,
        date: meetup.startDate,
        content: "Your meetup is starting!",
        type: .meetup,
        typeId: meetup.id!.int!
      )
      try notificationService.sendBatchedScheduledNotification(
        users: invitedUsers,
        date: meetup.startDate.addingTimeInterval(-3600),
        content: "Your meetup is starting in an hour!",
        type: .meetup,
        typeId: meetup.id!.int!
      )
    }
    
    return Response(status: .ok)
  }
  
  // Gets all the meetups, based on you, the user
  public func getAllMeetups(request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    // once we get userId, we'll find all the ties between meetup
    var meetups = try Meetup.makeQuery().filter("userId", userId).all()
    
    // gets all the meetups from invited
    let invitedMeetups = try Invitation.makeQuery().filter("inviteeId", userId)
      .and({ try $0.filter("accepted", true) }).all().map { invited in
      return try invited.meetup.get()
    }.flatMap { $0 }
    
    meetups.append(contentsOf: invitedMeetups)
    
    return try meetups.makeJSON()
  }
  
  // get meetup based on the id
  public func getMeetup(_ request: Request, meetup: Meetup) throws -> ResponseRepresentable {
    return try meetup.makeJSON()
  }
  
  public func updateMeetup(_ request: Request, meetup: Meetup) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard userId == meetup.userId.int else {
      throw Abort(.conflict, reason: "You can't edit someone's meetup!")
    }
    
    if let meetupType = request.json?["meetupType"]?.string {
      guard let meetType = Meetup.MeetType(rawValue: meetupType) else {
        throw Abort.badRequest
      }
      
      meetup.meetupTypeId = try meetType.id()
    }
    
    meetup.title = request.json?["title"]?.string ?? meetup.title
    meetup.description = request.json?["description"]?.string ?? meetup.description
    
    if let startDate = request.json?["startDate"]?.date {
      guard startDate < meetup.endDate else {
        throw Abort(.conflict, reason: "Your start date can't be higher than your end date")
      }
      meetup.startDate = startDate
    }
    
    meetup.endDate = request.json?["endDate"]?.date ?? meetup.endDate
    meetup.startDate = request.json?["startDate"]?.date ?? meetup.startDate
    meetup.endDate = request.json?["endDate"]?.date ?? meetup.endDate
    meetup.metadata = request.json?["metadata"]?.string ?? meetup.metadata
    
    try meetup.save()
    
    // send a notification
    guard let config = droplet?.config["onesignal"] else { throw Abort.serverError }
    let notificationService = try OneSignalService(config: config)
    
    // get all the invites
    let invites = try meetup.invitations
      .all()
      .map { try $0.invitee.get() }
      .flatMap { $0 }
    
    try notificationService.sendBatchNotifications(users: invites, content: "The meetup: \(meetup.title), has been updated!", type: .meetup, typeId: meetup.id!.int!)
    
    return Response(status: .ok)
  }
  
  public func deleteMeetup(_ request: Request, meetup: Meetup) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard userId == meetup.userId.int else {
      throw Abort(.conflict, reason: "You can't delete someone's meetup!")
    }
    
    // if there are any invitations, I will need to delete them
    let invitations = try meetup.invitations.all()
    
    let invitedUsers = try invitations.map { try $0.invitee.get() }.flatMap { $0 }
    
    try invitations.forEach { invite in
      try invite.delete()
    }
    
    try meetup.delete()
    
    // send a notification
    guard let config = droplet?.config["onesignal"] else { throw Abort.serverError }
    let notificationService = try OneSignalService(config: config)
    
    try notificationService.cancelNotification(type: .meetup, typeId: meetup.id!.int!)
    try notificationService.sendBatchNotifications(users: invitedUsers, content: "The meetup: \(meetup.title), has been deleted!", type: .meetup, typeId: meetup.id!.int!)
    
    return Response(status: .ok)
  }
  
  public func makeResource() -> Resource<Meetup> {
    return Resource(
      index: getAllMeetups,
      store: createMeetup,
      show: getMeetup,
      update: updateMeetup,
      destroy: deleteMeetup
    )
  }
}
