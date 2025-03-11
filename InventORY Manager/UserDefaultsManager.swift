//
//  UserDefaultsManager.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import Foundation

class UserDefaultsManager {
    @MainActor static let shared = UserDefaultsManager() // Синглтон

    private let userDefaults = UserDefaults.standard
    
    private let userIdentifierKey = "userIdentifier"
    private let userLoginKey = "userLogin"
    private let userPasswordKey = "userPassword"
    private let userAccessLevelKey = "userAccessLevel"
    private let userName = "userName"

    func saveUserData(identifier: String, login: String, password: String, name: String, accessLevel: Int8) {
        userDefaults.set(identifier, forKey: userIdentifierKey)
        userDefaults.set(login, forKey: userLoginKey)
        userDefaults.set(password, forKey: userPasswordKey)
        userDefaults.set(name, forKey: userName)
        userDefaults.set(accessLevel, forKey: userAccessLevelKey)
        
        let savedMessage = """
        values saved:
        "identifier: \(identifier)")
        "login: \(login)")
        "password: \(password)")
        "name: \(name)")
        "accessLevel: \(accessLevel)")
        """
        print(savedMessage)
    }

    func loadUserData() -> [String: String] {
        var defaultsToExport: [String: String] = [:]

        if let identifier = userDefaults.string(forKey: userIdentifierKey) {
            defaultsToExport["identifier"] = identifier
        }
        if let login = userDefaults.string(forKey: userLoginKey) {
            defaultsToExport["login"] = login
        }
        if let password = userDefaults.string(forKey: userPasswordKey) {
            defaultsToExport["password"] = password
        }
        if let name = userDefaults.string(forKey: userName) {
            defaultsToExport["name"] = name
        }
        if let accessLevel = userDefaults.string(forKey: userAccessLevelKey) {
            defaultsToExport["accessLevel"] = accessLevel
        }

        print("values load:")
        print(defaultsToExport)

        return defaultsToExport
    }

    func clearUserData() {
        userDefaults.removeObject(forKey: userIdentifierKey)
        userDefaults.removeObject(forKey: userLoginKey)
        userDefaults.removeObject(forKey: userPasswordKey)
        userDefaults.removeObject(forKey: userAccessLevelKey)
        userDefaults.removeObject(forKey: userName)
    }

    func isUserLoggedIn() -> Bool {
        return userDefaults.string(forKey: userIdentifierKey) != nil
    }
}
