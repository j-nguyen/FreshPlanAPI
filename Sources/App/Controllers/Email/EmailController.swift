//
//  EmailController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import Foundation
import HTTP
import SMTP
import SendGridProvider

public class EmailController {
	private let apiKey: String
	
	/**
	Initializer for us to setup
   - parameters: config - Configuration files to setup our email provider
	**/
	public init(config: Config) throws {
		self.apiKey = try config.get("apiKey")
	}
	
	/**
	Sends a verification email based on the parameters given
	- parameters: to - Sends it to the person
	- parameters: code - The token from the registration process
	**/
	public func sendVerificationEmail(to user: User, code: Int) throws {
		//: Generate the Email Message Format
		let verifyTemplate = HTMLTemplate.verification(user: user, code: code)
    
    //: Generate The Email
    if let droplet = droplet {
      let body = EmailBody(type: .html, content: try verifyTemplate.makeMessage())
      let email = Email(from: serverEmail, to: user.email, subject: verifyTemplate.subject, body: body)
      try droplet.mail.send(email)
    }
	}
	
	/**
	Sends a confirmation email based on the parameters given
	- parameters: to - Sends it to the person
	**/
	public func sendConfirmationEmail(to user: User) throws {
		//: Generate the Email Message Format
		let confirmTemplate = HTMLTemplate.confirmation(user: user)
		
		//: Generate the Email
    if let droplet = droplet {
      let body = EmailBody(type: .html, content: try confirmTemplate.makeMessage())
      let email = Email(from: serverEmail, to: user.email, subject: confirmTemplate.subject, body: body)
      try droplet.mail.send(email)
    }
	}
	
	/**
	Sends an invitaion email based on the parameters given
	- parameters: from - From the user
	- parameters: to - Sends it to the person
	**/
	public func sendInvitationEmail(from: User, to user: User, meetup: String) throws {
		//: Generate the Email Message Format
		let inviteTemplate = HTMLTemplate.invite(from: from, to: user, meetup: meetup)
    
    //: Generate the email
    if let droplet = droplet {
      let body = EmailBody(type: .html, content: try inviteTemplate.makeMessage())
      let email = Email(from: serverEmail, to: user.email, subject: inviteTemplate.subject, body: body)
      try droplet.mail.send(email)
    }
	}
	
	/**
	Sends an accepted invitaion email based on the parameters given
	- parameters: From - From the user
	- parameters: to - Sends it to the person
	- parameters: meetup - the meetup that they've accepted
	**/
	public func sendAcceptedInvitationEmail(from: User, to user: User, meetup: String) throws {
		//: Generate the Email Message Format
		let acceptTemplate = HTMLTemplate.acceptInvite(from: from, to: user, meetup: meetup)
    
    //: Generate the email
    if let droplet = droplet {
      let body = EmailBody(type: .html, content: try acceptTemplate.makeMessage())
      let email = Email(from: serverEmail, to: user.email, subject: acceptTemplate.subject, body: body)
      try droplet.mail.send(email)
    }
	}
	
	/**
	Sends a friend request email based on the parameters given
	- parameters: From - From the user
	- parameters: to - Sends it to the person
	**/
	public func sendFriendRequestEmail(from: User, to user: User) throws {
		//: Generate the Email Message Format
		let friendRequestTemplate = HTMLTemplate.friendRequest(from: from, to: user)
		
    //: Generate the email
    if let droplet = droplet {
      let body = EmailBody(type: .html, content: try friendRequestTemplate.makeMessage())
      let email = Email(from: serverEmail, to: user.email, subject: friendRequestTemplate.subject, body: body)
      try droplet.mail.send(email)
    }
	}

	/**
	Sends an invitaion email based on the parameters given
	- Parameters: From - From the user
	- Parameters: to - Sends it to the person
	**/
	public func sendAcceptedFriendRequestEmail(from: User, to user: User) throws {
		//: Generate the Email Message Format
		let acceptFriendTemplate = HTMLTemplate.acceptFriend(from: from, to: user)
		
    //: Generate the email
    if let droplet = droplet {
      let body = EmailBody(type: .html, content: try acceptFriendTemplate.makeMessage())
      let email = Email(from: serverEmail, to: user.email, subject: acceptFriendTemplate.subject, body: body)
      try droplet.mail.send(email)
    }
	}
}
