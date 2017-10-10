//
//  UserController.swift
//  FreshPlanAPIPackageDescription
//
//  Created by David Lin on 2017-10-08.
//

//import Foundation
import Vapor
import HTTP

public final class UserController {
	public func addRoutes(_ builder: RouteBuilder) {
		// user routes
		builder.grouped(TokenMiddleware()).get("user", handler: getAllUsers)
		builder.grouped(TokenMiddleware()).get("user", ":userId", handler: getUser)
		builder.grouped(TokenMiddleware()).patch("user", ":userId", handler: updateUser)
		// invitation routes
		builder.grouped(TokenMiddleware()).post("invitation", ":invitationId", handler: createInvitation)
		builder.grouped(TokenMiddleware()).get("invitation", ":invitationId", handler: getAllInvitation)
		builder.grouped(TokenMiddleware()).get("invitation", ":invitationId", handler: getInvitation)
		builder.grouped(TokenMiddleware()).patch("invitation", ":invitationId", handler: updateInvitation)
		builder.grouped(TokenMiddleware()).delete("invitation", ":invitationId", handler: deleteInvitation)
		// friend routes
		builder.grouped(TokenMiddleware()).get("user", ":userId", "friends", handler: getFriends)
	}
	
	public func getFriends(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.parameters["userId"]?.int else {
			throw Abort.badRequest
		}
		
		
	}
	
	// get all the users
	public func getAllUsers(request: Request) throws -> ResponseRepresentable {
		let users = try User.all()
		return try users.makeJSON()
	}
	
	// get user by the id
	public func getUser(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.parameters["userId"]?.int else {
			throw Abort.badRequest
		}
		guard let user = try User.makeQuery().filter("userId", userId).first() else {
			throw Abort.notFound
		}
		
		return try user.makeJSON()
	}
	
	// update user
	public func updateUser(request: Request) throws -> ResponseRepresentable {
		guard
			let headerUserId = request.headers["userId"]?.int,
			let userId = request.parameters["userId"]?.int else {
				throw Abort.badRequest
		}
		
		guard headerUserId == userId else {
			throw Abort(.forbidden, reason: "You can only edit your own user!")
		}
		
		guard let user = try User.makeQuery().filter("userId", userId).first() else {
			throw Abort.notFound
		}
		
		user.firstName = request.json?["firstName"]?.string ?? user.firstName
		user.lastName = request.json?["lastName"]?.string ?? user.lastName
		user.displayName = request.json?["displayName"]?.string ?? user.displayName
		user.email = request.json?["email"]?.string ?? user.email
		
		return JSON([:])
	}
	
	//create user invitation
	public func createInvitation(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int,
			let meetupId = request.json?["meetup"]?.string else {
				throw Abort.badRequest
		}
		
		//model
		let invitation = Invitation (userId: Identifier(userId), meetupId: Identifier(meetupId))
		try invitation.save()
		
		return JSON([:])
	}
	
	// get all inv
	public func getAllInvitation(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
			
		}
		let invitation = try Invitation.makeQuery().filter("userId", userId).all()
		return try invitation.makeJSON()
	}
	
	// get inv by id
	public func getInvitation(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
			
		}
		guard let invitationId = request.parameters["invitationId"]?.int else {
			throw Abort.badRequest
		}
		guard let invitation = try Invitation.makeQuery().filter("id", invitationId).and({try $0.filter("userId", userId)}).first() else {
			throw Abort.notFound
		}
		
		return try invitation.makeJSON()
	}
	
	// update
	public func updateInvitation(request: Request) throws -> ResponseRepresentable {
		guard let invitationId = request.parameters["invitationId"]?.int else {
			throw Abort.badRequest
		}
		guard let invitation = try Invitation.makeQuery().filter("invitationId", invitationId).first() else {
			throw Abort.notFound
		}
		
		invitation.accepted = request.json?["accepted"]?.bool ?? invitation.accepted
		return JSON([:])
	}
	
	// delete
	public func deleteInvitation(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
			
		}
		guard let invitationId = request.parameters["invitationId"]?.int else {
			throw Abort.badRequest
		}
		guard let invitation = try Invitation.makeQuery().filter("id", invitationId).and({try $0.filter("userId", userId)}).first() else {
			throw Abort.notFound
		}
		try invitation.delete()
		return JSON([:])
	}
	
}
