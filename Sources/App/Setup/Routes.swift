//
//  Routes.swift
//  App
//
//  Created by Johnny Nguyen on 2017-12-02.
//

import Vapor
import HTTP

// We can set up our routes here for easier access
extension Droplet {
  public func setupRoutes() throws {
    get("/") { req in
      throw Abort.unauthorized
    }
    
    try collection(V1Collection.self)
  }
}
