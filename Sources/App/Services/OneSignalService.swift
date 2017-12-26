// Created by Johnny Nguyen

import Vapor
import HTTP

/**
 OneSignalService - Designed to send out notifications to devices
**/
public final class OneSignalService {
  private let apiKey: String
  private let appId: String
  
  private let baseUrl: String = "https://onesignal.com/api/v1"
  private let allUsers: [String] = ["All"]
  
  public init(apiKey: String, appId: String) {
    self.apiKey = apiKey
    self.appId = appId
  }
  
  public convenience init(config: Config) throws {
    self.init(
      apiKey: try config.get("apiKey"),
      appId: try config.get("appId")
    )
  }
  
  /**
   Sends out a notification
   - parameters:
     - invitee: User - The user that is getting the notification
     - content: String - the message of the notification
  **/
  public func sendNotification(user: User, content: String) throws -> Response {
    // set up URL
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var content = JSON()
    try content.set("en", content)
    // set up our JSON valuese
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [user.deviceToken ?? ""])
    try json.set("contents", content.makeJSON())
    // set up the headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())

    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json {
      let notification = try NotificationManager(json: responseJSON)
      try notification.save()
    }
    
    return Response(status: .ok)
  }
  
  /**
   Sends a notification to the person who requested to become friends with that user
   - parameters:
     - user: User - A list of users we want to send the notification to
     - content: String - The content of which the information
  **/
  public func sendBatchNotifications(users: [User], content: String) throws -> Response {
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var content = JSON()
    try content.set("en", content)
    // set up our JSON Values
    // set a variable for map users
    let deviceTokens: [String] = users.map { $0.deviceToken ?? "" }
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", deviceTokens)
    try json.set("contents", content.makeJSON())
    // set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // setup the request
    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json {
      let notification = try NotificationManager(json: responseJSON)
      try notification.save()
    }
    
    return Response(status: .ok)
  }
  
  /**
   Sends a scheduled meetup notification
   - parameters:
     - user: User - `User` object for who we're sending the notification to
     - date: Date - `Date` object of the date when it's being delivered
     - content: String - The content information of what to talk about
   **/
  public func sendScheduledNotification(user: User, date: Date, content: String) throws -> Response {
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var content = JSON()
    try content.set("en", content)
    // set up our JSON Values
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [user.deviceToken ?? ""])
    try json.set("send_after", date.dateString)
    try json.set("contents", content.makeJSON())
    // set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    // setup the request
    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json {
      let notification = try NotificationManager(json: responseJSON)
      try notification.save()
    }
    
    return Response(status: .ok)
  }
  
  /**
   Sends a batched scheduled meetup notification
   - parameters:
   - user: User - `User` object for who we're sending the notification to
   - date: Date - `Date` object of the date when it's being delivered
   - content: String - The content information of what to talk about
   **/
  public func sendBatchedScheduledNotification(users: [User], date: Date, content: String) throws -> Response {
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var content = JSON()
    try content.set("en", content)
    // set up our JSON Values
    // set a variable for map users
    let deviceTokens: [String] = users.map { $0.deviceToken ?? "" }
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", deviceTokens)
    try json.set("send_after", date.dateString)
    try json.set("contents", content.makeJSON())
    // set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json {
      let notification = try NotificationManager(json: responseJSON)
      try notification.save()
    }
    
    return Response(status: .ok)
  }
}
