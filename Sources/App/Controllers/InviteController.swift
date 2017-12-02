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
		guard let userId = request.headers["userId"]?.int,
			let inviteeId = request.json?["userId"]?.int,
			let meetupId = request.json?["meetupId"]?.int else {
				throw Abort.badRequest
		}
		
		guard
			let user = try User.find(userId),
			let invitee = try User.find(inviteeId) else {
			throw Abort.notFound
		}
		
		guard let meetup = try Meetup.find(meetupId) else { throw Abort.notFound }
		
		guard meetup.userId.int == userId else {
			throw Abort(.forbidden, reason: "Only the host can invite users!")
		}
		
		// create invitation
		let invite = Invitation(userId: Identifier(inviteeId), meetupId: Identifier(meetupId))
		try invite.save()
		
		// send email
		guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
		let emailController = try EmailController(config: config)
		try emailController.sendInvitationEmail(from: user, to: invitee, meetup: meetup.title)
		
		return JSON([:])
	}
	
	// get all inv
	public func getAllInvites(_ request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else { throw Abort.badRequest }
		let invite = try Invitation.makeQuery().filter("userId", userId).all()
		return try invite.makeJSON()
	}
	
	// get inv by id
  public func getInvite(_ request: Request, invite: Invitation) throws -> ResponseRepresentable {
		return try invite.makeJSON()
	}
	
	// update
  public func updateInvite(_ request: Request, invite: Invitation) throws -> ResponseRepresentable {
		
    invite.accepted = request.json?["accepted"]?.bool ?? invite.accepted
		try invite.save()
    
		if invite.accepted {
			guard let user = try invite.user.get() else { throw Abort.notFound }
			guard let meetup = try invite.meetup.get() else { throw Abort.notFound }
			guard let invitee = try meetup.user.get() else { throw Abort.notFound }
			// attemp to send email
			guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
			let emailController = try EmailController(config: config)
			try emailController.sendInvitationEmail(from: user, to: invitee, meetup: meetup.title)
		}
		return Response(status: .ok)
	}
	
	// delete
  public func deleteInvite(_ request: Request, invite: Invitation) throws -> ResponseRepresentable {
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

extension Request {
	fileprivate func invite() throws -> Invitation {
		guard let id = parameters["inviteId"]?.int, let userId = headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		guard let invitation = try Invitation.makeQuery().filter("id", id)
			.and({ try $0.filter("userId", userId) }).first() else {
				throw Abort.notFound
		}
		
		return invitation
	}
}
