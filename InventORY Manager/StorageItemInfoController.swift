//
//  StorageItemInfoController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 07.03.2025.
//

import Foundation
import UIKit

class StorageItemInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: StorageControllerDelegate?
    var itemData: [String: String]?
    var userData: [String: String]?
    
    private var image: UIImage?
    private var tableData: [LocationItem] = []
    private var selectedLocation: String?
    private var cabinets: [Cabinets] = []
    var count: Int?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        self.nameLabel.text = itemData?["name"]
        
        switch itemData?["category"] ?? "" {
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
            image = UIImage(systemName: "questionmark.circle")
        }
        
        itemImage.image = image
        
        let description = """
        Category: \(itemData!["category"] ?? "")
        Articul: \(itemData!["articul"] ?? "") 
        
        Quantity: \(itemData!["quantity"] ?? "")
        
        Buyer: \(itemData!["buyerName"] ?? "") (\(itemData!["whoBought"] ?? ""))
        Purchased at: \(itemData!["dateOfBuy"] ?? "")
        """
        
        descriptionLabel.text = description
        
        if Int(userData!["accessLevel"]!)! < 3 {
            addItemButton.isEnabled = false
        }
        
        if Bool(itemData!["fullyIdentified"]!) == true {
            locateButton.setTitle("All located", for: .normal)
            locateButton.isEnabled = false
        }

        Task {
            await setupTableView()
            await setupCabinets()
        }
    }
    
    @IBAction func onAddExistingItemTapped(_ sender: Any) {
        print("add existing item")
        print("item data is: \(String(describing: itemData))")
        
        Task {
            await chooseQuantityToLocate(action: "buy")
        }
    }
    
    
    private func setupTableView() async {
        tableView.delegate = self
        tableView.dataSource = self
                
        let getLocs = await Server.shared.fetchStorageLocations(value: itemData!["articul"]!)
        if getLocs.res {
            self.tableData = getLocs.locations
        } else {
            self.tableData = []
        }
        
        self.tableView.reloadData()
        
        if self.count == 0 {
            locateButton.isHidden = true
        }
        if self.tableData.count == self.count {
            locateButton.setTitle("All located", for: .normal)
            locateButton.isEnabled = false
        } else if self.tableData.count < self.count ?? 0 {
            locateButton.setTitle("Identify (\(self.tableData.count)/\(self.count!))", for: .normal)
            if Int(userData!["accessLevel"]!)! >= 3 {
                locateButton.isEnabled = true
            } else {
                locateButton.isEnabled = false
            }
        } else {
            locateButton.setTitle("Some problem", for: .normal)
            locateButton.isEnabled = false
        }
    }
    
    private func handleCabinetSelection(item: String) {
        print("Selected cabinet: \(item)")
        selectedLocation = item
        Task {
            await chooseQuantityToLocate()
        }
    }
    
    private func checkLocations() async {
        if self.tableData.count == self.count {
            print("all items located")
            await Server.shared.setAllLocatedState(articul: self.itemData!["articul"]!)
            self.delegate?.updateTable()
        } else {
            locateButton.setTitle("Identify (\(self.tableData.count)/\(self.count!))", for: .normal)
            if Int(userData!["accessLevel"]!)! >= 3 {
                locateButton.isEnabled = true
            } else {
                locateButton.isEnabled = false
            }
        }
    }
    
    private func chooseQuantityToLocate(action:  String = "locate") async {
        let alertController = UIAlertController(title: "How much do you want to insert?", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Quantity"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard
                var quantToBuy = alertController.textFields?[0].text
            else {
                return
            }
            if quantToBuy == "" {
                quantToBuy = "1"
            }
            Task {
                do {
                    switch action {
                    case "locate":
                        if Int(quantToBuy)! > (self.count! - self.tableData.count) {
                            quantToBuy = String(self.count! - self.tableData.count)
                        }
                        for _ in 0..<Int(quantToBuy)! {
                            print("locate \(self.itemData!["articul"]!) to \(self.selectedLocation!)")
                            if await Server.shared.locateItemInCab(art: self.itemData!["articul"]!, cab: self.selectedLocation!, userID: self.userData!["identifier"]!) {
                                await self.setupTableView()
                                await self.checkLocations()
                            }
                        }
                    case "buy":
                        if await Server.shared.buyExistingItem(art: self.itemData!["articul"]!, quantity: quantToBuy) {
                            self.count! += Int(quantToBuy)!
                            self.itemData!["quantity"]! = String(self.count!)
                            self.delegate?.updateTable()
                            self.setupUI()
                            
                            await self.checkLocations()
                        }
                    default:
                        break
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    
    
    private func setupCabinets() async {
        cabinets = await Server.shared.fetchCabinetNums()
        var actions = [UIAction]()
                
        for cabinet in cabinets {
            let action = UIAction(title: String(cabinet.cabinetNum)) { [weak self] _ in
                self?.handleCabinetSelection(item: String(cabinet.cabinetNum))
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Chose cabinet", children: actions)
        
        locateButton.menu = menu
        locateButton.showsMenuAsPrimaryAction = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemLocationCell", for: indexPath) as! ItemLocationCell
        cell.delegate = self.delegate
        cell.locationDelegate = self
        let item = tableData[indexPath.row]
                
        cell.configure(with: item, userLevel: Int(userData!["accessLevel"]!)!)
        
        return cell
    }
    
    private func setCondition(for rowData: LocationItem, userName: String) async {
        print("condition \(rowData.condition) will be set to \(!rowData.condition) on the row \(rowData.rowid)")
        
        if await Server.shared.setConditionOnLocation(rowData: rowData, condition: !rowData.condition, userName: userName) {
            print("succsess set condition")
            await setupTableView()
        }
    }
    
    private func cabinetAlert(rowData: LocationItem) {
        Task{
            do {
                let alertController = UIAlertController(title: "Locate items", message: "Choose a cabinet", preferredStyle: .actionSheet)
                
                for cabinet in cabinets {
                    let action = UIAlertAction(title: String(cabinet.cabinetNum), style: .default) { [weak self] _ in
                    Task {
                        do {
                            print("switch \(rowData.rowid) \(cabinet.cabinetNum)")
                            if await Server.shared.relocateStorageItem(rowData: rowData, cab: String(cabinet.cabinetNum), userID: self!.userData!["identifier"]!) {
                                await self?.setupTableView()
                            }
                        }
                    }
                        
                    }
                    alertController.addAction(action)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
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

extension StorageItemInfoController: LocationControllerDelegate {
    func didLocatedItem(rowData: LocationItem) {
        cabinetAlert(rowData: rowData)
    }
}
