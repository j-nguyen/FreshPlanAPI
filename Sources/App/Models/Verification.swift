//
//  Verification.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import FluentProvider

public final class Verification: Model {
	public var userId: Identifier
	public var token: String
	
	public let storage = Storage()
	
	public init(userId: Identifier, token: String) {
		self.userId = userId
		self.token = token
	}
	
	public init(row: Row) throws {
		userId = try row.get("userId")
		token = try row.get("token")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("userId", userId)
		try row.set("token", token)
		return row
	}
}

extension Verification {
	public var user: Parent<Verification, User> {
		return parent(id: userId)
	}
}

extension Verification: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { verification in
			verification.id()
			verification.parent(User.self)
			verification.string("token")
			verification.raw("UNIQUE(\"userId\", \"token\")")
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}
