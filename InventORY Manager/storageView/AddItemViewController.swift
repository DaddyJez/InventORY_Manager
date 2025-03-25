//
//  AddItemViewController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 07.03.2025.
//

import Foundation
import UIKit

class AddItemViewController: UIViewController {
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var greetTextEl: UILabel!
    @IBOutlet weak var costEl: UITextField!
    @IBOutlet weak var quantityEl: UITextField!
    @IBOutlet weak var categoryEl: UIButton!
    @IBOutlet weak var nameEl: UITextField!
    
    weak var delegate: StorageControllerDelegate?
    
    private var selectedCategory: String?
    private var categories: Set<String>?
    private var userData: [String: String]?
    private var insertedData: (name: Bool, cost: Bool, quantity: Bool, category: Bool)?
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func onNameChange(_ sender: Any) {
        if nameEl.text != "" {
            greetTextEl.text = "Funny name!"
            insertedData?.name = true
        } else {
            greetTextEl.text = "What name?"
            insertedData?.name = false
        }
    }
    @IBAction func quantityChanged(_ sender: Any) {
        if quantityEl.text != "" {
            greetTextEl.text = "Nothing much..."
            if let quantity = Int(quantityEl.text!) {
                if quantity > 0 {
                    insertedData?.quantity = true
                } else {
                    greetTextEl.text = "Zero? 🤔"
                    insertedData?.quantity = false
                }
            }
        } else {
            greetTextEl.text = "How much?"
            insertedData?.quantity = false
        }
    }
    @IBAction func costChanged(_ sender: Any) {
        if costEl.text != "" {
            greetTextEl.text = "💸💸💸💸💸💸"
            if let cost = Int(costEl.text!) {
                if cost > 0 {
                    insertedData?.cost = true
                } else {
                    greetTextEl.text = "Zero? 🤔"
                    insertedData?.cost = false
                }
            }
        } else {
            insertedData?.cost = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        configureCategories()
        insertedData = (false, false, false, false)
        
        nameEl.becomeFirstResponder()
    }
    
    private func configureCategories() {
        categories = ["Monitors", "Printers", "Storage", "Switches", "Mice", "Keyboards", "Computers", "Routers", "Servers"]
        var actions = [UIAction]()
        var image: UIImage!
                
        for item in categories! {
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
                image = UIImage(systemName: "questionmark.circle")
            }
            
            let action = UIAction(title: item, image: image) { [weak self] _ in
                self?.handleActionSelection(item: item)
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Chose category", children: actions)
        
        categoryEl.menu = menu
        categoryEl.showsMenuAsPrimaryAction = true
    }
    
    private func handleActionSelection(item: String) {
        print("Выбрано: \(item)")
        selectedCategory = item
        greetTextEl.text = "U need MORE \(item.lowercased())?"
        insertedData?.category = true
        
        let image = UIImage(systemName: "tray")
        categoryEl.setTitle(item, for: .normal)
        categoryEl.setImage(image, for: .normal)
    }
    
    private func checkFields() -> Bool {
        if insertedData?.name == false {
            greetTextEl.text = "Lol, what is the name?"
            return false
        } else if insertedData?.category == false {
            greetTextEl.text = "I can't add category for you"
            return false
        } else if insertedData?.quantity == false {
            greetTextEl.text = "Ok, but how much?"
            return false
        } else if insertedData?.cost == false {
            greetTextEl.text = "Yo, u need to pay"
            return false
        } else {
            greetTextEl.text = "Yep, u can add"
            return true
        }
    }
    
    
    @IBAction func onProceedAddingTapped(_ sender: Any) {
        if checkFields() {
            proceedButton.isEnabled = false
            print("adding")
            Task {
                let adding = await Server.shared.addToStorage(caregory: selectedCategory!, name: nameEl.text!, cost: costEl.text!, quantity: quantityEl.text!)
                if adding.res == true {
                    print("Successfuly added \(adding.insertedArticul)")
                    self.navigationController?.popViewController(animated: true)
                    delegate?.updateTable()
                } else {
                    DispatchQueue.main.async {
                        self.greetTextEl.text = "Error occurred 😢"
                        self.proceedButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    
    
}
