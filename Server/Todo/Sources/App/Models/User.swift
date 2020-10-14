//
//  User.swift
//
//  Created by Mitchell Sweet on 10/12/20.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "auth_token") var authToken: String?
    @Field(key: "username") var username: String
    @Field(key: "password") var password: String
    
    init() { }
    
    init(id: UUID? = nil, authToken: String? = nil, username: String, password: String) {
        self.id = id
        self.authToken = authToken
        self.username = username
        self.password = password
    }
}
