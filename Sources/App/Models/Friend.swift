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
    return parent(id: friendsId)
  }
}

extension Friend: Preparation {
  
}
