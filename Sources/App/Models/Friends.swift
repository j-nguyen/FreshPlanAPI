//
//  Friends.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-08.
//

import Vapor
import FluentProvider

public final class Friends: Model, Timestampable {
	public var userId: Identifier
	public var friendsId: Identifier
	public var accepted: Bool = false
	
	public let storage = Storage()
	
	public init(userId: Identifier, friendsId: Identifier, accepted: Bool = false) {
		self.userId = userId
		self.friendsId = friendsId
		self.accepted = accepted
	}
	
	public init(row: Row) throws {
		userId = try row.get("userId")
		friendsId = try row.get("friendsId")
		accepted = try row.get("accepted")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("userId", userId)
		try row.set("friendsId", friendsId)
		try row.set("accepted", accepted)
		return row
	}
}

extension Friends {
	public var user: Parent<Friends, User> {
		return parent(id: userId)
	}
	
	public var friend: Parent<Friends, User> {
		return parent(id: friendsId)
	}
}

extension Friends: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { friends in
			friends.id()
			friends.parent(User.self)
			friends.parent(User.self, foreignIdKey: "friendsId")
			friends.bool("accepted", default: false)
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Friends: JSONConvertible {
	public convenience init(json: JSON) throws {
		self.init(userId: try json.get("userId"), friendsId: try json.get("friendsId"))
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("id", id)
		try json.set("user", user.get()?.makeJSON())
		try json.set("friend", friend.get()?.makeJSON())
		try json.set("accepted", accepted)
		return json
	}
}
