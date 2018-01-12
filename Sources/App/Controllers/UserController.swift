//
//  UserController.swift
//  FreshPlanAPIPackageDescription
//
//  Created by David Lin on 2017-10-08.
//

import Vapor
import HTTP

public final class UserController: EmptyInitializable, ResourceRepresentable {
  public init() { }
	
	// get all the users
	public func getAllUsers(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else { throw Abort.badRequest }
		
		// if a search query shows up, we can filter based on the contains
		if let search = request.query?["search"]?.string {
      let users = try User.makeQuery()
        .filter("displayName", .custom("~*"), search)
        .filter("id", .notEquals, userId)
        .all()
      
			return try users.makeJSON()
		}
		
		let users = try User.all()
		return try users.makeJSON()
	}
	
	// get user by the id
  public func getUser(_ request: Request, user: User) throws -> ResponseRepresentable {
    var userJSON = try user.makeJSON()
    
    // if the user requesting is the user itself, we can let the user have its deviceoken
    if let userId = request.headers["userId"]?.int, userId == user.id?.int {
      try userJSON.set("deviceToken", user.deviceToken)
    }
    
		return userJSON
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
    user.deviceToken = request.json?["deviceToken"]?.string ?? user.deviceToken
    
    try user.save()
		
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
