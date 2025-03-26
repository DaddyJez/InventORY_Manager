//
//  SupabaseManager.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import Supabase
import Realtime
import Foundation

class SupabaseManager {
    @MainActor static let shared = SupabaseManager() // Синглтон
    
    private let client: SupabaseClient

    init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://ukgeippwcvmzqirugeio.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrZ2VpcHB3Y3ZtenFpcnVnZWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczMzU5MDEsImV4cCI6MjA1MjkxMTkwMX0.GJEg05_DOZlFUntJCHehR44uhI5aKlxNWyIU1sEyjE4"
        )
    }
    
    func fetchUsersData(identifier: String) async -> (data: [UserData], res: Bool) {
        do {
            let response: [UserData] = try await client
                .from("users")
                .select()
                .eq("identifier", value: identifier)
                .execute()
                .value

            return (response, true)
        } catch {
            print(error)
            return ([], false)
        }
    }
    
    func register(id: String, login: String, password: String) async -> Bool {
        do {
            try await client
                .from("users")
                .insert([
                    "identifier": id,
                    "login": login,
                    "password": password,
                    "name": login,
                ])
                .execute()

            print("Пользователь зарегистрирован: \(login)")
            await UserDefaultsManager.shared.saveUserData(identifier: id, login: login, password: password, name: login, accessLevel: 1)
            return true
        } catch {
            print("Ошибка при регистрации пользователя: \(error)")
            return false
        }
    }
    
    func isLoginExists(login: String) async -> Bool {
        do {
            let response: [UserData] = try await client
                .from("users")
                .select()
                .eq("login", value: login)
                .execute()
                .value

            return response.isEmpty
        } catch {
            print("Ошибка при проверке логина: \(error)")
            return false
        }
    }
    
    func getAllIDs(table: String) async -> (set: Set<String>, res: Bool) {
        do {
            switch table {
            case "users":
                let response: [UserData] = try await client
                    .from(table)
                    .select()
                    .execute()
                    .value
                let ids = response.map { $0.identifier }
                print(ids)
                return (Set(ids), true)
            case "shopItems":
                let response: [ShopItem] = try await client
                    .from(table)
                    .select()
                    .execute()
                    .value

                let ids = response.map { $0.articul }
                return (Set(ids), true)
            default:
                preconditionFailure("Неверно указана таблица")
            }
        } catch {
            print("Ошибка при получении идентификаторов: \(error)")
            return ([], false)
        }
    }
    
    func login(enteredLogin: String, enteredPassword: String) async -> Bool {
        do {
            let response: [UserData] = try await client
                .from("users")
                .select()
                .eq("login", value: enteredLogin)
                .eq("password", value: enteredPassword)
                .execute()
                .value
                        
            if (response.first != nil) {
                await UserDefaultsManager.shared.saveUserData(identifier: response.first!.identifier, login: response.first!.login, password: response.first!.password, name: response.first!.name, accessLevel: response.first!.level)
                return true
            }
        } catch {
            print("Ошибка при входе пользователя: \(error)")
        }
        return false
    }
    
    //MARK: WORKERS OPERATIONS
    func fetchAllUsersData() async -> (data: [UserData], res: Bool) {
        do {
            let response: [UserData] = try await client
                .from("users")
                .select()
                .execute()
                .value
            
            return (response, true)
        } catch {
            print(error)
            return ([], false)
        }
    }
    
    func newUserChange(adminId: String, workerId: String, typeCond: String, fromCond: String, toCond: String) async {
        do {
            try await client.from("usersChanges")
                .insert([
                    "adminId": adminId,
                    "workerId": workerId,
                    "type": typeCond,
                    "from": fromCond,
                    "to": toCond
                ])
                .execute()
            
        } catch {
            print(error)
        }
    }
    
    @MainActor func updateUserName(newName: String, oldData: [String: String]) async -> Bool {
        do {
            let response = try await client.from("users")
                .update(["name": newName])
                .eq("identifier", value: oldData["identifier"]!)
                .execute()
            
            print("Имя пользователя обновлено: \(response)")
            
            UserDefaultsManager.shared.saveUserData(
                identifier: oldData["identifier"]!,
                login: oldData["login"]!,
                password: oldData["password"]!,
                name: newName,
                accessLevel: Int8(oldData["accessLevel"]!)!
            )
            
            return true
        } catch {
            print("Ошибка при обновлении имени пользователя: \(error)")
            return false
        }
    }
    
    @MainActor
    func updateLoginPassword(newLogin: String, newPassword: String, oldData: [String: String]) async -> Bool {
        do {
            try await client.from("users")
                .update([
                    "login": newLogin,
                    "password": newPassword
                ])
                .eq("identifier", value: oldData["identifier"]!)
                .execute()
            
            UserDefaultsManager.shared.saveUserData(
                identifier: oldData["identifier"]!,
                login: newLogin,
                password: newPassword,
                name: oldData["name"]!,
                accessLevel: Int8(oldData["accessLevel"]!)!
            )
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func updateUser(oldID: String, newData: [String: String]) async -> Bool {
        do {
            try await client.from("users")
                .update([
                    "identifier": newData["identifier"],
                    "name": newData["name"]!,
                    "login": newData["login"]!,
                    "password": newData["password"]!,
                    "level": newData["accessLevel"]!
                ])
                .eq("identifier", value: oldID)
                .execute()
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    //MARK: STORAGE OPERATIONS:
    func fetchStorageItems() async -> (dataExtracted: [StorageItem], res: Bool) {
        do {
            // Выполняем запрос к таблице "storage" с JOIN на таблицу "users"
            let response: [StorageItem] = try await client
                .from("storage")
                .select("category, articul, name, quantity, whoBought, dateOfBuy, users:users(name), fullyIdentified")
                .execute()
                .value

            return (response, true)
        } catch {
            print("Ошибка при получении данных из таблицы storage: \(error)")
            return ([], false)
        }
    }
    
    private func isItemInStorage(articul: String) async -> (quant: Int, res: Bool) {
        do {
            let response: [StorageItem] = try await client
                .from("storage")
                .select()
                .eq("articul", value: articul)
                .execute()
                .value
            
            if response.first != nil {
                return (response.first!.quantity, true)
            } else {
                return (0, true)
            }
        } catch {
            print("error with checking item in storage: \(error)")
            return (0, false)
        }
    }
    
    func buyItemFromStore(articul: String, quantity: String) async -> Bool {
        do {
            let response: [ShopItem] = try await client
                .from("shopItems")
                .select()
                .eq("articul", value: articul)
                .execute()
                .value
            
            if (response.first != nil) {
                let userData = await UserDefaultsManager.shared.loadUserData()
                let itemInStorage = await isItemInStorage(articul: response.first!.articul)
                if itemInStorage.res {
                    if itemInStorage.quant > 0  {
                        _ = try await client.from("storage")
                            .update(["quantity": String(itemInStorage.quant + Int(quantity)!),
                                    "fullyIdentified": "false"
                                    ])
                            .eq("articul", value: response.first!.articul)
                            .execute()
                    } else {
                        _ = try await client
                            .from("storage")
                            .insert([
                                "articul": response.first!.articul,
                                "name": response.first!.name,
                                "quantity": quantity,
                                "whoBought": userData["identifier"],
                                "category": response.first!.category,
                                "fullyIdentified": "false"
                            ])
                            .execute()
                    }
                    await newStorageChange(type: "BUY", art: response.first!.articul, quant: quantity, price: String((response.first!.cost * Int(quantity)!)), personalName: userData["identifier"]!)
                    return true
                }
            }
            return false
        } catch {
            print("error: \(error)")
            return false
        }
    }
    
    func addStoreItem(articul: String, category: String, name: String, cost: String) async -> (art: String, res: Bool)  {
        do {
            try await client
                .from("shopItems")
                .insert([
                    "articul": articul,
                    "category": category,
                    "name": name,
                    "cost": cost,
                ])
                .execute()

            print("Товар добавлен")
            return (articul, true)
        } catch {
            print("Ошибка при регистрации товара: \(error)")
            return ("", false)
        }
    }
    
    func deleteStorageItem(articul: String) async -> Bool {
        do {
            try await client
                .from("storage")
                .delete()
                .eq("articul", value: articul)
                .execute()
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func newStorageChange(type: String = "BUY", art: String, quant: String = "1", price: String = "0", personalName: String) async {
        print("\(type) \(art) \(quant) \(price) \(personalName)")
        do {
            try await client
                .from("storageChanges")
                .insert([
                    "type": type,
                    "itemArticul": art,
                    "quantity": quant,
                    "cost": price,
                    "personalName": personalName,
                ])
                .execute()
        } catch {
            print(error)
        }
    }
    
    //MARK: LOCATION OPERATIONS
    func fetchLocations(col: String, value: String) async -> (locations: [LocationItem], res: Bool) {
        do {
            let response: [LocationItem] = try await client
                .from("itemList")
                .select("rowid, ItemArticul, cabinet, condition, storage:storage(name, category), cabinets:cabinets(responsible)")
                .eq(col, value: value)
                .execute()
                .value
            return (response, true)
        } catch {
            print(error)
            return ([], false)
        }
    }
    
    func setConditionOnLocation(rowData: LocationItem, condition: Bool, userName: String) async -> Bool {
        do {
            try await client.from("itemList")
                .update(["condition": condition])
                .eq("rowid", value: rowData.rowid)
                .execute()
            await newStorageChange(type: "UPDATE \(!rowData.condition ? "TRUE" : "FALSE")", art: rowData.ItemArticul, personalName: userName)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func fetchCabinets() async throws -> [Cabinets] {
        do {
            let response: [Cabinets] = try await client
                .from("cabinets")
                .select("cabinetNum")
                .execute()
                .value
            
            return response
        } catch {
            print("Ошибка при загрузке товаров: \(error)")
            throw error
        }
    }
    
    func locateItem(articul: String, cabinet: String, userName: String) async -> Bool {
        do {
            try await client
                .from("itemList")
                .insert([
                    "ItemArticul": articul,
                    "cabinet": cabinet,
                    "condition": "TRUE"
                ])
                .execute()
            await newStorageChange(type: "LOCATE", art: articul, personalName: userName)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func setItemState(art: String, state: String) async {
        do {
            try await client.from("storage")
                .update(["fullyIdentified": state])
                .eq("articul", value: art)
                .execute()
        } catch {
            print(error)
        }
    }
    
    func relocateItem(rowId: String, newCabinet: String) async -> Bool {
        print("relocateItem \(rowId) \(newCabinet)")
        do {
            try await client.from("itemList")
                .update(["cabinet": newCabinet])
                .eq("rowid", value: rowId)
                .execute()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    
    //MARK: CABINETS OPERATIONS
    func fetchCabinetsWithInfo() async -> (dataExtracted: [CabinetsInfo], res: Bool) {
        do {
            let response: [CabinetsInfo] = try await client
                .from("cabinets")
                .select("cabinetNum, responsible, floor, users:users(name)")
                .execute()
                .value
            
            return (response, true)
        } catch {
            print(error)
            return ([], false)
        }
    }
    
    func fetchExactCabinet(cabinetNum: Int) async -> (dataExtracted: [CabinetsInfo]?, res: Bool) {
        do {
            let response: [CabinetsInfo] = try await client
                .from("cabinets")
                .select("cabinetNum, responsible, floor, users:users(name)")
                .eq("cabinetNum", value: cabinetNum)
                .execute()
                .value
            
            return (response, true)
        } catch {
            print(error)
            return (nil, false)
        }
    }
    
    func addNewCabinetToDB(cabinetNum: String, floor: String, responsible: String) async -> Bool {
        do {
            try await client
                .from("cabinets")
                .insert(["cabinetNum": cabinetNum, "floor": floor, "responsible": responsible])
                .execute()
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func findSome(table: String, column: String, value: String) async -> Int {
        do {
            let response: [[String: String]] = try await client
                .from(table)
                .select(column)
                .eq(column, value: value)
                .execute()
                .value
            
            print("RESPONSE:")
            return response.count
        } catch {
            print(error)
            return 404
        }
    }
    
    //MARK: JOURNALS
    func fetchStorageJournal() async -> [StorageJournalModel] {
        do {
            let response: [StorageJournalModel] = try await client
                .from("storageChanges")
                .select("rowid, type, itemArticul, storage:storage(name), quantity, cost, created_at, personalName, users:users(name)")
                .execute()
                .value
            
            return response
        } catch {
            print(error)
            return []
        }
    }
}

