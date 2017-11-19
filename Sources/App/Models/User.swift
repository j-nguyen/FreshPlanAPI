//
//  User.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//

import Vapor
import BCrypt
import FluentProvider
import Validation

public final class User: Model, Timestampable {
	
	public var firstName: String
	public var lastName: String
	public var displayName: String
	public var email: String
	public var password: String
	public var profileURL: String
	public var verified: Bool = false
	
	public let storage = Storage()
	
	public init(firstName: String, lastName: String, displayName: String, email: String, password: String, verified: Bool = false) throws {
		self.firstName = firstName
		self.lastName = lastName
    self.displayName = displayName
		self.email = email
		self.password = password
		self.profileURL = try firstName.generatePlaceholder()
		self.verified = verified
	}
	
	public init(row: Row) throws {
		firstName = try row.get("firstName")
		lastName = try row.get("lastName")
		displayName = try row.get("displayName")
		email = try row.get("email")
		password = try row.get("password")
		profileURL = try row.get("profileURL")
		verified = try row.get("verified")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("firstName", firstName)
		try row.set("lastName", lastName)
		try row.set("displayName", displayName)
		try row.set("email", email)
		try row.set("password", password)
    try row.set("profileURL", profileURL)
		try row.set("verified", verified)
		return row
	}
}

extension User {
	
	/**
	 * Checks for the registration on the user
	**/
	public static func register(user: User) throws {
		guard user.email != "", user.firstName != "", user.lastName != "", user.password != "", user.displayName != "" else {
			throw Abort(.conflict, reason: "Some fields are missing!")
		}
		guard try User.makeQuery().filter("email", user.email.lowercased()).first() == nil else {
			throw Abort(.conflict, reason: "Email address already exists! Do you have an account?")
		}
		
		guard try User.makeQuery().filter("displayName", user.displayName.lowercased().trim()).first() == nil else {
				throw Abort(.conflict, reason: "Display Name already exists!")
		}
		
		// now we do some actual authentic validation cheking provided by Vapor
		user.email = user.email.lowercased()
		user.displayName = user.displayName.lowercased().trim()
		
		do {
			try user.email.validated(by: EmailValidator())
		} catch {
			throw Abort(.conflict, metadata: "That is not a valid email address")
		}
		
		do {
			try user.firstName.validated(by: OnlyAlphanumeric())
			try user.lastName.validated(by: OnlyAlphanumeric())
		} catch {
			throw Abort(.conflict, metadata: "Your names must be alpha numeric only!")
		}
		
		do {
			try user.password.validated(by: Count.min(8))
		} catch {
			throw Abort(.conflict, metadata: "Your password must be at least a minimum length of 8")
		}
		
		user.password = try Hash.make(message: user.password).makeString()
	
		try user.save()
	}
}

extension User: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { user in
			user.id()
			user.string("firstName")
			user.string("lastName")
			user.string("displayName", unique: true)
			user.string("email", unique: true)
			user.string("password")
			user.string("profileURL")
			user.bool("verified", default: false)
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension User: JSONConvertible {
	public convenience init(json: JSON) throws {
		try self.init(
			firstName: try json.get("firstName"),
		  lastName: try json.get("lastName"),
			displayName: try json.get("displayName"),
		  email: try json.get("email"),
		  password: try json.get("password")
		)
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("id", id)
		try json.set("firstName", firstName)
		try json.set("lastName", lastName)
		try json.set("displayName", displayName)
		try json.set("email", email)
		try json.set("profileURL", profileURL)
		try json.set("verified", verified)
		try json.set("createdAt", createdAt)
		try json.set("updatedAt", updatedAt)
		return json
	}
}
