//
//  Friends.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-08.
//

import Vapor
import FluentProvider

public final class FriendRequest: Model, Timestampable {
	public var requesterId: Identifier
	public var requestedId: Identifier
	public var accepted: Bool = false
	
	public let storage = Storage()
	
	public init(requesterId: Identifier, requestedId: Identifier, accepted: Bool = false) {
		self.requesterId = requesterId
		self.requestedId = requestedId
		self.accepted = accepted
	}
	
	public init(row: Row) throws {
		requesterId = try row.get("requesterId")
		requestedId = try row.get("requestedId")
		accepted = try row.get("accepted")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("requesterId", requesterId)
		try row.set("requestedId", requestedId)
		try row.set("accepted", accepted)
		return row
	}
}

extension FriendRequest {
	public var requester: Parent<FriendRequest, User> {
		return parent(id: requesterId)
	}
	
	public var requested: Parent<FriendRequest, User> {
		return parent(id: requestedId)
	}
}

extension FriendRequest: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { friend in
			friend.id()
      friend.parent(User.self, foreignIdKey: "requesterId")
			friend.parent(User.self, foreignIdKey: "requestedId")
			friend.bool("accepted", default: false)
      friend.raw("UNIQUE(\"requesterId\", \"requestedId\")")
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension FriendRequest: JSONConvertible {
	public convenience init(json: JSON) throws {
		self.init(
      requesterId: try json.get("requesterId"),
      requestedId: try json.get("requestedId")
    )
	}
	
	public func makeJSON() throws -> JSON {
		var json = try requester.get()?.makeJSON()
		try json?.set("accepted", accepted)
    return json ?? JSON()
	}
}
