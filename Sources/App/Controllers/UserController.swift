//
//  UserController.swift
//  FreshPlanAPIPackageDescription
//
//  Created by David Lin on 2017-10-08.
//

//import Foundation
import Vapor
import HTTP

public final class UserController {
    public func addRoutes(_ builder: RouteBuilder) {
        builder.grouped(TokenMiddleware()).get("user", handler: getAllUsers)
        builder.grouped(TokenMiddleware()).get("user", ":userId", handler: getUser)
        builder.grouped(TokenMiddleware()).get("user", ":userId", handler: updateUser)
        
    }
    
    // get all the users
    public func getAllUsers(request: Request) throws -> ResponseRepresentable{
        let users = try User.all()
        return try users.makeJSON()
    }
    
    // get user by the id
    public func getUser(request: Request) throws -> ResponseRepresentable {
        guard let userId = request.parameters["userId"]?.int else {
            throw Abort.badRequest
        }
        guard let user = try User.makeQuery().filter("userId", userId).first() else {
            throw Abort.notFound
        }
        
        return try user.makeJSON()
    }
    
    // update user
    public func updateUser(request: Request) throws -> ResponseRepresentable {
        guard let userId = request.parameters["userId"]?.int else {
            throw Abort.badRequest
        }
        guard let user = try User.makeQuery().filter("userId", userId).first() else {
            throw Abort.notFound
        }
        
        user.firstName = request.json?["firstName"]?.string ?? user.firstName
        user.lastName = request.json?["lastName"]?.string ?? user.lastName
        user.displayName = request.json?["displayName"]?.string ?? user.displayName
        user.email = request.json?["email"]?.string ?? user.email
        
        return JSON([:])
    }
}
