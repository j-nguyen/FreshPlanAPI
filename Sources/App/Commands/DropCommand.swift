//
//  DropCommand.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-17.
//

import Vapor
import Console

public final class DropCommand: Command {
  public var console: ConsoleProtocol
  public let id: String = "drop"
  public let help = ["This command initializes the database with pre-added data."]
  
  public init(console: ConsoleProtocol) {
    self.console = console
  }
  
  public func run(arguments: [String]) throws {
    console.print("Starting to drop DB..")
    try droplet?.database?.raw("DROP SCHEMA PUBLIC CASCADE;")
    console.print("DB Dropped")
    try droplet?.database?.raw("CREATE SCHEMA PUBLIC;")
    console.print("DB Created")
  }
}

extension DropCommand: ConfigInitializable {
  public convenience init(config: Config) throws {
    let console = try config.resolveConsole()
    self.init(console: console)
  }
}
