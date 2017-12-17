//
//  MeetupController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-10-06.
//

import Vapor
import HTTP

public final class MeetupController: ResourceRepresentable, EmptyInitializable {
  public init() { }
  
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
    
    return Response(status: .ok)
  }
  
  // Gets all the meetups, based on you, the user
  public func getAllMeetups(request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    // once we get userId, we'll find all the ties between meetup
    var meetups = try Meetup.makeQuery().filter("userId", userId).all()
    
    // gets all the meetups from invited
    let invitedMeetups = try Invitation.makeQuery().filter("inviteeId", userId).all().map { invited in
      return try invited.meetup.get()
    }.flatMap { $0 }
    
    meetups.append(contentsOf: invitedMeetups)
    
    return try meetups.makeJSON()
  }
  
  // get meetup based on the id
  public func getMeetup(_ request: Request, meetup: Meetup) throws -> ResponseRepresentable {
    return try meetup.makeJSON()
  }
  
  public func updateMeetup(_ request: Request, meetup: Meetup) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard userId == meetup.userId.int else {
      throw Abort(.conflict, reason: "You can't edit someone's meetup!")
    }
    
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
    
    return Response(status: .ok)
  }
  
  public func deleteMeetup(_ request: Request, meetup: Meetup) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard userId == meetup.userId.int else {
      throw Abort(.conflict, reason: "You can't delete someone's meetup!")
    }
    
    try meetup.delete()
    return Response(status: .ok)
  }
  
  public func makeResource() -> Resource<Meetup> {
    return Resource(
      index: getAllMeetups,
      store: createMeetup,
      show: getMeetup,
      update: updateMeetup,
      destroy: deleteMeetup
    )
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
