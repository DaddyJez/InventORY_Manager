//
//  AddCabinetViewController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 23.03.2025.
//

import Foundation
import UIKit

class AddCabinetViewController: UIViewController {
    @IBOutlet weak var answLabel: UILabel!
    @IBOutlet weak var numberEl: UITextField!
    @IBOutlet weak var floorEl: UITextField!
    @IBOutlet weak var choosingResponsibleButton: UIButton!
    
    weak var delegate: CabinetsControllerDelegate!
    
    var cabinets: [String]!
    var users: [[String: String]]!
    
    private var selectedInfo: (num: Int?, floor: Int?, resp: String?)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.users == nil {
            Task {
                let usersFetch = await Server.shared.fetchUsersWithoutPassword()
                if usersFetch.res {
                    self.users = usersFetch.users
                }
                configureResponsible()
            }
        } else {
            configureResponsible()
        }
        
    }
    
    private func configureResponsible() {
        let items = self.users!
        var actions = [UIAction]()
        let image = UIImage(systemName: "person.fill")!
                
        for item in items {
            let action = UIAction(title: "\(item["name"] ?? "name") (\(item["identifier"] ?? "id"))", image: image) { [weak self] _ in
                self?.handleActionSelection(item: item["identifier"]!)
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Chose category", children: actions)
        
        self.choosingResponsibleButton.menu = menu
        self.choosingResponsibleButton.showsMenuAsPrimaryAction = true
    }
    
    private func handleActionSelection(item: String) {
        self.choosingResponsibleButton.setTitle(item, for: .normal)
        self.selectedInfo.resp = item
    }
    
    @IBAction func numberElementChanged(_ sender: Any) {
        if numberEl.text != "" {
            self.selectedInfo.num = Int(numberEl.text!) ?? nil
        } else {
            self.selectedInfo.num = nil
        }
    }
    
    @IBAction func floorElementChanged(_ sender: Any) {
        if floorEl.text != "" {
            self.selectedInfo.floor = Int(floorEl.text!) ?? nil
        } else {
            self.selectedInfo.floor = nil
        }
    }
    
    @IBAction func provideAddingItems(_ sender: Any) {
        if selectedInfo.floor != nil && selectedInfo.num != nil && selectedInfo.resp != nil {
            answLabel.text = "Good, let's add cab."
            
            Task {
                if await Server.shared.addNewCabinet(num: selectedInfo.num!, floor: selectedInfo.floor!, resp: selectedInfo.resp!) {
                    self.delegate?.needsToUpdateCabinets()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            answLabel.text = "Fill all fields correctly!"
        }
    }
}
