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
		let meetup = builder.grouped(TokenMiddleware()).grouped("meetup")
		
		
	}
}
