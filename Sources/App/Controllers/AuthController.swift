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
		
		guard let userId = user.id else { throw Abort.notFound }
		
		//: This helps us create a "verification" registeration to verify your email
		var payload = JSON(ExpirationTimeClaim(createTimestamp: { Int(Date().timeIntervalSince1970) + 86400 }))
		
		// set-up our random payload string to check
		var code: Int
		#if os(Linux)
			srandom(UInt32(time(nil)))
			code = Int(random() % 10000)
		#else
			code = Int(arc4random_uniform(9999))
		#endif
		
		try payload.set("userId", userId)
		
		// creat the token string
		let token = try JWT(payload: payload, signer: HS512(key: "verify".bytes))
		let tokenString = try token.createToken()
		
		// save this into our db.
		let verification = Verification(userId: userId, token: tokenString)
		try verification.save()
		
		return JSON([:])
	}
}
