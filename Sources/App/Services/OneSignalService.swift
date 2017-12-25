// Created by Johnny Nguyen

import Vapor
import HTTP

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
   Sends a notification right now
   - parameters:
     - invitee: User - The user that is getting the notification
     - content: String - the message of the notification
  **/
  public func sendInvitedNotification(invitee: User, content: String) throws {
    guard let deviceToken = invitee.deviceToken else {
      throw Abort(.notFound, reason: "User must have a device token to receive a notification!")
    }
    // set up URL
    let url = "\(baseUrl)/notifications"
    // set up the content JSON
    var content = JSON()
    try content.set("en", content)
    
    // set up our JSON values
    var json = JSON()
    try json.set("app_id", appId)
    try json.set("include_player_ids", [deviceToken])
    try json.set("contents", content.makeJSON())
    
    // set up the headers
    let headers: [HeaderKey: String] = [
      .contentType: "application/json",
      .authorization: "Basic \(apiKey)"
    ]
    
    let request = Request(method: .post, uri: url, headers: headers, body: json.makeBody())
    
    try EngineClient.factory.respond(to: request)
  }
}
