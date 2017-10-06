//
//  AuthController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import Vapor
import HTTP

public final class AuthController {
	public func addRoutes(_ builder: RouteBuilder) {
		let auth = builder.grouped("auth")
		// add routes
		auth.post("register", handler: register)
	}
	
	/**
		Registers the user, from the static function register
	**/
	public func register(request: Request) throws -> ResponseRepresentable {
		guard let json = request.json else { throw Abort.badRequest }
		
	  let user = try User(json: json)
		let registeredUser = try User.register(user: user)
		
		return try registeredUser.makeJSON()
	}
}
