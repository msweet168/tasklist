//
//  Utilities.swift
//
//  Created by Mitchell Sweet on 10/12/20.
//

import Foundation

struct DefaultConstants {
    public static let authTokenLength = 50
    public static let tokenTrackerKey = "TOKENS"
}

struct ErrorMessages {
    public static let incorrectUserData = "Incorrect user data recieved"
    public static let userNotFound = "User not found"
    public static let incorrectPassword = "Password is incorrect"
    public static let authTokenRequired = "Auth token is required"
    public static let invalidAuthToken = "Auth token is not valid"
    public static let taskDataMissing = "Task data not recieved"
    public static let taskNotFound = "Task not found"
    public static let unknown = "An unknown error has occured"
}

extension String {
    func token(length: Int = DefaultConstants.authTokenLength) -> String {
        // FIXME: Tokens are not protected against collisions, this should be fixed in the future.
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567891234567890"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
