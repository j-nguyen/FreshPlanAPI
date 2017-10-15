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
		auth.post("verify", handler: verify)
		auth.post("resend", handler: resend)
	}
	
	public func resend(request: Request) throws -> ResponseRepresentable {
		guard let email = request.json?["email"]?.string?.lowercased() else {
			throw Abort.badRequest
		}
		
		guard let user = try User.makeQuery().filter("email", email).first() else {
			throw Abort.badRequest
		}
		
		guard let userId = user.id else { throw Abort.notFound }
		
		// attempt to get the verification token next
		guard let userVerify = try Verification.makeQuery().filter("userId", userId).first() else {
			throw Abort.notFound
		}
		
		// if we know the record is there, we can regen it for them.
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
		try payload.set("code", code)
		
		// creat the token string
		let token = try JWT(payload: payload, signer: HS512(key: "verify".bytes))
		let tokenString = try token.createToken()
		
		userVerify.token = tokenString
		try userVerify.save()
		
		// send email
		guard let config = droplet?.config["sparkpost"] else { throw Abort.notFound }
		
		let emailController = try EmailController(config: config)
		try emailController.sendVerificationEmail(to: user, code: code)
		
		return JSON([:])
	}
	
	public func verify(request: Request) throws -> ResponseRepresentable {
		guard
			let email = request.json?["email"]?.string?.lowercased(),
			let code = request.json?["code"]?.int else {
				throw Abort.badRequest
		}
		
		guard let user = try User.makeQuery().filter("email", email).first() else {
			throw Abort(.notFound, reason: "This user does not exist! Did you create an account?")
		}
		
		guard let userId = user.id else { throw Abort.notFound }
		
		guard let userVerify = try Verification.makeQuery().filter("userId", userId).first() else {
			throw Abort.notFound
		}
		
		guard userId == userVerify.userId else { throw Abort(.forbidden, reason: "Please contact an administrator") }
		
		// attempt to get the token, and verify its result
		let jwt = try JWT(token: userVerify.token)
		
		do {
			try jwt.verifySignature(using: HS512(key: "verify".bytes))
		} catch {
			throw Abort(.forbidden, metadata: "Invalid token, please contact an administrator")
		}
		
		// check the expiration date
		guard let exp = jwt.payload["exp"]?.int, TimeInterval(exp) > Date().timeIntervalSince1970 else {
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
			try payload.set("code", code)
			
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
		
		guard code == jwt.payload["code"]?.int else {
			throw Abort(.forbidden, reason: "These codes don't match!")
		}
		
		user.verified = true
		try user.save()
		
		// once it's verified, we can also delete our record as well
		try userVerify.delete()
		
		guard let config = droplet?.config["sparkpost"] else { throw Abort.notFound }
		
		let emailController = try EmailController(config: config)
		try emailController.sendConfirmationEmail(to: user)
		
		return JSON([:])
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
			throw Abort(.notFound, reason: "This user does not exist! Did you create an account?")
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
		try payload.set("code", code)
		
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
