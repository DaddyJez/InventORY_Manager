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
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var levelStepperElement: UIStepper!
    @IBOutlet weak var passwordElement: UITextField!
    @IBOutlet weak var loginElement: UITextField!
    @IBOutlet weak var levelElement: UITextField!
    @IBOutlet weak var idElement: UITextField!
    
    var workerData: [String: String]!
    var oldWorkerData: [String: String]!
    var selfLevel: String!
    
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
        }
        
        idElement.text = workerData["identifier"]
        levelElement.text = "\(workerData["accessLevel"]!)*"
        levelElement.isEnabled = false
        levelStepperElement.value = Double(workerData["accessLevel"]!)!
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
                    self.delegate?.needsToUpdateList()
                }
            }
        }
    }
}
