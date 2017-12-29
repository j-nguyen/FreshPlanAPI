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
			try? meetupType.forEach { type in
				guard let name = type.string else { throw Abort.notFound }
				console.print("Saving meetup type: \(name)")
				let meetupObj = MeetupType(type: name)
				try? meetupObj.save()
				console.print("Done.")
			}
		}
	}
	
	fileprivate func addUsers() throws {
		for i in 1...5 {
			let user = try User(
				displayName: "fakeuser\(i)",
				email: "fakeuser\(i)@example.com",
				password: "test1234"
			)
			user.verified = true
			console.print("Attempting to add \(user.displayName)")
			try? User.register(user: user)
			console.print("User added.")
		}
		console.print("Added 5 users.")
	}
  
  fileprivate func addFriends() throws {
    let users = try User.all()
    
    users.forEach { user in
      users.forEach { other in
        if user.id != other.id {
          let friend = Friend(userId: user.id!, friendId: other.id!)
          try? friend.save()
          console.print("\(user.displayName) and \(other.displayName) are now friends!")
        }
      }
    }
  }
    
  fileprivate func addInvites() throws {
    let meetups = try Meetup.all()
    try meetups.forEach { meetup in
      let friends = try Friend.makeQuery().filter("userId", meetup.userId).all()
      friends.forEach { friend in
        let invitation = Invitation(inviterId: meetup.userId, inviteeId: friend.id!, meetupId: meetup.id!)
        try? invitation.save()
        console.print("Invitation saved for: \(meetup.title)")
      }
    }
  }
	
	fileprivate func addMeetups() throws {
    let meetupTypes = try MeetupType.all()
    let users = try User.all()
    let description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis nunc eget lorem dolor sed viverra. Nulla aliquet enim tortor at auctor urna nunc. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis nunc eget lorem dolor sed viverra. Nulla aliquet enim tortor at auctor urna nunc."
    let currentDate = Date()
    
    // create location
    var locationJSON = JSON()
    try locationJSON.set("latitude", 24.2352351)
    try locationJSON.set("longitude", 23.126343)
    let locationJSONString = try locationJSON.serialize().makeString()
    
    // create other
    var otherJSON = JSON()
    try otherJSON.set("notes", "Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Turpis nunc eget lorem dolor sed viverra. Nulla aliquet enim tortor at auctor urna nunc.")
    let otherJSONString = try otherJSON.serialize().makeString()
    
    users.forEach { user in
      for index in 0...1 {
        let meetup = Meetup(
          meetupTypeId: meetupTypes[index].id!,
          userId: user.id!,
          title: "Meetup-\(meetupTypes[index].type)-\(user.id!.int!)",
          description: description,
          startDate: currentDate.addingTimeInterval(13492),
          endDate: currentDate.addingTimeInterval(124342),
          metadata: (meetupTypes[index].type == "location") ? locationJSONString : otherJSONString
        )
        try? meetup.save()
        console.print("Saved meetup: \(meetup.title)")
      }
    }
	}
	
	public func run(arguments: [String]) throws {
		console.print("running custom command..")
		try? addMeetupTypes()
		try? addUsers()
		try? addMeetups()
    try? addFriends()
    try? addInvites()
	}
}

extension SeedCommand: ConfigInitializable {
	public convenience init(config: Config) throws {
		let meetupType = config["seed", "meetupTypes"]?.array
		let console = try config.resolveConsole()
		self.init(console, meetupType: meetupType)
	}
}
