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
    func didTapToSeeCabinets(cabinetNum: Int)
}

@MainActor
protocol LocationControllerDelegate: AnyObject {
    func didLocatedItem(rowData: LocationItem)
}

@MainActor
protocol WorkerControllerDelegate: AnyObject {
    func didPressedWorkerInfo(rowData: [String: String])
    func needsToUpdateList()
}

@MainActor
protocol CabinetsControllerDelegate: AnyObject {
    func didTapOnCabinet(rowData: [String: String]?, cabinetNum: Int?)
    func didTapAddCabinet(cabinetNums: [String])
    func needsToUpdateCabinets()
}
