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

  public func updateFriend(_ request: Request, friend: Friend) throws -> ResponseRepresentable {
    guard friend.userId.int == request.headers["userId"]?.int else {
      throw Abort(.forbidden, reason: "You cannot edit someones friend request!")
    }
    
    friend.accepted = request.json?["accepted"]?.bool ?? friend.accepted
    
    if friend.accepted {
      guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
      let emailController = try EmailController(config: config)
      
      guard let user = try friend.user.get(), let friendOfUser = try friend.friend.get() else {
        throw Abort.notFound
      }
      
      try emailController.sendAcceptedFriendRequestEmail(from: user, to: friendOfUser)
    }
    
    try friend.save()
    
    return Response(status: .ok)
  }
  
  public func removeFriend(_ request: Request, friend: Friend) throws -> ResponseRepresentable {
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
    
    let friend = Friend(userId: Identifier(userId), friendsId: Identifier(friendId))
    try friend.save()
    
    guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
    let emailController = try EmailController(config: config)
    
    guard let user = try friend.user.get(), let friendOfUser = try friend.friend.get() else { throw Abort.notFound }
    
    try emailController.sendFriendRequestEmail(from: user, to: friendOfUser)
    
    return Response(status: .ok)
  }
  
  public func getFriend(_ request: Request, friend: Friend) throws -> ResponseRepresentable {
    return try friend.makeJSON()
  }
  
  public func getAllFriends(request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int else {
      throw Abort.badRequest
    }
    
    let friends = try Friend.makeQuery().filter("userId", userId).all()
    
    return try friends.makeJSON()
  }
  
  public func makeResource() -> Resource<Friend> {
    return Resource(
      index: getAllFriends,
      store: addFriend,
      show: getFriend,
      update: updateFriend,
      destroy: removeFriend
    )
  }
}
