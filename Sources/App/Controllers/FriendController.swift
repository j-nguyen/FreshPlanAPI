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
      // we want to add two rows to make sure they've been added
      let acceptedFriend = Friend(userId: friend.requestedId, friendId: friend.requesterId)
      let acceptedFriendOfUser = Friend(userId: friend.requesterId, friendId: friend.requestedId)
      
      try acceptedFriend.save()
      try acceptedFriendOfUser.save()
      
      // config
      guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
      guard let onesignal = droplet?.config["onesignal"] else { throw Abort.notFound }
      let emailController = try EmailController(config: config)
      let notificationService = try OneSignalService(config: onesignal)
      
      guard let user = try friend.requester.get(), let friendOfUser = try friend.requested.get() else {
        throw Abort.notFound
      }
      
      try emailController.sendAcceptedFriendRequestEmail(from: friendOfUser, to: user)
      try notificationService.sendNotification(user: user, content: "\(friendOfUser.displayName) has accepted your friend request!", type: .friend, typeId: acceptedFriendOfUser.id!.int!)
    }
    // we need to delete this because it doesn't matter for the request
    try friend.delete()
    
    return Response(status: .ok)
  }
  
  public func removeFriend(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int,
          let friendId = request.parameters["friendId"]?.int  else {
        throw Abort.badRequest
    }
    
    // get the friend, and the friend owner
    guard
      let friend = try Friend.makeQuery().filter("friendId", friendId).and({ try $0.filter("userId", userId) }).first(),
      let userFriend = try Friend.makeQuery().filter("friendId", userId).and({ try $0.filter("userId", friendId) }).first() else {
      throw Abort.notFound
    }
    
    guard userId == request.headers["userId"]?.int else {
      throw Abort(.forbidden, reason: "You must be the user to be able to remove friends")
    }
    
    // we need to delete both since they're bi directional
    try friend.delete()
    try userFriend.delete()
    
    return Response(status: .ok)
  }
  
  public func getFriendRequests(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.parameters["userId"]?.int else {
      throw Abort.badRequest
    }
    
    return try FriendRequest.makeQuery().filter("requestedId", userId).all().makeJSON()
  }
  
  public func getFriendRequest(_ request: Request) throws -> ResponseRepresentable {
    guard
      let userId = request.parameters["userId"]?.int,
      let friendId = request.parameters["friendId"]?.int else {
        throw Abort.badRequest
    }
    
    guard let friendRequest = try FriendRequest.makeQuery().filter("requestedId", userId)
      .and({ try $0.filter("requesterId", friendId) }).first() else {
        throw Abort.notFound
    }
    
    return try friendRequest.makeJSON()
  }
  
  public func addFriend(_ request: Request) throws -> ResponseRepresentable {
    guard let userId = request.headers["userId"]?.int else {
      throw Abort.badRequest
    }
    
    guard let friendId = request.json?["friendId"]?.int else {
      throw Abort.notFound
    }
    
    guard userId != friendId else {
      throw Abort(.conflict, reason: "You can't send a friend request to yourself!")
    }
    
    let friend = FriendRequest(requesterId: Identifier(userId), requestedId: Identifier(friendId))
    try friend.save()
    
    guard let config = droplet?.config["sendgrid"] else { throw Abort.notFound }
    guard let onesignal = droplet?.config["onesignal"] else { throw Abort.notFound }
    
    let emailController = try EmailController(config: config)
    let notificationService = try OneSignalService(config: onesignal)
    
    guard let user = try friend.requester.get(), let friendOfUser = try friend.requested.get() else { throw Abort.notFound }
    
    try emailController.sendFriendRequestEmail(from: user, to: friendOfUser)
    try notificationService.sendNotification(
      user: friendOfUser,
      content: "\(user.displayName) has sent a you friend request!",
      type: .friend,
      typeId: friend.id!.int!
    )
    
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
      index: getAllFriends,
      store: addFriend
    )
  }
}
