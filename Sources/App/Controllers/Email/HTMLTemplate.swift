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
}

extension HTMLTemplate {
	var path: String {
		guard let currentDirectory = droplet?.config.viewsDir else { return "" }
		switch self {
		case .verification:
			return "\(currentDirectory)/verification.html"
		case .confirmation:
			return "\(currentDirectory)/confirmation.html"
		}
	}
	
	var subject: String {
		switch self {
		case .verification:
			return "Verifying your User Account"
		case .confirmation:
			return "Account Verified!"
		}
	}
	
	public func type() throws -> String {
		let string = try String(contentsOfFile: path, encoding: .utf8)
		return string
	}
	
	public static func makeMessage(_ template: HTMLTemplate) throws -> String {
		// read the template
		let file = try template.type()
		
		switch template {
		case let .verification(user, code):
			return String.format(file, user.firstName, user.lastName, code)
		case let .confirmation(user):
			return String.format(file, user.firstName, user.lastName)
		}
	}
}
