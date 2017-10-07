//
//  SeedCommand.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-07.
//

import Vapor
import Console

public final class SeedCommand: Command {
	public let id = "seed-command"
	public let help = ["This command initializes the database with pre-added data."]
	public let console: ConsoleProtocol
	
	public init(console: ConsoleProtocol) {
		self.console = console
	}
	
	public func run(arguments: [String]) throws {
		console.print("running custom command..")
	}
}

extension SeedCommand: ConfigInitializable {
	public convenience init(config: Config) throws {
		let console = try config.resolveConsole()
		self.init(console: console)
	}
}
