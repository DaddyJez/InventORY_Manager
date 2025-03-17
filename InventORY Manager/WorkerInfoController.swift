//
//  WorkerInfoController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 11.03.2025.
//

import Foundation
import UIKit

class WorkerInfoController: UIViewController {
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var nameLabel: UITextView!
    
    @IBOutlet weak var levelDescriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var levelStepperElement: UIStepper!
    @IBOutlet weak var passwordElement: UITextField!
    @IBOutlet weak var loginElement: UITextField!
    @IBOutlet weak var levelElement: UITextField!
    @IBOutlet weak var idElement: UITextField!
    
    var workerData: [String: String]!
    var oldWorkerData: [String: String]!
    var selfLevel: String!
    var selfId: String!
    
    weak var delegate: WorkerControllerDelegate?
    
    var isAllowedToChange = (name: true, identifier: true, password: true, login: true)
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupUI()
    }
    
    private func setupUI() {
        oldWorkerData = workerData
        nameLabel.text = workerData["name"]
        
        if workerData["accessLevel"] == "5" {
            imageLabel.image = UIImage(systemName: "person.badge.key.fill")
        } else {
            imageLabel.image = UIImage(systemName: "person.fill")
        }
        
        if selfLevel == "5" {
            passwordElement.text = workerData["password"]
            
            loginElement.text = workerData["login"]
            
            if workerData["accessLevel"] != "5" {
                loginElement.isEnabled = true
                passwordElement.isEnabled = true
                idElement.isEnabled = true
                levelStepperElement.isEnabled = true
            } else {
                loginElement.isEnabled = false
                passwordElement.isEnabled = false
                idElement.isEnabled = false
                levelStepperElement.isEnabled = false
            }
        } else {
            passwordElement.text = "******"
            passwordElement.isEnabled = false
            
            loginElement.text = "******"
            loginElement.isEnabled = false
            
            idElement.isEnabled = false
            
            submitButton.isEnabled = false
            submitButton.setTitle("Unabled", for: .normal)
            
            levelStepperElement.isEnabled = false
        }
        
        idElement.text = workerData["identifier"]
        levelElement.text = "\(workerData["accessLevel"]!)*"
        levelElement.isEnabled = false
        levelStepperElement.value = Double(workerData["accessLevel"]!)!
    }
    
    private func setupDescriptionText() {
        switch Int(levelStepperElement.value) {
        case 1:
            levelDescriptionLabel.text = """
            1* is the level without any permissions.
            
            Users with this level can't provide any changes.
            It's allowed to see info with this level.
            """
        case 2:
            levelDescriptionLabel.text = """
            2* level allows user to contact with storage units.
            
            Users with this level can report units as broken/working.
            """
        case 3:
            levelDescriptionLabel.text = """
            3* is the level that controlls all storage operations.
            
            Can add/remove all storage units.
            Can see "Storage operations" journal.
            """
        case 4:
            levelDescriptionLabel.text = """
            4* is the level that controlls all operations with storage and cabinets.
            
            Add/remove storage units.
            Add/remove cabinets and responsible people.
            """
        case 5:
            levelDescriptionLabel.text = """
            5* is the level whitch allows to controll everything.
            
            This level can controll all operations or give permissions to other.
            (You can't change it once You set this level to someone)
            """
        default:
            levelDescriptionLabel.text = "wtf is this level"
        }
    }
    
    @IBAction func idElementEdited(_ sender: Any) {
        if idElement.text != "" {
            workerData["identifier"] = idElement.text!
            isAllowedToChange.identifier = true
        } else {
            isAllowedToChange.identifier = false
        }
    }
    
    @IBAction func loginEdited(_ sender: Any) {
        if loginElement.text != "" {
            workerData["login"] = loginElement.text!
            isAllowedToChange.login = true
        } else {
            isAllowedToChange.login = false
        }
    }
    
    @IBAction func passwordElementChanged(_ sender: Any) {
        if passwordElement.text != "" {
            workerData["password"] = passwordElement.text!
            isAllowedToChange.password = true
        } else {
            isAllowedToChange.password = false
        }
    }
    
    @IBAction func levelChanged(_ sender: Any) {
        levelElement.text = "\(Int(levelStepperElement.value))*"
        workerData["accessLevel"] = String(Int(levelStepperElement.value))
        setupDescriptionText()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        print()
        if nameLabel.text != "" {
            workerData["name"] = nameLabel.text!
            isAllowedToChange.name = true
        } else {
            isAllowedToChange.name = false
        }
        print(oldWorkerData!)
        print(workerData!)
                
        if !isAllowedToChange.login || !isAllowedToChange.password || !isAllowedToChange.name || !isAllowedToChange.identifier {
            print("not allowed")
            submitButton.setTitle("NO", for: .normal)
        } else {
            submitButton.setTitle("YEP", for: .normal)
            Task {
                if await Server.shared.updateUserInfo(oldId: oldWorkerData["identifier"]!, newData: workerData) {
                    await Server.shared.parseUserChange(oldData: oldWorkerData!, newData: workerData!, adminId: selfId)
                    self.delegate?.needsToUpdateList()
                }
            }
        }
    }
}
