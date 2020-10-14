import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "Todo Vapor server is running..."
    }
    
    app.post("login") { req -> EventLoopFuture<AuthenticatedUser> in
        guard req.headers["Content-Type"].contains("application/json"), let jsonData = req.body.string?.data(using: .utf8) else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.incorrectUserData))
        }
        let signInReq: SigninRequest = try JSONDecoder().decode(SigninRequest.self, from: jsonData)
        
        
        return User.query(on: req.db)
            .filter(\.$username == signInReq.username)
            .first()
            .unwrap(or: Abort(.notFound, reason: ErrorMessages.userNotFound))
            .flatMap { userObj in
                
                guard try! req.password.verify(signInReq.password, created: userObj.password) == true else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.incorrectPassword))
                }
                let token = String().token()
                userObj.authToken = token
                return userObj.save(on: req.db).map {
                    return AuthenticatedUser(id: userObj.id!, authToken: userObj.authToken!, username: userObj.username)
                }
            }
    }
    
    app.post("signup") { req -> EventLoopFuture<HTTPStatus> in
        guard req.headers["Content-Type"].contains("application/json"), let jsonData = req.body.string?.data(using: .utf8) else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.incorrectUserData))
        }
        let signInReq: SigninRequest = try JSONDecoder().decode(SigninRequest.self, from: jsonData)
        let passHash = try req.password.hash(signInReq.password)
        
        return User(username: signInReq.username.lowercased(), password: passHash)
            .create(on: req.db)
            .transform(to: .created)
    }
    
    app.post("logout") { req -> EventLoopFuture<HTTPStatus> in
        guard let authToken = req.headers["authToken"].first else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.authTokenRequired))
        }
        
        return User.query(on: req.db)
            .filter(\.$authToken == authToken)
            .first()
            .unwrap(or: Abort(.badRequest, reason: "Auth token is not valid"))
            .flatMap { userObj in
                userObj.authToken = nil
                return userObj.save(on: req.db)
                    .transform(to: .ok)
            }
    }
    
    app.post("task") { req -> EventLoopFuture<HTTPStatus> in
        guard req.headers["Content-Type"].contains("application/json"), let jsonData = req.body.string?.data(using: .utf8) else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.taskDataMissing))
        }
        guard let authToken = req.headers["authToken"].first else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.authTokenRequired))
        }
        
        let newTaskRequest: NewTaskRequest = try JSONDecoder().decode(NewTaskRequest.self, from: jsonData)
        
        return User.query(on: req.db)
            .filter(\.$authToken == authToken)
            .first()
            .unwrap(or: Abort(.badRequest, reason: ErrorMessages.invalidAuthToken))
            .flatMap { userObj in
                return Task(creatorID: userObj.id!, text: newTaskRequest.text)
                    .create(on: req.db)
                    .transform(to: .created)
            }
    }
    
    app.get("tasks") { req -> EventLoopFuture<[Task]> in
        guard let authToken = req.headers["authToken"].first else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.authTokenRequired))
        }
        
        return User.query(on: req.db)
            .filter(\.$authToken == authToken)
            .first()
            .unwrap(or: Abort(.badRequest, reason: "Auth token is not valid"))
            .flatMap { userObj in
                return Task.query(on: req.db)
                    .filter(\.$creator.$id == userObj.id!)
                    .all()
            }
    }
    
    
    app.put("task") { req -> EventLoopFuture<HTTPStatus> in
        guard req.headers["Content-Type"].contains("application/json"), let jsonData = req.body.string?.data(using: .utf8) else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.taskDataMissing))
        }
        guard let authToken = req.headers["authToken"].first else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.authTokenRequired))
        }
        
        let updateTaskRequest: UpdateTaskRequest = try JSONDecoder().decode(UpdateTaskRequest.self, from: jsonData)
        
        return User.query(on: req.db)
            .filter(\.$authToken == authToken)
            .first()
            .unwrap(or: Abort(.badRequest, reason: ErrorMessages.invalidAuthToken))
            .flatMap { userObj in
                return Task.find(updateTaskRequest.taskId, on: req.db)
                    .flatMap { taskToUpdate in
                        guard let task = taskToUpdate, task.$creator.id == userObj.id else {
                            return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: ErrorMessages.taskNotFound))
                        }
                        task.completed = updateTaskRequest.completed
                        return task.save(on: req.db)
                            .transform(to: .ok)
                    }
            }
    }
    
    app.delete("task") { req -> EventLoopFuture<HTTPStatus> in
        guard req.headers["Content-Type"].contains("application/json"), let jsonData = req.body.string?.data(using: .utf8) else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.taskDataMissing))
        }
        guard let authToken = req.headers["authToken"].first else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ErrorMessages.authTokenRequired))
        }
        
        let deleteTaskRequest: DeleteTaskRequest = try JSONDecoder().decode(DeleteTaskRequest.self, from: jsonData)
        
        return User.query(on: req.db)
            .filter(\.$authToken == authToken)
            .first()
            .unwrap(or: Abort(.badRequest, reason: ErrorMessages.invalidAuthToken))
            .flatMap { userObj in
                return Task.find(deleteTaskRequest.taskId, on: req.db)
                    .unwrap(or: Abort(.notFound, reason: ErrorMessages.taskNotFound))
                    .flatMap { $0.delete(on: req.db) }
                    .transform(to: .ok)
            }
    }
}
