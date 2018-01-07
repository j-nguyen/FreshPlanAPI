//
//  HTMLTemplate.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-05.
//
//
//  HTMLTemplate.swift
//  fractalmediaapi
//
//  Created by Johnny Nguyen on 2017-08-09.
//
//

import Foundation
import Vapor

enum HTMLTemplate {
	case verification(user: User, code: Int)
	case confirmation(user: User)
	case invite(from: User, to: User, meetup: String)
	case friendRequest(from: User, to: User)
	case acceptFriend(from: User, to: User)
	case acceptInvite(from: User, to: User, meetup: String)
}

extension HTMLTemplate {
	var path: String {
		guard let currentDirectory = droplet?.config.viewsDir else { return "" }
		switch self {
		case .verification:
			return "\(currentDirectory)/verification.html"
		case .confirmation:
			return "\(currentDirectory)/confirmation.html"
		case .invite:
			return "\(currentDirectory)/invite.html"
		case .friendRequest:
			return "\(currentDirectory)/friendRequest.html"
		case .acceptFriend:
			return "\(currentDirectory)/acceptFriend.html"
		case .acceptInvite:
			return "\(currentDirectory)/acceptInvite.html"
		}
	}
	
	var subject: String {
		switch self {
		case .verification:
			return "Verifying your User Account"
		case .confirmation:
			return "Account Verified!"
		case .invite:
			return "Meetup Invitation"
		case .friendRequest:
			return "FreshPlan - Friend Request"
		case .acceptFriend:
			return "Accepted Friend Request"
		case .acceptInvite(let user, _, _):
			return "Accepted Invitation - \(user.displayName)"
		}
	}
	
	public func type() throws -> String {
		let string = try String(contentsOfFile: path, encoding: .utf8)
		return string
	}
	
	public func makeMessage() throws -> String {
		// read the template
		let file = try self.type()
		
		switch self {
		case let .verification(user, code):
			return String.format(file, user.displayName, code)
		case let .confirmation(user):
			return String.format(file, user.displayName)
		case let .invite(from, to, meetup):
			return String.format(file, to.displayName, from.displayName, meetup)
		case let .friendRequest(from, to):
			return String.format(file, to.displayName, from.displayName)
		case let .acceptFriend(from, to):
			return String.format(file, to.displayName, from.displayName)
		case let .acceptInvite(from, to, meetup):
			return String.format(file, to.displayName, from.displayName, meetup)
		}
	}
}
