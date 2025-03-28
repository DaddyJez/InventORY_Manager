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
    
    
    //MARK: MAIN VIEW SETTINGS
    var mainController: MainWindowController?
    @IBOutlet weak var mainViewJournalsDropdown: UIButton!
    
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
    @IBOutlet weak var accountLoginTextField: UITextField!
    @IBOutlet weak var accountPasswordLoginChangeButton: UIButton!
    @IBOutlet weak var accountPasswTextField: UITextField!
    @IBAction func proceedChangePassw(_ sender: Any) {
        accountController.proceedChangingLoginPassword()
    }
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
        workersController!.applyFilter(criterion: "identifier")
    }
    @IBAction func filterWorkersByName(_ sender: Any) {
        workersController!.applyFilter(criterion: "name")
    }
    @IBAction func filterWorkersByLevel(_ sender: Any) {
        workersController!.applyFilter(criterion: "accessLevel")
    }
    @IBAction func resetWorkersFiltersTapped(_ sender: Any) {
        workersController!.resetFilters()
    }
    
    //MARK: CABINETS SETTINGS
    var cabinetsController: CabinetsController?
    @IBOutlet weak var cabinetsTable: UITableView!
    @IBOutlet weak var resetCabinetFiltersButton: UIButton!
    @IBOutlet weak var addCabinetButton: UIButton!
    @IBOutlet weak var pullDownCabinetsButton: UIButton!
    @IBAction func filterCabinetsByResponsible(_ sender: Any) {
        cabinetsController!.filterByResponsible()
    }
    @IBAction func filterCabinetsByNumber(_ sender: Any) {
        cabinetsController!.filterByNumber()
    }
    @IBAction func resetCabinetsFilterButtonTapped(_ sender: Any) {
        cabinetsController!.resetFilters()
    }
    @IBAction func addCabinetButtonTapped(_ sender: Any) {
        cabinetsController!.addNewCabinet()
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
        if self.cabinetsController == nil {
            self.cabinetsController = CabinetsController(resetFiltersButton: self.resetCabinetFiltersButton, tableView: self.cabinetsTable, userData: self.userData, pullDownButton: self.pullDownCabinetsButton, addCabinetButton: self.addCabinetButton, delegate: self)
        }
    }
    
    private func showStorageWindow() {
        greetingLabel.text = "Storage"
        if self.storageController == nil {
            self.storageController = StorageController(pullDownButton: self.pullDownStorageButton, tableView: self.storageTable, resetFiltersButton: self.resetStorageFiltersButton, addItemButton: addItemInStorageButton, userData: self.userData, delegate: self)
        }
    }
        
    private func showMainWindow() {
        greetingLabel.text = "Hello, \(userData["name"]!)!"
        if self.mainController == nil {
            self.mainController = MainWindowController(dropdownWithJournals: self.mainViewJournalsDropdown, delegate: self)            
        }
    }
    
    private func showWorkerWindow() {
        greetingLabel.text = "Personal"
        if self.workersController == nil {
            self.workersController = WorkersController(resetFiltersButton: resetWorkerFiltersButton, tableView: workersTable, userData: self.userData, delegate: self)
        }
    }
    
    private func showAccountSettingsWindow() {
        greetingLabel.text = "Account settings"
        if self.accountController == nil {
            self.accountController = AccountController(userData: self.userData, infoLabel: self.accountInfoLabel, controller: self, delegate: self, passwTextElement: self.accountPasswTextField, loginTextElement: self.accountLoginTextField, proceedButton: self.accountPasswordLoginChangeButton)
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
        if self.storageController != nil {
            storageController!.reloadTableData()
        }
        if self.workersController != nil {
            self.workersController!.setupTableView()
        }
    }
}

extension MainViewController: StorageControllerDelegate {
    func didTapToSeeCabinets(cabinetNum: Int) {
        self.didTapOnCabinet(cabinetNum: cabinetNum)
    }
    
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

extension MainViewController: WorkerControllerDelegate {
    func didPressedWorkerInfo(rowData: [String : String]) {
        if rowData["identifier"] != self.userData["identifier"] {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let itemVC = storyboard.instantiateViewController(withIdentifier: "WorkerInfoController") as? WorkerInfoController {
                itemVC.workerData = rowData
                itemVC.selfLevel = self.userData["accessLevel"]!
                itemVC.selfId = self.userData["identifier"]!
                itemVC.delegate = self
                self.navigationController?.pushViewController(itemVC, animated: true)
            }
        }
    }
    
    func needsToUpdateList() {
        self.workersController?.setupTableView()
    }
}

extension MainViewController: CabinetsControllerDelegate {
    func needsToUpdateCabinets() {
        self.cabinetsController?.reloadTableData()
    }
    
    func didTapAddCabinet(cabinetNums: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let itemVC = storyboard.instantiateViewController(withIdentifier: "AddCabinetViewController") as? AddCabinetViewController {

            itemVC.cabinets = cabinetNums
            itemVC.delegate = self
            
            self.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
    
    func didTapOnCabinet(rowData: [String : String]? = nil, cabinetNum: Int? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let itemVC = storyboard.instantiateViewController(withIdentifier: "CabinetsInfoController") as? CabinetsInfoController {
            itemVC.cabinetData = rowData
            itemVC.cabinetNum = cabinetNum
            itemVC.selfData = self.userData
            itemVC.delegate = self
            itemVC.userData = self.userData
            self.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
}

extension MainViewController: MainWindowControllerDelegate {
    func didTapOnStorageJournal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let itemVC = storyboard.instantiateViewController(withIdentifier: "StorageJournalViewController") as? StorageJournalViewController {
            self.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
    
    func didTapOnWorkersJournal() {
        print("workers")
        
        // TODO: ^
    }
    
    
}
