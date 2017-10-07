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
		builder.grouped(TokenMiddleware()).get("meetup", handler: getAllMeetups)
	}
	
	// Gets all the meetups, based on you, the user
	public func getAllMeetups(request: Request) throws -> ResponseRepresentable {
		guard let userId = request.headers["userId"]?.int else {
			throw Abort.badRequest
		}
		
		// once we get userId, we'll find all the ties between meetup
		guard let meetups = try Meetup.makeQuery()
		
		return JSON([:])
	}
}
