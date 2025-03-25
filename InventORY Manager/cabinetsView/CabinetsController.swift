//
//  CabinetsController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 15.03.2025.
//

import Foundation
import UIKit

class CabinetsController: NSObject {
    private var resetFiltersButton: UIButton!
    private var tableView: UITableView!
    private var tableData: [[String: String]] = []
    private var initialTableData: [[String: String]] = []
    private var userData: [String: String]!
    private var addCabinetButton: UIButton!
    
    private var pullDownButton: UIButton!
    
    private var delegate: CabinetsControllerDelegate!
    
    init(resetFiltersButton: UIButton!, tableView: UITableView!, userData: [String : String]!, pullDownButton: UIButton!, addCabinetButton: UIButton!, delegate: CabinetsControllerDelegate!) {
        self.resetFiltersButton = resetFiltersButton
        self.resetFiltersButton.isHidden = true
        
        self.tableView = tableView
        self.tableData = []
        self.initialTableData = []
        self.userData = userData
        self.pullDownButton = pullDownButton
        self.delegate = delegate
        self.addCabinetButton = addCabinetButton
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        loadConfig()
    }
    
    private func loadConfig() {
        if self.userData["accessLevel"]! < "4" {
            self.addCabinetButton.isEnabled = false
        } else {
            self.addCabinetButton.isEnabled = true
        }
        
        reloadTableData()
    }
    
    private func applyFilter(criterion: String) {
        let filteredData = self.tableData
        
        resetFiltersButton.isHidden = false
        switch criterion {
        case "cabinetNum":
            resetFiltersButton.setTitle("Number", for: .normal)
        case "responsibleName":
            resetFiltersButton.setTitle("Responsible", for: .normal)
        default:
            resetFiltersButton.setTitle(criterion.capitalized, for: .normal)

        }
        
        let sortedData: [[String: String]]
        sortedData = filteredData.sorted {
            guard let firstValue = $0[criterion], let secondValue = $1[criterion] else { return false }
            return firstValue < secondValue
        }
        
        self.tableData = sortedData
        self.tableView.reloadData()
    }
    
    private func configurePullDownButton() {
        let items = Set(tableData.compactMap { $0["floor"] }).sorted()
        var actions = [UIAction]()
        let image = UIImage(systemName: "door.left.hand.closed")!
                
        for item in items {
            let action = UIAction(title: item, image: image) { [weak self] _ in
                self?.handleActionSelection(item: item)
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Chose category", children: actions)
        
        self.pullDownButton.menu = menu
        self.pullDownButton.showsMenuAsPrimaryAction = true
    }
    
    private func handleActionSelection(item: String) {
        print("Выбрано: \(item)")
        
        switch item.last {
        case "1":
            resetFiltersButton.setTitle("\(item)st floor", for: .normal)
        case "2":
            resetFiltersButton.setTitle("\(item)nd floor", for: .normal)
        case "3":
            resetFiltersButton.setTitle("\(item)rd floor", for: .normal)
        default:
            resetFiltersButton.setTitle("\(item)th floor", for: .normal)
        }
        
        resetFiltersButton.isHidden = false
        let filteredData = initialTableData.filter { $0["floor"] == item }
        
        self.tableData = filteredData
        self.tableView.reloadData()
    }
    
    func resetFilters() {
        self.resetFiltersButton.isHidden = true
        self.tableData = self.initialTableData
        self.tableView.reloadData()
    }
    
    func reloadTableData() {
        resetFilters()
        Task {
            let answ = await Server.shared.fetchCabinetsWithInfo()
            if answ.res {
                self.tableData = answ.dataExtracted
                self.initialTableData = answ.dataExtracted
                                
                DispatchQueue.main.async {
                    self.configurePullDownButton()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func filterByNumber() {
        applyFilter(criterion: "cabinetNum")
    }
    
    func filterByResponsible() {
        applyFilter(criterion: "responsibleName")
    }
    
    @MainActor
    func addNewCabinet() {
        let cabinetNums = Set(self.tableData.compactMap {$0["cabinetNum"]}).sorted()
                
        self.delegate?.didTapAddCabinet(cabinetNums: cabinetNums)
    }
}

extension CabinetsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CabinetTableCell", for: indexPath) as! CabinetTableCell
        cell.delegate = self.delegate
        
        let rowData = tableData[indexPath.row]
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
                    
        self.delegate.didTapOnCabinet(rowData: rowData, cabinetNum: nil)
    }
}

extension CabinetsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
