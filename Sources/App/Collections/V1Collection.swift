//
//  V1Collection.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import Vapor
import HTTP

public final class V1Collection: EmptyInitializable, RouteCollection {
	public init() { }
	
	public func build(_ builder: RouteBuilder) throws {
		// gets the versioning for future release
		let api = builder.grouped("api", "v1")
		// add from the controllers
		AuthController().addRoutes(api)
    try api.grouped(TokenMiddleware()).resource("users", UserController.self)
    try api.grouped(TokenMiddleware()).grouped("users").resource("friends", FriendController.self)
    try api.grouped(TokenMiddleware()).resource("meetup", MeetupController.self)
    try api.grouped(TokenMiddleware()).resource("invites", InviteController.self)
	}
}
