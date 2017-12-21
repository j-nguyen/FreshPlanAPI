//
//  SeedCommand.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-07.
//

import Foundation
import Vapor
import Console

public final class SeedCommand: Command {
	public let id = "seed"
	public let help = ["This command initializes the database with pre-added data."]
	public let console: ConsoleProtocol
	
	public let meetupType: [Config]?
	
	public init(_ console: ConsoleProtocol, meetupType: [Config]?) {
		self.console = console
		self.meetupType = meetupType
	}
	
	fileprivate func addMeetupTypes() throws {
		if let meetupType = meetupType {
			try meetupType.forEach { type in
				guard let name = type.string else { throw Abort.notFound }
				console.print("Saving meetup type: \(name)")
				let meetupObj = MeetupType(type: name)
				try meetupObj.save()
				console.print("Done.")
			}
		}
	}
	
	fileprivate func addUsers() throws {
		for i in 1...10 {
			let user = try User(
				displayName: "fakeuser\(i)",
				email: "fakeuser\(i)@example.com",
				password: "test1234"
			)
			user.verified = true
			console.print("Attempting to add \(user.displayName)")
			try User.register(user: user)
			console.print("User added.")
		}
		console.print("Added 10 users.")
	}
    
  fileprivate func addInvites() throws {
    let user = try User.all()
    let meetup = try Meetup.all()
    try meetup.forEach { meetup in
      try user.forEach { user in
        if meetup.userId != user.id {
          let invite = Invitation(inviterId: meetup.userId, inviteeId: user.id!, meetupId: meetup.id!)
          try? invite.save()
          console.print("add user \(user.displayName)")
        }
      }
    }
  }
	
	fileprivate func addMeetups() throws {
    guard let currentUser = try User.find(1) else { return }
    let meetupTypes = try MeetupType.all()
    let users = try User.makeQuery().filter("id", .notEquals, currentUser.id).all()
    let currentDate = Date()
    
    // create location
    var locationJSON = JSON()
    try locationJSON.set("title", "random title")
    try locationJSON.set("latitude", 24.2352351)
    try locationJSON.set("longitude", 23.126343)
    let locationJSONString = try locationJSON.serialize().makeString()
    
    // create other
    var otherJSON = JSON()
    try otherJSON.set("title", "random title suited")
    try otherJSON.set("description", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis nunc eget lorem dolor sed viverra. Nulla aliquet enim tortor at auctor urna nunc.")
    let otherJSONString = try otherJSON.serialize().makeString()
    
    users.forEach { user in
      let code: Int
      #if os(Linux)
        code = Int(random())
      #else
        code = Int(arc4random_uniform(1))
      #endif
      
      let meetup = Meetup(
        meetupTypeId: meetupTypes[code].id!,
        userId: currentUser.id!,
        title: "Meetup-\(meetupTypes[code].type)-\(user.id!.int!)",
        startDate: currentDate,
        endDate: currentDate.addingTimeInterval(15241),
        metadata: (code == 1) ? locationJSONString : otherJSONString
      )
      try? meetup.save()
      console.print("Saved meetup: \(meetup.title)")
    }
	}
	
	public func run(arguments: [String]) throws {
		console.print("running custom command..")
		try addMeetupTypes()
		try addUsers()
		try addMeetups()
    try addInvites()
	}
}

extension SeedCommand: ConfigInitializable {
	public convenience init(config: Config) throws {
		let meetupType = config["seed", "meetupTypes"]?.array
		let console = try config.resolveConsole()
		self.init(console, meetupType: meetupType)
	}
}
