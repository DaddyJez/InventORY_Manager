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
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var passwordElement: UITextField!
    @IBOutlet weak var loginElement: UITextField!
    @IBOutlet weak var levelElement: UITextField!
    @IBOutlet weak var idElement: UITextField!
    
    var workerData: [String: String]!
    var selfLevel: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
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
                levelElement.isEnabled = true
                idElement.isEnabled = true
            } else {
                loginElement.isEnabled = false
                passwordElement.isEnabled = false
                levelElement.isEnabled = false
                idElement.isEnabled = false
            }
        } else {
            passwordElement.text = "******"
            passwordElement.isEnabled = false
            
            loginElement.text = "******"
            loginElement.isEnabled = false
            
            levelElement.isEnabled = false
            idElement.isEnabled = false
        }
        
        idElement.text = workerData["identifier"]
        levelElement.text = workerData["accessLevel"]
    }
}
