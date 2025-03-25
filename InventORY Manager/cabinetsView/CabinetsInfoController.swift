//
//  CabinetsInfoController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 17.03.2025.
//

import Foundation
import UIKit

class CabinetsInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var categoriesFiltefButton: UIButton!
    @IBOutlet weak var cabunetNumLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var items: Set<String> = []
    
    private var tableData: [LocationItem] = []
    private var initialTableData: [LocationItem] = []

    var userData: [String: String]?
    
    var cabinetData: [String: String]!
    var cabinetNum: Int!
    var selfData: [String: String]!
    
    weak var delegate: CabinetsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configure()
    }
    
    private func configure() {
        if self.cabinetData != nil {
            self.cabunetNumLabel.text = "\(cabinetData["cabinetNum"]!) Cabinet"
            self.descriptionLabel.text = """
            Responsible: \(cabinetData["responsibleName"]!) (\(cabinetData["responsible"]!))
            Floor: \(cabinetData["floor"]!)
            
            Items:
            """
            updateTableView()
        } else if cabinetNum != nil {
            Task {
                let answ = await Server.shared.fetchExactCabinet(cabinetNum: cabinetNum)
                if answ.res {
                    self.cabinetData = answ.dataExtracted
                    self.configure()
                }
            }
        }
    }
    
    private func updateTableView() {
        Task {
            let answ = await Server.shared.fetchStorageLocations(column: "cabinet", value: cabinetData["cabinetNum"]!)
            if answ.res {
                self.tableData = answ.locations
                self.initialTableData = answ.locations
                self.tableView.reloadData()
                
                configurePullDownButton()
            }
        }
    }
    
    private func configurePullDownButton() {
        items = Set(tableData.compactMap { $0.storage?.category })
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
        
        let action = UIAction(title: "Reset", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.resetFilters()
            self?.categoriesFiltefButton.setTitle("Categories:", for: .normal)
        }
        
        actions.append(action)
        
        let menu = UIMenu(title: "Chose category", children: actions)
        
        categoriesFiltefButton.menu = menu
        categoriesFiltefButton.showsMenuAsPrimaryAction = true
    }
    
    private func resetFilters() {
        self.tableData = initialTableData
        self.tableView.reloadData()
    }
    
    private func handleActionSelection(item: String) {
        print("Выбрано: \(item)")
        
        //resetFiltersButton.isHidden = false
        categoriesFiltefButton.setTitle(item, for: .normal)
        let filteredData = initialTableData.filter { $0.storage!.category == item }
        
        self.tableData = filteredData
        self.tableView.reloadData()
    }
    
    private func onCellTapped(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let rowData = tableData[indexPath.row]
        
        var titleMessage: String!
        if rowData.condition {
            titleMessage = "Report '\(String(describing: rowData.storage!.name))' as broken?"
        } else {
            titleMessage = "Report '\(String(describing: rowData.storage!.name))' as working?"
        }
        
        let message = "U can change the status later"
        let alertController = UIAlertController(
            title: titleMessage,
            message: message,
            preferredStyle: .alert
        )
        
        let proceedAction = UIAlertAction(title: "Yes", style: .default) {
            [weak self] _ in
            guard let self = self else { return }
            Task {
                do {
                    await self.setCondition(for: rowData, userName: self.userData!["identifier"]!)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(proceedAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setCondition(for rowData: LocationItem, userName: String) async {
        print("condition \(rowData.condition) will be set to \(!rowData.condition) on the row \(rowData.rowid)")
        
        if await Server.shared.setConditionOnLocation(rowData: rowData, condition: !rowData.condition, userName: userName) {
            print("succsess set condition")
            updateTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CabinetInfoTableViewCell", for: indexPath) as! CabinetInfoTableViewCell
        
        /*
        cell.delegate = self.delegate
        cell.locationDelegate = self
         */
        
        cell.item = tableData[indexPath.row]
        cell.configure()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if Int(userData!["accessLevel"]!)! >= 2 {
            self.onCellTapped(cell: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
