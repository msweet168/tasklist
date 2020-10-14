//
//  API.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/7/20.
//

import Foundation

class API {
    public static let shared = API()
    
    // MARK: Constants
    private let apiAddress = "http://localhost:8080"
    private let SIGNUP_ROUTE = "/signup"
    private let LOGIN_ROUTE = "/login"
    private let LOGOUT_ROUTE = "/logout"
    private let TASK_ROUTE = "/task"
    private let TASKS_ROUTE = "/tasks"
    
    private enum RequestType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: Utility Functions
    
    // TODO: These are a bit redundent, maybe try to make a single function that takes a parameter for a user default key.
    private func getAuthToken() -> String? {
        return UserDefaults.standard.value(forKey: Keys.authTokenKey) as? String
    }
    
    private func updateAuthToken(token: String?) {
        UserDefaults.standard.setValue(token, forKey: Keys.authTokenKey)
    }
    
    public func getUsername() -> String? {
        return UserDefaults.standard.value(forKey: Keys.usernameKey) as? String
    }
    
    private func updateUsername(username: String?) {
        UserDefaults.standard.setValue(username, forKey: Keys.usernameKey)
    }
    
    public func isLoggedIn() -> Bool {
        return getAuthToken() != nil
    }
    
    // MARK: REST Functions
    private func httpRequest(url: URL, requestType: RequestType, body: String, authToken: String? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken = authToken { request.setValue(authToken, forHTTPHeaderField: "authToken") }
        request.httpBody = body.data(using: .utf8)
        request.timeoutInterval = 20
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, response, error)
            }
        }.resume()
    }
    
    
    // MARK: API Functions
    func signUp(username: String, password: String, completion: @escaping (Bool) -> Void) {
        print("Signup request...")
        let signInRequest = SigninRequest(username: username, password: password)
        do {
            let jsonString = String(data: try JSONEncoder().encode(signInRequest), encoding: .utf8)
            let unsafeUrl = URL(string: apiAddress + SIGNUP_ROUTE)
            guard let url = unsafeUrl, let body = jsonString else {
                completion(false)
                return
            }
            
            httpRequest(url: url, requestType: .post, body: body) { (_, response, error) in
                guard let response = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }
                
                if response.statusCode == 201 {
                    completion(true)
                } else {
                    print("ERROR Creating user: \(error?.localizedDescription ?? "N/A")")
                    completion(false)
                }
            }
        } catch {
            print("ERROR Caught when creating user: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        print("Login request...")
        let loginRequest = SigninRequest(username: username, password: password)
        do {
            let jsonString = String(data: try JSONEncoder().encode(loginRequest), encoding: .utf8)
            let unsafeUrl = URL(string: apiAddress + LOGIN_ROUTE)
            guard let url = unsafeUrl, let body = jsonString else {
                completion(false)
                return
            }
            
            httpRequest(url: url, requestType: .post, body: body) { (data, response, error) in
                guard let response = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }
                guard response.statusCode == 200 else {
                    print("ERROR Logging in: Code: \(response.statusCode) Error: \(error?.localizedDescription ?? "N/A")")
                    completion(false)
                    return
                }
                guard let userData = data else {
                    print("ERROR Logging in: \(error?.localizedDescription ?? "N/A")")
                    completion(false)
                    return
                }
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: userData)
                    self.updateAuthToken(token: loginResponse.authToken)
                    self.updateUsername(username: loginResponse.username)
                    completion(true)
                } catch {
                    print("ERROR Caught when parsing response data: \(error.localizedDescription)")
                    completion(false)
                }
            }
        } catch {
            print("ERROR Caught when logging in: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func logOut(completion: @escaping (Bool) -> Void) {
        print("Logout request...")
        let unsafeUrl = URL(string: apiAddress + LOGOUT_ROUTE)
        guard let url = unsafeUrl, let token = getAuthToken() else {
            completion(false)
            return
        }
        
        httpRequest(url: url, requestType: .post, body: "", authToken: token) { (_, response, _) in
            guard let response = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            if response.statusCode == 200 {
                self.updateAuthToken(token: nil)
                self.updateUsername(username: nil)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getTasks(completion: @escaping ([Task]?) -> Void) {
        print("Get tasks request...")
        let unsafeUrl = URL(string: apiAddress + TASKS_ROUTE)
        guard let url = unsafeUrl, let token = getAuthToken() else {
            completion(nil)
            return
        }
        
        httpRequest(url: url, requestType: .get, body: "", authToken: token) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                completion(nil)
                return
            }
            guard response.statusCode == 200 else {
                print("ERROR Getting tasks: \(error?.localizedDescription ?? "N/A")")
                completion(nil)
                return
            }
            guard let taskData = data else {
                print("ERROR Getting tasks: \(error?.localizedDescription ?? "N/A")")
                completion(nil)
                return
            }
            do {
                let tasks = try JSONDecoder().decode([Task].self, from: taskData)
                completion(tasks)
            } catch {
                print("ERROR Caught when parsing tasks: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // TODO: The following API functions are very repetitive, a function can probably be made to abstract most of the logic.
    func addTask(taskText: String, completion: @escaping (Bool) -> Void) {
        print("Add task request...")
        let newTaskRequest = NewTaskRequest(text: taskText)
        do {
            let jsonString = String(data: try JSONEncoder().encode(newTaskRequest), encoding: .utf8)
            let unsafeUrl = URL(string: apiAddress + TASK_ROUTE)
            guard let url = unsafeUrl, let token = getAuthToken(), let body = jsonString else {
                completion(false)
                return
            }
            httpRequest(url: url, requestType: .post, body: body, authToken: token) { (_, response, _) in
                guard let response = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }
                if response.statusCode == 201 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } catch {
            print("ERROR Caught when adding task: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func deleteTask(task: Task, completion: @escaping (Bool) -> Void) {
        print("Delete task request...")
        let deleteTaskRequest = DeleteTaskRequest(taskId: task.id)
        do {
            let jsonString = String(data: try JSONEncoder().encode(deleteTaskRequest), encoding: .utf8)
            let unsafeUrl = URL(string: apiAddress + TASK_ROUTE)
            guard let url = unsafeUrl, let token = getAuthToken(), let body = jsonString else {
                completion(false)
                return
            }
            httpRequest(url: url, requestType: .delete, body: body, authToken: token) { (_, response, _) in
                guard let response = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }
                if response.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } catch {
            print("ERROR Caught when adding task: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func toggleTaskCompletion(task: Task, completion: @escaping (Bool) -> Void) {
        print("Update task request...")
        let updateTaskRequest = UpdateTaskRequest(taskId: task.id, completed: !task.completed)
        do {
            let jsonString = String(data: try JSONEncoder().encode(updateTaskRequest), encoding: .utf8)
            let unsafeUrl = URL(string: apiAddress + TASK_ROUTE)
            guard let url = unsafeUrl, let token = getAuthToken(), let body = jsonString else {
                completion(false)
                return
            }
            httpRequest(url: url, requestType: .put, body: body, authToken: token) { (_, response, _) in
                guard let response = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }
                if response.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } catch {
            print("ERROR Caught when updating task: \(error.localizedDescription)")
            completion(false)
        }
    }
}
