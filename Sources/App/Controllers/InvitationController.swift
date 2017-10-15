//
//  InvitationController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-10.
//

import Vapor
import HTTP

public final class InvitationController {
	public func addRoutes(_ builder: RouteBuilder) {
		// invitation routes
		builder.grouped(TokenMiddleware()).post("invitation", ":invitationId", handler: createInvitation)
		builder.grouped(TokenMiddleware()).get("invitation", ":invitationId", handler: getAllInvitation)
		builder.grouped(TokenMiddleware()).get("invitation", ":invitationId", handler: getInvitation)
		builder.grouped(TokenMiddleware()).patch("invitation", ":invitationId", handler: updateInvitation)
		builder.grouped(TokenMiddleware()).delete("invitation", ":invitationId", handler: deleteInvitation)
	}

	//create user invitation
	public func createInvitation(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int,
			let meetupId = request.json?["meetup"]?.string else {
				throw Abort.badRequest
		}
		
		// create invitation
		let invitation = Invitation(userId: Identifier(userId), meetupId: Identifier(meetupId))
		try invitation.save()
		
		return JSON([:])
	}
	
	// get all inv
	public func getAllInvitation(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else { throw Abort.badRequest }
		let invitation = try Invitation.makeQuery().filter("userId", userId).all()
		return try invitation.makeJSON()
	}
	
	// get inv by id
	public func getInvitation(request: Request) throws -> ResponseRepresentable {
		let invitation = try request.invitation()
		return try invitation.makeJSON()
	}
	
	// update
	public func updateInvitation(request: Request) throws -> ResponseRepresentable {
		let invitation = try request.invitation()
		invitation.accepted = request.json?["accepted"]?.bool ?? invitation.accepted
		try invitation.save()
		return JSON([:])
	}
	
	// delete
	public func deleteInvitation(request: Request) throws -> ResponseRepresentable {
		let invitation = try request.invitation()
		try invitation.delete()
		return JSON([:])
	}
}

extension Request {
	fileprivate func invitation() throws -> Invitation {
		guard let id = parameters["invitationId"]?.int, let userId = headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		guard let invitation = try Invitation.makeQuery().filter("id", id)
			.and({ try $0.filter("userId", userId) }).first() else {
				throw Abort.notFound
		}
		
		return invitation
	}
}