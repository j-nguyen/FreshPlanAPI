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
import BCrypt

public final class AuthController {
	public func addRoutes(_ builder: RouteBuilder) {
		let auth = builder.grouped("auth")
		// add routes
		auth.post("register", handler: register)
		auth.post("login", handler: login)
	}
	
	/**
		Attempts to login for the user
	**/
	public func login(request: Request) throws -> ResponseRepresentable {
		guard
			let email = request.json?["email"]?.string?.lowercased(),
			let password = request.json?["password"]?.string else {
				throw Abort(.badRequest, reason: "Missing fields!")
		}
		
		guard let user = try User.makeQuery().filter("email", email).first() else {
			throw Abort(.notFound, reason: "User does not exist!")
		}
		
		guard try BCrypt.Hash.verify(message: password, matches: user.password) == true else {
			throw Abort(.unauthorized, reason: "Invalid credentials!")
		}
		
		guard user.verified else {
			throw Abort(.forbidden, reason: "You must be verified in order to log in. Please verify your email address.")
		}
		
		// if all guard are successful, we can create a token to allow access
		var payload = JSON(ExpirationTimeClaim(createTimestamp: { Int(Date().timeIntervalSince1970) + 86400 }))
		try payload.set("userId", user.id)
		
		let token = try JWT(payload: payload, signer: HS512(key: "login".bytes))
		
		var json = JSON()
		try json.set("token", try token.createToken())
		
		return json
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
			code = Int(random() % 10000) + 1000
		#else
			code = Int(arc4random_uniform(9999)) + 1000
		#endif
		
		try payload.set("userId", userId)
		
		// creat the token string
		let token = try JWT(payload: payload, signer: HS512(key: "verify".bytes))
		let tokenString = try token.createToken()
		
		// save this into our db.
		let verification = Verification(userId: userId, token: tokenString)
		try verification.save()
		
		// send email
		guard let config = droplet?.config["sparkpost"] else { throw Abort.notFound }
		
		let emailController = try EmailController(config: config)
		try emailController.sendVerificationEmail(to: user, code: code)
		
		return JSON([:])
	}
}
