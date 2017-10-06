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
	
	public func sendResetPasswordEmail(to user: User) throws {
		let template = HTMLTemplate.reset(user: user)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
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
	Sends a request about forgot password to the user based on their email.
	- Parameters: to - Sends it to the user
	- Parameters: jwt - token expected
	**/
	public func sendForgotPasswordEmail(to user: User, jwt: String) throws {
		// Generate Template
		let template = HTMLTemplate.forgot(user: user, jwt: jwt)
		let message = try HTMLTemplate.makeMessage(template)
		let email = Email(emails: [user.email], subject: template.subject, message: message)
		
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
	Sends a verification email based on the parameters given
	- Parameters: to - Sends it to the person
	- Parameters: jwt - The token from the registration process
	**/
	public func sendVerificationEmail(to user: User, jwt: String) throws {
		//: Generate the Email Message Format
		let template = HTMLTemplate.verification(user: user, jwt: jwt)
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
