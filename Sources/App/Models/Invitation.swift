//
//  Invitation.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import FluentProvider

public final class Invitation: Model, Timestampable {
  public var inviterId: Identifier
  public var inviteeId: Identifier
	public var meetupId: Identifier
	public var accepted: Bool = false
	
	public let storage = Storage()
	
  public init(inviterId: Identifier, inviteeId: Identifier, meetupId: Identifier) {
		self.inviterId = inviterId
    self.inviteeId = inviteeId
		self.meetupId = meetupId
	}
	
	public init(row: Row) throws {
    inviterId = try row.get("inviterId")
		inviteeId = try row.get("inviteeId")
		meetupId = try row.get("meetupId")
		accepted = try row.get("accepted")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
    try row.set("inviterId", inviterId)
    try row.set("inviteeId", inviteeId)
		try row.set("meetupId", meetupId)
		try row.set("accepted", accepted)
		return row
	}
}

extension Invitation {
	public var meetup: Parent<Invitation, Meetup> {
		return parent(id: meetupId)
	}
	
	public var inviter: Parent<Invitation, User> {
		return parent(id: inviterId)
	}
  
  public var invitee: Parent<Invitation, User> {
    return parent(id: inviteeId)
  }
}

extension Invitation: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { invitation in
			invitation.id()
      invitation.parent(User.self, foreignIdKey: "inviterId")
      invitation.parent(User.self, foreignIdKey: "inviteeId")
			invitation.parent(Meetup.self)
			invitation.bool("accepted", default: false)
      invitation.raw("UNIQUE(\"inviterId\", \"inviteeId\", \"meetupId\")")
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Invitation: JSONConvertible {
	public convenience init(json: JSON) throws {
		self.init(
      inviterId: try json.get("inviterId"),
      inviteeId: try json.get("inviteeId"),
			meetupId: try json.get("meetupId")
		)
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("id", id)
    try json.set("inviter", inviter.get()?.makeJSON())
    try json.set("invitee", invitee.get()?.makeJSON())
		try json.set("accepted", accepted)
		try json.set("createdAt", createdAt)
		try json.set("updatedAt", updatedAt)
		return json
	}
}
