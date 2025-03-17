//
//  Server.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import Foundation

class Server {
    @MainActor static let shared = Server(login: "", password: "")
    var userIdentifier: String?
    var name: String?
    private(set) var login: String
    private(set) var password: String
    
    private let databaseManager = SupabaseManager()
    
    init(login: String = "", password: String = "") {
        self.login = login
        self.password = password
    }
    
    func register() async -> Bool {
        guard await isValidLogin(self.login) && isValidPassword(self.password) else {
            print("Некорректный логин или пароль")
            return false
        }
        
        let answ = await generateIdentifier()
        if answ.res == true {
            self.userIdentifier = answ.id
            return await databaseManager.register(id: self.userIdentifier!, login: self.login, password: self.password)
        }
        return false
    }

    func tryToLog() async -> Bool {
        if await databaseManager.login(enteredLogin: self.login, enteredPassword: self.password) {
            print("Пользователь \(login) успешно вошел!")
            return true
        } else {
            print("Неверный логин или пароль")
            return false
        }
    }

    private func generateIdentifier(table: String = "users", length: Int = 6) async -> (id: String, res: Bool) {
        let generatedIDs = await databaseManager.getAllIDs(table: table)
        
        if generatedIDs.res {
            let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ0123456789"
            let charactersArray = Array(characters)

            while true {
                let newID = (0..<length).map { _ in
                    charactersArray.randomElement()!
                }.reduce("", { String($0) + String($1) })

                if !generatedIDs.set.contains(newID) {
                    self.userIdentifier = newID
                    return (newID, true)
                }
            }
        } else { return ("", false) }
    }

    private func isValidLogin(_ login: String) async -> Bool {
        if await databaseManager.isLoginExists(login: login){
            return login.count >= 6
        } else { return false }
    }

    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    //MARK: STORAGE OPERATIONS
    func getStorageData() async -> (dataExtracted: [[String: String]], res: Bool) {
        let answ = await databaseManager.fetchStorageItems()
        
        if answ.res {
            var storageData: [[String: String]] = []
            for item in answ.dataExtracted {
                storageData.append([
                    "category": item.category,
                    "articul": item.articul,
                    "name": item.name,
                    "quantity": String(item.quantity),
                    "whoBought": item.whoBought,
                    "buyerName": item.users?.name ?? "Unknown",
                    "dateOfBuy": item.dateOfBuy,
                    "fullyIdentified": String(item.fullyIdentified)
                ])
            }
            return (storageData, true)
        }
            
        return ([], false)
    }
    
    func addToStorage(caregory: String, name: String, cost: String, quantity: String) async -> (insertedArticul: String, res: Bool) {
        let gettingId = await generateIdentifier(table: "shopItems", length: 4)
        if gettingId.res {
            let answ = await databaseManager.addStoreItem(articul: gettingId.id, category: caregory, name: name, cost: cost)
            if answ.res {
                if await databaseManager.buyItemFromStore(articul: answ.art, quantity: quantity) {
                    return (answ.art, true)
                }
            }
        }
        return ("", false)
    }
    
    func deleteFromStorage(articul: String) async -> Bool {
        return await databaseManager.deleteStorageItem(articul: articul)
    }
    
    func fetchStorageLocations(column: String = "ItemArticul", value: String) async -> (locations: [LocationItem], res: Bool) {
        let answ = await databaseManager.fetchLocations(col: column, value: value)
        return answ
    }
    
    func setConditionOnLocation(rowData: LocationItem, condition: Bool, userName: String) async -> Bool {
        if await databaseManager.setConditionOnLocation(rowData: rowData, condition: condition, userName: userName) {
            return true
        }
        return false
    }
    
    func fetchCabinetNums() async -> [Cabinets] {
        do {
            return try await databaseManager.fetchCabinets()
        } catch {
            print (error)
            return []
        }
    }
    
    func locateItemInCab(art: String, cab: String, userID: String) async -> Bool {
        return await databaseManager.locateItem(articul: art, cabinet: cab, userName: userID)
    }
    
    func setAllLocatedState(articul: String) async {
        await databaseManager.setItemState(art: articul, state: "true")
    }
    
    func relocateStorageItem(rowData: LocationItem, cab: String, userID: String) async -> Bool{
        if await databaseManager.relocateItem(rowId: String(rowData.rowid), newCabinet: cab) {
            await databaseManager.newStorageChange(type: "RELOCATE",art: rowData.ItemArticul, personalName: userID)
            return true
        }
        return false
    }
    
    func buyExistingItem(art: String, quantity: String) async -> Bool {
        return await databaseManager.buyItemFromStore(articul: art, quantity: quantity)
    }
    
    
    func fetchUsersInfo() async -> (users: [[String: String]], res: Bool) {
        let answ = await databaseManager.fetchAllUsersData()
        if answ.res {
            var users: [[String: String]] = []
            for user in answ.data {
                users.append([
                    "identifier": user.identifier,
                    "name": user.name,
                    "accessLevel": String(user.level),
                    "login": user.login,
                    "password": user.password
                ])
            }
            return (users, true)
        }
        return ([], false)
    }
    
    func updateUserInfo(oldId: String, newData: [String: String]) async -> Bool {
        return await databaseManager.updateUser(oldID: oldId, newData: newData)
    }
    
    func fetchCabinetsWithInfo() async -> (dataExtracted: [[String: String]], res: Bool) {
        let answ = await databaseManager.fetchCabinetsWithInfo()
        if answ.res {
            var cabinets: [[String: String]] = []
            for cabinet in answ.dataExtracted {
                cabinets.append([
                    "cabinetNum": String(cabinet.cabinetNum),
                    "responsible": cabinet.responsible,
                    "responsibleName": cabinet.users!.name,
                    "floor": String(cabinet.floor)
                ])
            }
            return (cabinets, true)
        }
        else {
            return ([], false)
        }
    }
    
    func parseUserChange(oldData: [String: String], newData: [String: String], adminId: String) async {
        var typeCondition = ""
        var fromCondition = ""
        var toCondition = ""
        
        for item in oldData {
            if oldData["\(item.key)"] != newData["\(item.key)"] {
                typeCondition += "\(item.key), ".capitalized
                if item.key != "login" && item.key != "password" {
                    fromCondition += "\(oldData["\(item.key)"]!), "
                    toCondition += "\(newData["\(item.key)"]!), "
                }
            }
        }
        
        await databaseManager.newUserChange(adminId: adminId, workerId: newData["identifier"]!, typeCond: typeCondition, fromCond: fromCondition, toCond: toCondition)
    }
}
