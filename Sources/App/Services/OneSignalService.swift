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
  public func sendNotification(user: User, content: String, type: NotificationManager.Notification, typeId: Int) throws {
    // set up URL
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var message = JSON()
    try message.set("en", content)
    // set up our JSON valuese
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [user.deviceToken ?? ""])
    try json.set("contents", message.makeJSON())
    // set up the headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())

    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json, response.status.statusCode >= 200 && response.status.statusCode <= 299 {
      let uuid: String = try responseJSON.get("id")
      let notification = NotificationManager(uuid: uuid, type: type.rawValue, typeId: typeId)
      try notification.save()
    }
  }
  
  /**
   Sends a notification to the person who requested to become friends with that user
   - parameters:
     - user: User - A list of users we want to send the notification to
     - content: String - The content of which the information
  **/
  public func sendBatchNotifications(users: [User], content: String, type: NotificationManager.Notification, typeId: Int) throws {
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var message = JSON()
    try message.set("en", content)
    // set up our JSON Values
    // set a variable for map users
    let deviceTokens: [String] = users.map { $0.deviceToken ?? "" }
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", deviceTokens)
    try json.set("contents", message.makeJSON())
    // set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    // setup the request
    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json, response.status.statusCode >= 200 && response.status.statusCode <= 299 {
      let uuid: String = try responseJSON.get("id")
      let notification = NotificationManager(uuid: uuid, type: type.rawValue, typeId: typeId)
      try notification.save()
    }
  }
  
  /**
   Sends a scheduled meetup notification
   - parameters:
     - user: User - `User` object for who we're sending the notification to
     - date: Date - `Date` object of the date when it's being delivered
     - content: String - The content information of what to talk about
   **/
  public func sendScheduledNotification(user: User, date: Date, content: String, type: NotificationManager.Notification, typeId: Int) throws {
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var message = JSON()
    try message.set("en", content)
    // set up our JSON Values
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [user.deviceToken ?? ""])
    try json.set("send_after", date.dateString)
    try json.set("contents", message.makeJSON())
    // set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    // setup the request
    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json, response.status.statusCode >= 200 && response.status.statusCode <= 299 {
      let uuid: String = try responseJSON.get("id")
      let notification = NotificationManager(uuid: uuid, type: type.rawValue, typeId: typeId)
      try notification.save()
    }
  }
  
  /**
   Sends a batched scheduled meetup notification
   - parameters:
   - user: User - `User` object for who we're sending the notification to
   - date: Date - `Date` object of the date when it's being delivered
   - content: String - The content information of what to talk about
   **/
  public func sendBatchedScheduledNotification(users: [User], date: Date, content: String, type: NotificationManager.Notification, typeId: Int) throws {
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var message = JSON()
    try message.set("en", content)
    // set up our JSON Values
    // set a variable for map users
    let deviceTokens: [String] = users.map { $0.deviceToken ?? "" }
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", deviceTokens)
    try json.set("send_after", date.dateString)
    try json.set("contents", message.makeJSON())
    // set up our headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // setup the request
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    let response = try EngineClient.factory.respond(to: request)
    
    if let responseJSON = response.json, response.status.statusCode >= 200 && response.status.statusCode <= 299 {
      let uuid: String = try responseJSON.get("id")
      let notification = NotificationManager(uuid: uuid, type: type.rawValue, typeId: typeId)
      try notification.save()
    }
  }
  
  /**
    Cancels all the notifications based on the type and typeId given
   - parameters:
     - type: The type its given
     - typeId: The Id found
  **/
  public func cancelNotification(type: NotificationManager.Notification, typeId: Int) throws {
    // create headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    // get all the notifications that we're going to cancel
    let notifications = try NotificationManager.makeQuery()
      .filter("type", type.rawValue)
      .filter("typeId", typeId)
      .all()
    
    // attempt to delete each request
    try notifications.forEach { notification in
      let url = "\(baseUrl)/notifications/\(notification.uuid)?app_id=\(appId)"
      let request = Request(method: .delete, uri: url, headers: headers)
      let response = try EngineClient.factory.respond(to: request)
      // check the response, and if it's successful, we delete
      if response.status.statusCode >= 200 && response.status.statusCode <= 299 {
        try notification.delete()
      }
    }
  }
}

extension NotificationManager {
  public enum Notification: String {
    case meetup
    case invitation
    case friend
  }
}
