//
//  MeetupType.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import FluentProvider

public final class MeetupType: Model {
	public var type: String
	
	public let storage = Storage()
	
	public init(type: String) {
		self.type = type
	}
	
	public init(row: Row) throws {
		type = try row.get("type")
	}
	
	public func makeRow() throws -> Row {
		var row = Row()
		try row.set("type", type)
		return row
	}
}

extension MeetupType: Preparation {
	public static func prepare(_ database: Database) throws {
		try database.create(self) { meetupType in
			meetupType.id()
			meetupType.string("type")
		}
	}
	
	public static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension MeetupType: JSONRepresentable {
	public func makeJSON() throws -> JSON {
		var json = JSON()
		try json.set("id", id)
		try json.set("type", type)
		return json
	}
}
