//
//  Migration.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-21.
//

import Foundation
import Vapor
import FluentProvider

public struct UpdateMigration: Preparation {
  public static func prepare(_ database: Database) throws {
    try? NotificationManager.makeQuery().delete()
    try? database.modify(NotificationManager.self) { db in
      db.string("type")
      db.int("typeId")
      db.raw("UNIQUE(\"uuid\", \"type\", \"typeId\")")
    }
  }
  
  public static func revert(_ database: Database) throws {
    
  }
}
