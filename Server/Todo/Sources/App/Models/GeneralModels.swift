//
//  GeneralModels.swift
//
//  Created by Mitchell Sweet on 10/12/20.
//

import Foundation
import Fluent
import Vapor

struct AuthenticatedUser: Content {
    var id: UUID
    var authToken: String
    var username: String
}

// MARK: Requests / Responses
struct SigninRequest: Content {
    let username: String
    let password: String
}

struct NewTaskRequest: Content {
    let text: String
}

struct UpdateTaskRequest: Content {
    let taskId: UUID
    let completed: Bool
}

struct DeleteTaskRequest: Content {
    let taskId: UUID
}
