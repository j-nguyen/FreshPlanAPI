//
//  UserController.swift
//  FreshPlanAPIPackageDescription
//
//  Created by David Lin on 2017-10-08.
//

//import Foundation
import Vapor
import HTTP

public final class UserController: EmptyInitializable, ResourceRepresentable {
  public init() { }
	
	// get all the users
	public func getAllUsers(_ request: Request) throws -> ResponseRepresentable {
		
		// if a search query shows up, we can filter based on the contains
		if let search = request.query?["search"]?.string {
			let users = try User.makeQuery().filter("displayName", .contains, search).all()
			return try users.makeJSON()
		}
		
		let users = try User.all()
		return try users.makeJSON()
	}
	
	// get user by the id
  public func getUser(_ request: Request, user: User) throws -> ResponseRepresentable {
		return try user.makeJSON()
	}
	
	// update user
  public func updateUser(_ request: Request, user: User) throws -> ResponseRepresentable {
		guard let headerUserId = request.headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		guard headerUserId == user.id?.int else {
			throw Abort(.forbidden, reason: "You can only edit your own user!")
		}
		
		user.displayName = request.json?["displayName"]?.string ?? user.displayName
		user.email = request.json?["email"]?.string ?? user.email
		
    return Response(status: .ok)
	}
  
  public func makeResource() -> Resource<User> {
    return Resource(
      index: getAllUsers,
      show: getUser,
      update: updateUser
    )
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
