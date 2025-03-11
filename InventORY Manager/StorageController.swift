//
//  StorageController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 07.03.2025.
//

import Foundation
import UIKit

class StorageController: NSObject {
    private var pullDownButton: UIButton!
    private var resetFiltersButton: UIButton!
    private var addItemButton: UIButton!
    private var tableView: UITableView!
    
    private var storageData: [StorageItem]?
    private var tableData: [[String: String]] = []
    private var initialTableData: [[String: String]]
    
    var items: Set<String> = []
    
    var userData: [String: String]!
    
    private var server: Server
    
    private var delegate: StorageControllerDelegate
    
    init(pullDownButton: UIButton!, tableView: UITableView!, resetFiltersButton: UIButton!, addItemButton: UIButton!, userData: [String: String]!, delegate: StorageControllerDelegate) {
        self.pullDownButton = pullDownButton
        
        self.resetFiltersButton = resetFiltersButton
        self.resetFiltersButton.isHidden = true
        
        self.userData = userData
        self.addItemButton = addItemButton
        
        self.tableView = tableView
        self.server = Server()
        
        self.tableData = []
        self.initialTableData = []
        
        self.delegate = delegate
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        loadTableConfig()
    }
    
    private func loadTableConfig() {
        if Int(userData["accessLevel"]!)! < 3 {
            addItemButton.isEnabled = false
        }
        
        reloadTableData()
    }
    
    func reloadTableData() {
        Task {
            let answ = await server.getStorageData()
            if answ.res {
                self.storageData = answ.dataExtracted
                self.tableData = []
                for item in self.storageData! {
                    self.tableData.append([
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
                self.initialTableData = self.tableData
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("no data extracted")
            }
            DispatchQueue.main.async {
                self.configurePullDownButton()
            }
        }
    }
    
    private func configurePullDownButton() {
        items = Set(tableData.compactMap { $0["category"] })
        var actions = [UIAction]()
        var image: UIImage!
                
        for item in items {
            switch item {
            case "Computers":
                image = UIImage(systemName: "desktopcomputer.and.macbook")
            case "Monitors":
                image = UIImage(systemName: "desktopcomputer")
            case "Printers":
                image = UIImage(systemName: "printer.fill")
            case "Storage":
                image = UIImage(systemName: "externaldrive.fill")
            case "Switches":
                image = UIImage(systemName: "xserve")
            case "Mice":
                image = UIImage(systemName: "computermouse.fill")
            case "Keyboards":
                image = UIImage(systemName: "keyboard.fill")
            case "Routers":
                image = UIImage(systemName: "wifi")
            case "Laptops":
                image = UIImage(systemName: "laptopcomputer")
            case "Servers":
                image = UIImage(systemName: "server.rack")
            default:
                image = UIImage(systemName: "personalhotspot.slash")
            }
            
            let action = UIAction(title: item, image: image) { [weak self] _ in
                self?.handleActionSelection(item: item)
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Chose category", children: actions)
        
        pullDownButton.menu = menu
        pullDownButton.showsMenuAsPrimaryAction = true
    }
    
    private func handleActionSelection(item: String) {
        print("Выбрано: \(item)")
        
        resetFiltersButton.isHidden = false
        resetFiltersButton.setTitle(item, for: .normal)
        let filteredData = initialTableData.filter { $0["category"] == item }
        
        self.tableData = filteredData
        self.tableView.reloadData()
    }
    
    func resetFilters() {
        self.resetFiltersButton.isHidden = true
        self.tableData = self.initialTableData
        self.tableView.reloadData()
    }
    
    private func applyFilter(criterion: String) {
        let filteredData = self.tableData
        
        resetFiltersButton.isHidden = false
        resetFiltersButton.setTitle(criterion.capitalized, for: .normal)
        
        let sortedData: [[String: String]]
        if criterion == "quantity" {
            sortedData = filteredData.sorted {
                guard let firstValue = $0[criterion], let secondValue = $1[criterion] else { return false }
                return Int(firstValue)! < Int(secondValue)!
            }
        } else if criterion == "unidentified" {
            sortedData = filteredData.filter { !Bool($0["fullyIdentified"]!)! }
        } else {
            sortedData = filteredData.sorted {
                guard let firstValue = $0[criterion], let secondValue = $1[criterion] else { return false }
                return firstValue < secondValue
            }
        }
        
        self.tableData = sortedData
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @MainActor func onAddButtonPressed() {
        self.delegate.didPressedAddItem()
    }
    
    func filterByQuantity() {
        applyFilter(criterion: "quantity")
    }
    
    func filterByName() {
        applyFilter(criterion: "name")
    }
    
    func filterByIdentity() {
        applyFilter(criterion: "unidentified")
    }
    
}

extension StorageController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageTableCell", for: indexPath) as! StorageTableCell
        cell.delegate = self.delegate
        
        let rowData = tableData[indexPath.row]
        cell.userLevel = Int(self.userData["accessLevel"]!)
        cell.configure(with: rowData)
        
        return cell
    }
    
    @MainActor
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        self.showDetails(cell: cell)
    }
    
    @MainActor
    private func showDetails(cell: UITableViewCell!) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let rowData = tableData[indexPath.row]
                    
        self.delegate.didLocateItem(rowData: rowData)
    }
}

extension StorageController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

