//
//  FriendController.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-02.
//


import Vapor
import HTTP

public final class FriendController: EmptyInitializable, ResourceRepresentable {
  public init() { }

  public func updateFriend(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int,
          let requesterId = request.parameters["friendId"]?.int else {
        throw Abort.badRequest
    }
  
    guard let friend = try FriendRequest.makeQuery().filter("requestedId", userId)
      .and({ try $0.filter("requesterId", requesterId) }).first() else {
      throw Abort.notFound
    }
    
    guard userId == request.headers["userId"]?.int && friend.requestedId.int == userId else {
      throw Abort(.forbidden, reason: "You cannot edit someones friend request!")
    }
    
    friend.accepted = request.json?["accepted"]?.bool ?? friend.accepted
    
    if friend.accepted {
      guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
      let emailController = try EmailController(config: config)
      
      guard let user = try friend.requester.get(), let friendOfUser = try friend.requested.get() else {
        throw Abort.notFound
      }
      
      try emailController.sendAcceptedFriendRequestEmail(from: user, to: friendOfUser)
    }
    
    try friend.save()
    
    return Response(status: .ok)
  }
  
  public func removeFriend(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int,
          let requesterId = request.parameters["requesterId"]?.int  else {
        throw Abort.badRequest
    }
  
    guard let friend = try FriendRequest.makeQuery().filter("requestedId", userId)
      .and({ try $0.filter("requesterId", requesterId) }).first() else {
        throw Abort.notFound
    }
    
    guard userId == request.headers["userId"]?.int && friend.requestedId.int == userId else {
      throw Abort(.forbidden, reason: "You cannot edit someones friend request!")
    }
    
    try friend.delete()
    
    return Response(status: .ok)
  }
  
  public func addFriend(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard let friendId = request.json?["friendId"]?.int else {
      throw Abort.notFound
    }
    
    let friend = FriendRequest(userId: Identifier(userId), friendsId: Identifier(friendId))
    try friend.save()
    
    guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
    let emailController = try EmailController(config: config)
    
    guard let user = try friend.user.get(), let friendOfUser = try friend.friend.get() else { throw Abort.notFound }
    
    try emailController.sendFriendRequestEmail(from: user, to: friendOfUser)
    
    return Response(status: .ok)
  }
  
  public func getFriend(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int,
      let friendId = request.parameters["friendId"]?.int else {
        throw Abort.badRequest
    }
    
    guard let friend = try Friend.makeQuery().filter("userId", userId).and({ try $0.filter("friendId", friendId) }).first() else {
      throw Abort.notFound
    }
    
    return try friend.makeJSON()
  }
  
  public func getAllFriends(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int else {
      throw Abort.badRequest
    }

    return  try Friend.makeQuery().filter("userId", userId).all().makeJSON()
  }
  
  public func makeResource() -> Resource<FriendRequest> {
    return Resource(
      store: addFriend
    )
  }
}
