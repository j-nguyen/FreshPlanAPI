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
  
  public let storage: Storage = Storage()
  
  public init(uuid: String) {
    self.uuid = uuid
  }
  
  public init(row: Row) throws {
    uuid = try row.get("uuid")
  }
  
  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("uuid", uuid)
    return row
  }
}

extension NotificationManager: Preparation {
  public static func prepare(_ database: Database) throws {
    try database.create(self) { db in
      db.id()
      db.custom("uuid", type: "TEXT")
    }
  }
  
  public static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}

extension NotificationManager: JSONInitializable {
  public convenience init(json: JSON) throws {
    try self.init(uuid: json.get("uuid"))
  }
}
