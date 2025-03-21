//
//  Structures.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import Foundation

struct UserData: Decodable {
    let identifier: String
    let login: String
    let password: String
    let name: String
    let level: Int8
}

struct ShopItem: Decodable {
    let articul: String
    let category: String
    let name: String
    let cost: Int
    let description: String
}

struct StorageItem: Decodable {
    let category: String
    let articul: String
    let name: String
    let quantity: Int
    let whoBought: String
    let dateOfBuy: String
    let fullyIdentified: Bool
    let users: UserData?

    struct UserData: Decodable {
        let name: String
    }
}

struct LocationItem: Decodable {
    let rowid: Int
    let ItemArticul: String
    let cabinet: Int
    let condition: Bool

    let storage: StorageItem?
        
    struct StorageItem: Decodable {
        let name: String
        let category: String
    }
    
    let cabinets: Cabinets?
    
    struct Cabinets: Decodable {
        let responsible: String
    }
}

struct Cabinets: Decodable {
    let cabinetNum: Int
}

struct CabinetsInfo: Decodable {
    let cabinetNum: Int
    let responsible: String
    let floor: Int
    
    let users: UserData?

    struct UserData: Decodable {
        let name: String
    }
}
