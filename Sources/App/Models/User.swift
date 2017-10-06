//
//  User.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import Vapor
import FluentProvider

public final class User: Model, Timestampable {
	
	public var firstName: String
	public var lastName: String
	public var email: String
	public var verified: Bool = false
	
	public let storage = Storage()
	
	public init(firstName: String, lastName: String, email: String, verified: Bool = false) {
		self.firstName = firstName
		self.lastName = lastName
		self.email = email
		self.verified = verified
	}
	
	public init(row: Row) throws {
		firstName = try row.get("firstName")
		lastName = try row.get("lastName")
		email = try row.get("email")
		verified = try row.get("verified")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("firstName", firstName)
		try row.set("lastName", lastName)
		try row.set("verified", verified)
		return row
	}
}

extension User: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { user in
			user.id()
			user.string("firstName")
			user.string("lastName")
			user.string("email")
			user.bool("verified", default: false)
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension User: JSONConvertible {
	public convenience init(json: JSON) throws {
		self.init(
			firstName: try json.get("firstName"),
		  lastName: try json.get("lastName"),
		  email: try json.get("email"),
		  verified: json["verified"]?.bool ?? false
		)
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("firstName", firstName)
		try json.set("lastName", lastName)
		try json.set("email", email)
		try json.set("verified", verified)
		return json
	}
}
