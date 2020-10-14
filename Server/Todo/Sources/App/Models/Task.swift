//
//  Task.swift
//
//  Created by Mitchell Sweet on 10/12/20.
//

import Fluent
import Vapor

final class Task: Model, Content {
    static let schema = "tasks"
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "creator_id") var creator: User
    @Field(key: "text") var text: String
    @Field(key: "completed") var completed: Bool
    
    init() { }
    
    init(id: UUID? = nil, creatorID: UUID, text: String, completed: Bool = false) {
        self.id = id
        self.$creator.id = creatorID
        self.text = text
        self.completed = completed
    }
}
