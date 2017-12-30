//
//  V1Collection.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import Vapor
import HTTP
import Crypto

public final class V1Collection: EmptyInitializable, RouteCollection {
	public init() { }
	
	public func build(_ builder: RouteBuilder) throws {
		// gets the versioning for future release
		let api = builder.grouped("api", "v1")
		
    //MARK: - Authentication
    let authController = AuthController()
    api.group("auth") { auth in
      auth.post("register", handler: authController.register)
      auth.post("login", handler: authController.login)
      auth.post("verify", handler: authController.verify)
      auth.post("resend", handler: authController.resend)
    }
    
    //MARK: - Users
    try api.grouped(TokenMiddleware()).resource("users", UserController.self)
    
    //MARK: - Friends
    let friendController = FriendController()
    api.grouped(TokenMiddleware()).group("users", ":userId") { friend in
      friend.resource("friends", friendController)
      friend.get("friends", ":friendId", handler: friendController.getFriend)
      friend.patch("friends", ":friendId", handler: friendController.updateFriend)
      friend.delete("friends", ":friendId", handler: friendController.removeFriend)
      friend.get("friends", "requests", handler: friendController.getFriendRequests)
      friend.get("friends", ":friendId", "requests", handler: friendController.getFriendRequest)
    }
    
    //MARK: - Meetup
    try api.grouped(TokenMiddleware()).resource("meetups", MeetupController.self)
   
    //MARK: - Invites
    try api.grouped(TokenMiddleware()).resource("invites", InviteController.self)
	}
}
