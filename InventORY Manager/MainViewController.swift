//
//  MainViewController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    @MainActor let userDataManager = UserDefaultsManager()
    @MainActor var server: Server!
    var userData: [String: String] = [:]
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var storageView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cabinetsView: UIView!
    @IBOutlet weak var workerView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControllChanged(_ sender: Any) {
        updateView()
    }
    
    
    //MARK: STORAGE SETTINGS
    var storageController: StorageController?
    @IBOutlet weak var resetStorageFiltersButton: UIButton!
    @IBOutlet weak var addItemInStorageButton: UIButton!
    @IBOutlet weak var storageTable: UITableView!
    @IBOutlet weak var pullDownStorageButton: UIButton!
    @IBAction func filterStorageByName(_ sender: Any) {
        storageController!.filterByName()
    }
    @IBAction func filterStorageByQuantity(_ sender: Any) {
        storageController!.filterByQuantity()
    }
    @IBAction func filterStorageByIdentity(_ sender: Any) {
        storageController!.filterByIdentity()
    }
    @IBAction func addItemInStorage(_ sender: Any) {
        storageController!.onAddButtonPressed()
    }
    @IBAction func resetStorageFiltersTapped(_ sender: Any) {
        storageController!.resetFilters()
        
    }
    
    //MARK: ACCOUNT SETTINGS
    var accountController: AccountController!
    @IBOutlet weak var accountInfoLabel: UILabel!
    @IBAction func onLogOutPressed(_ sender: Any) {
        accountController.proceedLogout()
    }
    @IBAction func onChangeNamePressed(_ sender: Any) {
        accountController.proceedChangeName()
    }
    
    //MARK: WORKER SETTINGS
    var workersController: WorkersController?
    @IBOutlet weak var addWorkerButton: UIButton!
    @IBOutlet weak var resetWorkerFiltersButton: UIButton!
    @IBOutlet weak var workersTable: UITableView!
    
    @IBAction func filterWorkersByID(_ sender: Any) {
        print("filter workers by id")
    }
    @IBAction func filterWorkersByName(_ sender: Any) {
        print("filter workers by name")
    }
    @IBAction func filterWorkersByLevel(_ sender: Any) {
        print("filter workers by level")
    }
    @IBAction func resetWorkersFiltersTapped(_ sender: Any) {
        print("reset workers filters")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userData = userDataManager.loadUserData()
        print(self.userData)
        server = Server(login: userData["login"]!, password: userData["password"]!)
        updateView()
    }
    
    private func showCabinetsWindow() {
        greetingLabel.text = "Cabinets"
        print("showCabinetsWindow")
    }
    
    private func showStorageWindow() {
        greetingLabel.text = "Storage"
        if self.storageController == nil {
            self.storageController = StorageController(pullDownButton: self.pullDownStorageButton, tableView: self.storageTable, resetFiltersButton: self.resetStorageFiltersButton, addItemButton: addItemInStorageButton, userData: self.userData, delegate: self)
        }
    }
        
    private func showMainWindow() {
        greetingLabel.text = "Hello, \(userData["name"]!)!"
        print("showMainWindow")
    }
    
    private func showWorkerWindow() {
        greetingLabel.text = "Personal"
        if self.workersController == nil {
            self.workersController = WorkersController(resetFiltersButton: resetWorkerFiltersButton, tableView: workersTable, userData: self.userData)
        }
    }
    
    private func showAccountSettingsWindow() {
        greetingLabel.text = "Account settings"
        if self.accountController == nil {
            self.accountController = AccountController(userData: self.userData, infoLabel: self.accountInfoLabel, controller: self, delegate: self)
        }
    }
    
    private func updateView() {
        let selectedSegment = segmentedControl.selectedSegmentIndex
        
        cabinetsView.isHidden = selectedSegment != 0
        storageView.isHidden = selectedSegment != 1
        mainView.isHidden = selectedSegment != 2
        workerView.isHidden = selectedSegment != 3
        accountView.isHidden = selectedSegment != 4

        
        switch selectedSegment {
        case 0:
            showCabinetsWindow()
        case 1:
            showStorageWindow()
        case 2:
            showMainWindow()
        case 3:
            showWorkerWindow()
        case 4:
            showAccountSettingsWindow()
        default:
            break
        }
    }
}

extension MainViewController: AccountControllerDelegate {
    func didLogout() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginController")
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    func didChangeName(){
        self.userData = userDataManager.loadUserData()
    }
}

extension MainViewController: StorageControllerDelegate {
    func didPressedAddItem() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let storeVC = storyboard.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController {
            storeVC.delegate = self
            self.navigationController?.pushViewController(storeVC, animated: true)
        }
    }
    
    func updateTable() {
        storageController!.reloadTableData()
    }
    
    func didLocateItem(rowData: [String: String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let itemVC = storyboard.instantiateViewController(withIdentifier: "StorageItemInfoController") as? StorageItemInfoController {
            itemVC.delegate = self
            itemVC.itemData = rowData
            itemVC.userData = self.userData
            itemVC.count = Int(rowData["quantity"] ?? "1")!
            print(rowData)
            self.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
}
