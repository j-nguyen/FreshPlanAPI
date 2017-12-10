//
//  Friend.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-10.
//

import Vapor
import FluentProvider

public final class Friend: Model, Timestampable {
  public var userId: Identifier
  public var friendId: Identifier
  
  public let storage: Storage = Storage()
  
  public init(userId: Identifier, friendId: Identifier) {
    self.userId = userId
    self.friendId = friendId
  }
  
  public init(row: Row) throws {
    userId = try row.get("userId")
    friendId = try row.get("friendId")
  }
  
  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("userId", userId)
    try row.set("friendId", friendId)
    return row
  }
}

extension Friend {
  public var user: Parent<Friend, User> {
    return parent(id: userId)
  }
  
  public var friend: Parent<Friend, User> {
    return parent(id: friendId)
  }
}

extension Friend: Preparation {
  public static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.parent(User.self)
      db.parent(User.self, foreignIdKey: "friendId")
      db.raw("UNIQUE(\"userId\", \"friendId\")")
    }
  }
  
  public static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension Friend: JSONConvertible {
  public convenience init(json: JSON) throws {
    self.init(
      userId: try json.get("userId"),
      friendId: try json.get("friendId")
    )
  }
  
  public func makeJSON() throws -> JSON {
    return try friend.get()?.makeJSON() ?? JSON()
  }
}
