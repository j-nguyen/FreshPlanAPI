//
//  AuthController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import Vapor
import HTTP
import JWT
import Foundation

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
	  try User.register(user: user)
		
		//: This helps us create a "verification" registeration to verify your email
		var payload = JSON(ExpirationTimeClaim(createTimestamp: { Int(Date().timeIntervalSince1970) + 86400 }))
		try payload.set("userId", user.id)
		
		let token = try JWT(payload: payload, signer: HS512(key: "verify".bytes))
		let tokenString = try token.createToken()
		
		return JSON([:])
	}
}
