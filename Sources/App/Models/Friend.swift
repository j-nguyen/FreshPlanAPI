//
//  Friends.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-08.
//

import Vapor
import FluentProvider

public final class Friend: Model, Timestampable {
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
		friendsId = try row.get("friendId")
		accepted = try row.get("accepted")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("userId", userId)
		try row.set("friendId", friendsId)
		try row.set("accepted", accepted)
		return row
	}
}

extension Friend {
	public var user: Parent<Friend, User> {
		return parent(id: userId)
	}
	
	public var friend: Parent<Friend, User> {
		return parent(id: friendsId)
	}
}

extension Friend: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { friend in
			friend.id()
			friend.parent(User.self)
			friend.parent(User.self, foreignIdKey: "friendId")
			friend.bool("accepted", default: false)
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Friend: JSONConvertible {
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
