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
		// friend routes
		builder.grouped(TokenMiddleware()).get("user", ":userId", "friends", handler: getAllFriends)
		builder.grouped(TokenMiddleware()).post("user", ":userId", "friends", handler: addFriend)
		builder.grouped(TokenMiddleware()).get("user", ":userId", "friends", ":friendId", handler: getFriend)
		builder.grouped(TokenMiddleware()).delete("user", ":userId", "friends", ":friendId", handler: removeFriend)
		builder.grouped(TokenMiddleware()).patch("user", ":userId", "friends", ":friendId", handler: updateFriend)
	}
	
	public func updateFriend(request: Request) throws -> ResponseRepresentable {
		let friend = try request.friend()
		
		friend.accepted = request.json?["accepted"]?.bool ?? friend.accepted
		
		try friend.save()
		
		return JSON([:])
	}
	
	public func removeFriend(request: Request) throws -> ResponseRepresentable {
		let friend = try request.friend()
		try friend.delete()
		
		return JSON([:])
	}
	
	public func addFriend(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		guard let friendId = request.json?["friendId"]?.int else {
			throw Abort.notFound
		}
		
		let friend = Friend(userId: Identifier(userId), friendsId: Identifier(friendId))
		try friend.save()
		
		return JSON([:])
	}
	
	public func getFriend(request: Request) throws -> ResponseRepresentable {
		let friend = try request.friend()
		return try friend.makeJSON()
	}
	
	public func getAllFriends(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.parameters["userId"]?.int else {
			throw Abort.badRequest
		}
		
		let friends = try Friend.makeQuery().filter("userId", userId).all()
		
		return try friends.makeJSON()
	}
	
	// get all the users
	public func getAllUsers(request: Request) throws -> ResponseRepresentable {
		
		// if a search query shows up, we can filter based on the contains
		if let search = request.query?["search"]?.string {
			let users = try User.makeQuery().filter("displayName", .contains, search).all()
			return try users.makeJSON()
		}
		
		let users = try User.all()
		return try users.makeJSON()
	}
	
	// get user by the id
	public func getUser(request: Request) throws -> ResponseRepresentable {
		let user = try request.user()
		return try user.makeJSON()
	}
	
	// update user
	public func updateUser(request: Request) throws -> ResponseRepresentable {
		let user = try request.user()
		
		guard let headerUserId = request.headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		guard headerUserId == user.id?.int else {
			throw Abort(.forbidden, reason: "You can only edit your own user!")
		}
		
		user.firstName = request.json?["firstName"]?.string ?? user.firstName
		user.lastName = request.json?["lastName"]?.string ?? user.lastName
		user.displayName = request.json?["displayName"]?.string ?? user.displayName
		user.email = request.json?["email"]?.string ?? user.email
		
		return JSON([:])
	}
}

extension Request {
	fileprivate func friend() throws -> Friend {
		guard let userId = parameters["userId"]?.int,
			let friendId = parameters["friendId"]?.int else {
				throw Abort.badRequest
		}
		
		guard let friend = try Friend.makeQuery().filter("userId", userId).and({ try $0.filter("friendId", friendId) }).first() else {
			throw Abort.notFound
		}
		
		return friend
	}
	
	fileprivate func user() throws -> User {
		guard let userId = parameters["userId"]?.int else {
			throw Abort.badRequest
		}
	
		guard let user = try User.find(userId) else {
			throw Abort.notFound
		}
		
		return user
	}
}
