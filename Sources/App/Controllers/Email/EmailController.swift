//
//  EmailController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import Foundation
import HTTP

public class EmailController {
	private let apiKey: String
	private let host: String
	
	/**
	Initializer for us to setup
	- Parameters: host easy to setup
	- Parameters: accessKey
	- Parameters: secretKey
	**/
	public init(config: Config) throws {
		self.apiKey = try config.get("apiKey")
		self.host = try config.get("host")
	}
	
	/**
	Sends a verification email based on the parameters given
	- Parameters: to - Sends it to the person
	- Parameters: code - The token from the registration process
	**/
	public func sendVerificationEmail(to user: User, code: Int) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.verification(user: user, code: code)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
		//: This'll change soon
		var emailJSON = try email.makeJSON()
		try emailJSON.set("html", message)
		
		var json = JSON()
		try json.set("recipients", try email.makeEmailJSON())
		try json.set("content", emailJSON)
		
		let request = Request(method: .post, uri: "\(host)/transmissions", headers: ["Content-Type": "application/json", "Authorization": apiKey], body: json.makeBody())
		let response = try droplet?.client.respond(to: request)
		
		guard let statusCode = response?.status.statusCode, (200..<299).contains(statusCode) else {
			throw Abort.serverError
		}
	}
	
	/**
	Sends a confirmation email based on the parameters given
	- Parameters: to - Sends it to the person
	**/
	public func sendConfirmationEmail(to user: User) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.confirmation(user: user)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
		//: This'll change soon
		var emailJSON = try email.makeJSON()
		try emailJSON.set("html", message)
		
		var json = JSON()
		try json.set("recipients", try email.makeEmailJSON())
		try json.set("content", emailJSON)
		
		let request = Request(method: .post, uri: "\(host)/transmissions", headers: ["Content-Type": "application/json", "Authorization": apiKey], body: json.makeBody())
		let response = try droplet?.client.respond(to: request)
		
		guard let statusCode = response?.status.statusCode, (200..<299).contains(statusCode) else {
			throw Abort.serverError
		}
	}
	
	/**
	Sends an invitaion email based on the parameters given
	- Parameters: From - From the user
	- Parameters: to - Sends it to the person
	**/
	public func sendInvitationEmail(from: User, to user: User, meetup: String) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.invite(from: from, to: user, meetup: meetup)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
		//: This'll change soon
		var emailJSON = try email.makeJSON()
		try emailJSON.set("html", message)
		
		var json = JSON()
		try json.set("recipients", try email.makeEmailJSON())
		try json.set("content", emailJSON)
		
		let request = Request(method: .post, uri: "\(host)/transmissions", headers: ["Content-Type": "application/json", "Authorization": apiKey], body: json.makeBody())
		let response = try droplet?.client.respond(to: request)
		
		guard let statusCode = response?.status.statusCode, (200..<299).contains(statusCode) else {
			throw Abort.serverError
		}
	}
	
	/**
	Sends an accepted invitaion email based on the parameters given
	- Parameters: From - From the user
	- Parameters: to - Sends it to the person
	- Parameters: meetup - the meetup that they've accepted
	**/
	public func sendAcceptedInvitationEmail(from: User, to user: User, meetup: String) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.acceptInvite(from: from, to: user, meetup: meetup)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
		//: This'll change soon
		var emailJSON = try email.makeJSON()
		try emailJSON.set("html", message)
		
		var json = JSON()
		try json.set("recipients", try email.makeEmailJSON())
		try json.set("content", emailJSON)
		
		let request = Request(method: .post, uri: "\(host)/transmissions", headers: ["Content-Type": "application/json", "Authorization": apiKey], body: json.makeBody())
		let response = try droplet?.client.respond(to: request)
		
		guard let statusCode = response?.status.statusCode, (200..<299).contains(statusCode) else {
			throw Abort.serverError
		}
	}
	
	/**
	Sends a friend request email based on the parameters given
	- Parameters: From - From the user
	- Parameters: to - Sends it to the person
	**/
	public func sendFriendRequestEmail(from: User, to user: User) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.friendRequest(from: from, to: user)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
		//: This'll change soon
		var emailJSON = try email.makeJSON()
		try emailJSON.set("html", message)
		
		var json = JSON()
		try json.set("recipients", try email.makeEmailJSON())
		try json.set("content", emailJSON)
		
		let request = Request(method: .post, uri: "\(host)/transmissions", headers: ["Content-Type": "application/json", "Authorization": apiKey], body: json.makeBody())
		let response = try droplet?.client.respond(to: request)
		
		guard let statusCode = response?.status.statusCode, (200..<299).contains(statusCode) else {
			throw Abort.serverError
		}
	}

	/**
	Sends an invitaion email based on the parameters given
	- Parameters: From - From the user
	- Parameters: to - Sends it to the person
	**/
	public func sendAcceptedFriendRequestEmail(from: User, to user: User) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.acceptFriend(from: from, to: user)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
		//: This'll change soon
		var emailJSON = try email.makeJSON()
		try emailJSON.set("html", message)
		
		var json = JSON()
		try json.set("recipients", try email.makeEmailJSON())
		try json.set("content", emailJSON)
		
		let request = Request(method: .post, uri: "\(host)/transmissions", headers: ["Content-Type": "application/json", "Authorization": apiKey], body: json.makeBody())
		let response = try droplet?.client.respond(to: request)
		
		guard let statusCode = response?.status.statusCode, (200..<299).contains(statusCode) else {
			throw Abort.serverError
		}
	}
}
