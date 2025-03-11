//
//  Delegates.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 07.03.2025.
//

import Foundation

@MainActor
protocol AccountControllerDelegate: AnyObject {
    func didLogout()
    func didChangeName()
}

@MainActor
protocol StorageControllerDelegate: AnyObject {
    func didPressedAddItem()
    func didLocateItem(rowData: [String: String])
    func updateTable()
}

@MainActor
protocol LocationControllerDelegate: AnyObject {
    func didLocatedItem(rowData: LocationItem)
}
