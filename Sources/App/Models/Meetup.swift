//
//  Meetup.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import FluentProvider

public final class Meetup: Model, Timestampable {
	public var meetupTypeId: Identifier
	public var title: String
	public var startDate: Date
	public var endDate: Date
	public var metadata: String
	
	public let storage = Storage()
	
	public init(meetupTypeId: Identifier, title: String, startDate: Date, endDate: Date, metadata: String) {
		self.meetupTypeId = meetupTypeId
		self.title = title
		self.startDate = startDate
		self.endDate = endDate
		self.metadata = metadata
	}
	
	public init(row: Row) throws {
		meetupTypeId = try row.get("meetupTypeId")
		title = try row.get("title")
		startDate = try row.get("startDate")
		endDate = try row.get("endDate")
		metadata = try row.get("metadata")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("meetupTypeId", meetupTypeId)
		try row.set("title", title)
		try row.set("startDate", startDate)
		try row.set("endDate", endDate)
		try row.set("metadata", metadata)
		return row
	}
}

extension Meetup {
	public var meetupType: Parent<Meetup, MeetupType> {
		return parent(id: meetupTypeId)
	}
}

extension Meetup: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { meetup in
			meetup.id()
			meetup.parent(MeetupType.self)
			meetup.string("title")
			meetup.date("startDate")
			meetup.date("endDate")
			meetup.custom("metadata", type: "TEXT")
			meetup.raw("UNIQUE(\"meetupTypeId\", \"title\")")
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension Meetup: JSONConvertible {
	public convenience init(json: JSON) throws {
	 self.init(
			meetupTypeId: try json.get("meetupTypeId"),
		  title: try json.get("title"),
		  startDate: try json.get("startDate"),
		  endDate: try json.get("endDate"),
		  metadata: try json.get("metadata")
		)
	}
	
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("meetupType", meetupType.get()?.makeJSON())
		try json.set("title", title)
		try json.set("startDate", startDate)
		try json.set("endDate", endDate)
		try json.set("metadata", metadata)
		return json
	}
}
