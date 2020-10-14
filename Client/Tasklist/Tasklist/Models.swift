//
//  Models.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/7/20.
//

import Foundation

struct User: Codable {
    let id: Int
    let username: String
}

struct Task: Codable {
    let id: UUID
    let text: String
    let completed: Bool
}

// MARK: Requests
struct SigninRequest: Codable {
    let username: String
    let password: String
}

struct NewTaskRequest: Codable{
    let text: String
}

struct UpdateTaskRequest: Codable {
    let taskId: UUID
    let completed: Bool
}

struct DeleteTaskRequest: Codable {
    let taskId: UUID
}

// MARK: Responses
struct LoginResponse: Codable {
    let id: UUID
    let authToken: String
    let username: String
}

