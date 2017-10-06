//
//  Email.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor

public struct Email: JSONRepresentable {
	public var emails: [String]
	public var subject: String
	public var message: String
	
	public init(emails: [String] = [], subject: String, message: String) {
		self.emails = emails
		self.subject = subject
		self.message = message
	}
	
	public func makeEmailJSON() throws -> [JSON] {
		var emailJSON: [JSON] = []
		for email in emails {
			let json = try JSON(node: ["address": email])
			emailJSON.append(json)
		}
		return emailJSON
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("from", serverEmail)
		try json.set("subject", subject)
		return json
	}
}
