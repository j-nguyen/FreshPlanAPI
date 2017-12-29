//
//  Notification.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-25.
//

import Foundation
import Vapor
import FluentProvider

public final class NotificationManager: Model {
  public var uuid: String
  public var type: String
  public var typeId: Int
  
  public let storage: Storage = Storage()
  
  public init(uuid: String, type: String, typeId: Int) {
    self.uuid = uuid
    self.type = type
    self.typeId = typeId
  }
  
  public init(row: Row) throws {
    uuid = try row.get("uuid")
    type = try row.get("type")
    typeId = try row.get("typeId")
  }
  
  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("uuid", uuid)
    try row.set("type", type)
    try row.set("typeId", typeId)
    return row
  }
}

extension NotificationManager: Preparation {
  public static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.custom("uuid", type: "TEXT")
      db.string("type")
      db.int("typeId")
      db.raw("UNIQUE(\"uuid\", \"type\", \"typeId\")")
    }
  }
  
  public static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
