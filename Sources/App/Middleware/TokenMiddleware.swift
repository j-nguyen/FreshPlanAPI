//
//  TokenMiddleware.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import HTTP
import Foundation
import JWT

public final class TokenMiddleware: Middleware {
	public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		// get our token string, if there isn't any then we know it doesn't exist
		guard let token = request.headers["Authorization"]?.string else {
			throw Abort(.forbidden, metadata: "No token found!")
		}
		
		// Attempt to verify token
		let jwt: JWT
		
		do {
			jwt = try JWT(token: token)
			try jwt.verifySignature(using: HS512(key: "login".bytes))
			
		} catch {
			throw Abort(.unauthorized, metadata: "Token is either invalid, or something is wrong.")
		}
		
		guard let exp = jwt.payload["exp"]?.int, TimeInterval(exp) > Date().timeIntervalSince1970 else {
			throw Abort(.unauthorized, metadata: "Expired Token, please re-login")
		}
		
		let userId: Int = try jwt.payload.get("userId")
		
		guard try User.find(userId) != nil else {
			throw Abort.notFound
		}
		
		// this is now our header where we can get our userId
		request.headers["userId"] = String(userId)
		
		return try next.respond(to: request)
	}
}

