//
//  MeetupController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import HTTP

public final class MeetupController {
	public func addRoutes(_ builder: RouteBuilder) {
		// add the token middleware here as a default to make sure all routes are secured now
		builder.grouped(TokenMiddleware()).post("meetup", handler: createMeetup)
		builder.grouped(TokenMiddleware()).get("meetup", handler: getAllMeetups)
		builder.grouped(TokenMiddleware()).get("meetup", ":meetupId", handler: getMeetup)
		builder.grouped(TokenMiddleware()).patch("meetup", ":meetupId", handler: updateMeetup)
		builder.grouped(TokenMiddleware()).delete("meetup", ":meetupId", handler: deleteMeetup)
	}
	
	// create the meetup.
	public func createMeetup(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		guard let meetupType = request.json?["meetup"]?.string,
			let meetType = Meetup.MeetType(rawValue: meetupType) else {
				throw Abort(.badRequest, reason: "Invalid meetup type!")
		}
		
		guard
			let title = request.json?["title"]?.string,
			let metadata = request.json?["metadata"]?.string else {
			
			throw Abort(.unprocessableEntity, reason: "Missing Fields!")
		}
		
		guard let startDate = request.json?["startDate"]?.date,
			let endDate = request.json?["endDate"]?.date else {
				throw Abort(.unprocessableEntity, reason: "Missing Dates!")
		}
		
		guard endDate >= startDate else {
			throw Abort(.forbidden, reason: "The dates must be diferent!")
		}
		
		// create the model
		let meetup = Meetup(
			meetupTypeId: try meetType.id(),
			userId: Identifier(userId),
			title: title,
			startDate: startDate,
			endDate: endDate,
			metadata: metadata
		)
		
		try meetup.save()
		
		return JSON([:])
	}
	
	// Gets all the meetups, based on you, the user
	public func getAllMeetups(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		// once we get userId, we'll find all the ties between meetup
		let meetups = try Meetup.makeQuery().filter("userId", userId).all()
		
		return try meetups.makeJSON()
	}
	
	// get meetup based on the id
	public func getMeetup(request: Request) throws -> ResponseRepresentable {
		let meetup = try request.meetup()
		return try meetup.makeJSON()
	}
	
	public func updateMeetup(request: Request) throws -> ResponseRepresentable {
		let meetup = try request.meetup()
		
		if let meetupType = request.json?["meetupType"]?.string {
			guard let meetType = Meetup.MeetType(rawValue: meetupType) else {
				throw Abort.badRequest
			}
			
			meetup.meetupTypeId = try meetType.id()
		}
		
		meetup.title = request.json?["title"]?.string ?? meetup.title
		meetup.startDate = request.json?["startDate"]?.date ?? meetup.startDate
		meetup.endDate = request.json?["endDate"]?.date ?? meetup.endDate
		meetup.metadata = request.json?["metadata"]?.string ?? meetup.metadata
		
		try meetup.save()
		
		return JSON([:])
	}
	
	public func deleteMeetup(request: Request) throws -> ResponseRepresentable {
		let meetup = try request.meetup()
		try meetup.delete()
		return JSON([:])
	}
}

extension Request {
	fileprivate func meetup() throws -> Meetup {
		guard let userId = headers["userId"]?.int, let meetupId = parameters["meetupId"]?.int else {
			throw Abort.badRequest
		}
		
		// once we get userId, we'll find all the ties between meetup
		guard let meetup = try Meetup.makeQuery().filter("userId", userId)
				.and({ try $0.filter("meetupId", meetupId) }).first() else {
			throw Abort.notFound
		}
		
		return meetup
	}
}
