//
//  CreateTask.swift
//  
//  Created by Mitchell Sweet on 10/12/20.
//

import Fluent

struct CreateTask: Migration {
    let SCHEMA_NAME = "tasks"
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SCHEMA_NAME)
            .id()
            .field("creator_id", .uuid, .references("users", "id"))
            .field("text", .string, .required)
            .field("completed", .bool, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SCHEMA_NAME).delete()
    }
}
