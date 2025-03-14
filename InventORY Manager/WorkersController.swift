//
//  WorkersController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 10.03.2025.
//

import Foundation
import UIKit

class WorkersController: NSObject {
    private var resetFiltersButton: UIButton!
    private var tableView: UITableView!
    private var tableData: [[String: String]] = []
    private var initialTableData: [[String: String]] = []
    private var userData: [String: String]!
    
    private var delegate: WorkerControllerDelegate?

    init(resetFiltersButton: UIButton!, tableView: UITableView!, userData: [String: String]!, delegate: WorkerControllerDelegate?) {
        self.resetFiltersButton = resetFiltersButton
        self.tableView = tableView
        self.userData = userData
        
        self.delegate = delegate
        
        self.resetFiltersButton.isHidden = true
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        setupTableView()
        
    }
    
    func setupTableView() {
        resetFilters()
        Task {
            let answ = await Server.shared.fetchUsersInfo()
            if answ.res {
                self.tableData = answ.users
                self.initialTableData = answ.users
                                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func resetFilters() {
        self.tableData = self.initialTableData
        resetFiltersButton.isHidden = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func applyFilter(criterion: String) {
        let filteredData = self.tableData
        
        resetFiltersButton.isHidden = false
        resetFiltersButton.setTitle(criterion.capitalized, for: .normal)
        
        let sortedData: [[String: String]]
        sortedData = filteredData.sorted {
            guard let firstValue = $0[criterion], let secondValue = $1[criterion] else { return false }
            return firstValue < secondValue
        }
        
        self.tableData = sortedData
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension WorkersController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkerTableCell", for: indexPath) as! WorkerTableViewCell
        //cell.delegate = self.delegate
        
        let rowData = tableData[indexPath.row]
        cell.configure(with: rowData, selfId: userData["identifier"]!)
        
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
        
        self.delegate?.didPressedWorkerInfo(rowData: rowData)
    }
}

extension WorkersController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
