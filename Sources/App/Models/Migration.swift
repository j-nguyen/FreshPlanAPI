//
//  Migration.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-21.
//

import Foundation
import Vapor
import FluentProvider

public struct Migration: Preparation {
  public static func prepare(_ database: Database) throws {
    try database.modify(Invitation.self) { invite in
      invite.raw("UNIQUE(\"inviterId\", \"inviteeId\")")
    }
  }
  
  public static func revert(_ database: Database) throws {
    
  }
}
