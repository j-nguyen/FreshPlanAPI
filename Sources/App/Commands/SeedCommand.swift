//
//  SeedCommand.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-07.
//

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
		for i in 1...25 {
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
		console.print("Added 25 users.")
	}
	
	fileprivate func addFriends() throws {
		// we will attempt to add every single friend, lol
		for primaryId in 1...25 {
			// we will add the !, because this is run after addUsers()
			let user = try User.find(primaryId)!
			for secondaryId in 1...25 {
				let secondaryUser = try User.find(secondaryId)!
				// attempt to add friend here
        // it can't be the same user though.
        if primaryId != secondaryId {
          console.print("User: \(user.displayName) adding \(secondaryUser.displayName)")
          let friend = Friend(userId: user.id!, friendsId: secondaryUser.id!)
          try friend.save()
          console.print("Friend added.")
        }
			}
		}
		console.print("Added all friends")
	}
	
	fileprivate func addMeetups() throws {
		for i in 1...5 {
			let user = try User.find(i)!
			for j in 1...2 {
				for k in 1...5 {
					let currentDate = Date()
					let meetup = Meetup(
						meetupTypeId: Identifier(j),
						userId: user.id!,
						title: "Meetup\(i)\(j)\(k)",
						startDate: currentDate,
						endDate: currentDate.addingTimeInterval(10293), // we'll add some random date
						metadata: ""
					)
					console.print("Attempting to add meetup: \(meetup.title)")
					try meetup.save()
					console.print("Meetup saved")
				}
			}
		}
		console.print("Meetup saved")
	}
	
	fileprivate func addInvites() throws {
		for i in 1...5 {
			let user = try User.find(i)!
			for j in 1...10 {
				let meetup = try Meetup.find(j)!
				// attempt to get an invite here
				let invite = Invitation(userId: user.id!, meetupId: meetup.id!)
				console.print("Attempt to add invite: \(try invite.meetup.get()!.title)")
				try invite.save()
				console.print("Invitation saved")
			}
		}
	}
	
	public func run(arguments: [String]) throws {
		console.print("running custom command..")
		try addMeetupTypes()
		try addUsers()
		try addFriends()
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
