//
//  CreateUser.swift
//  
//  Created by Mitchell Sweet on 10/12/20.
//

import Fluent

struct CreateUser: Migration {
    let SCHEMA_NAME = "users"
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SCHEMA_NAME)
            .id()
            .field("auth_token", .string)
            .field("username", .string, .required)
            .field("password", .string, .required)
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SCHEMA_NAME).delete()
    }
}
