//
//  Invitation.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import FluentProvider

public final class Invitation: Model, Timestampable {
	public var userId: Identifier
	public var meetupId: Identifier
	public var accepted: Bool = false
	
	public let storage = Storage()
	
	public init(userId: Identifier, meetupId: Identifier) {
		self.userId = userId
		self.meetupId = meetupId
	}
	
	public init(row: Row) throws {
		userId = try row.get("userId")
		meetupId = try row.get("meetupId")
		accepted = try row.get("accepted")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("userId", userId)
		try row.set("meetupId", meetupId)
		try row.set("accepted", accepted)
		return row
	}
}

extension Invitation {
	public var meetup: Parent<Invitation, Meetup> {
		return parent(id: meetupId)
	}
	
	public var user: Parent<Invitation, User> {
		return parent(id: userId)
	}
}

extension Invitation: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { invitation in
			invitation.id()
			invitation.parent(User.self)
			invitation.parent(Meetup.self)
			invitation.bool("accepted", default: false)
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Invitation: JSONConvertible {
	public convenience init(json: JSON) throws {
		self.init(
			userId: try json.get("userId"),
			meetupId: try json.get("meetupId")
		)
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("id", id)
		try json.set("meetup", meetup.get()?.makeJSON())
		try json.set("user", user.get()?.makeJSON())
		try json.set("accepted", accepted)
		try json.set("createdAt", createdAt)
		try json.set("updatedAt", updatedAt)
		return json
	}
}
