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
	case verification(user: User, jwt: String)
	case forgot(user: User, jwt: String)
	case reset(user: User)
}

extension HTMLTemplate {
	var path: String {
		guard let currentDirectory = droplet?.config.viewsDir else { return "" }
		switch self {
		case .verification:
			return "\(currentDirectory)/verification.html"
		case .forgot:
			return "\(currentDirectory)/forgot.html"
		case .reset:
			return "\(currentDirectory)/reset.html"
		}
	}
	
	var subject: String {
		switch self {
		case .verification:
			return "Verifying your Email Address"
		case .forgot:
			return "Forgot Your Password"
		case .reset:
			return "Resetting Your Password Confirmation"
		}
	}
	
	public func type() throws -> String {
		let string = try String(contentsOfFile: path, encoding: .utf8)
		return string
	}
	
	public static func makeMessage(_ template: HTMLTemplate) throws -> String {
		// read the template
		let file = try template.type()
		
		// get the host
		guard let app = droplet?.config["app"]?.object else { throw Abort.notFound }
		guard let host = app["host"]?.string else { throw Abort.notFound }
		
		switch template {
		case let .verification(user, jwt):
			return String.format(file, user.firstName, user.lastName, host, jwt)
		case let .forgot(user, jwt):
			return String.format(file, user.firstName, user.lastName, host, jwt)
		case let .reset(user):
			return String.format(file, user.firstName, user.lastName, host)
		}
	}
}
