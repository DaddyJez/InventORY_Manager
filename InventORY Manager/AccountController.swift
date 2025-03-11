//
//  AccountController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import Foundation
import UIKit

class AccountController {
    private var userData: [String: String]
    private var infoLabel: UILabel
    private var controller: UIViewController
    private var delegate: AccountControllerDelegate?
    
    init(userData: [String: String], infoLabel: UILabel, controller: UIViewController, delegate: AccountControllerDelegate) {
        self.userData = userData
        self.infoLabel = infoLabel
        self.controller = controller
        self.delegate = delegate
        
        setupUI()
    }
    
    @MainActor
    func proceedLogout() {
        let alertController = UIAlertController(
            title: "Are U sure?",
            message: "Want to log out?",
            preferredStyle: .alert
        )
        
        let proceedAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.userData = [:]
            UserDefaultsManager.shared.clearUserData()
            
            self.delegate?.didLogout()
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alertController.addAction(proceedAction)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func proceedChangeName() {
        let alertController = UIAlertController(
            title: "Change name",
            message: "Type new name",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "New name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                Task { [weak self] in
                    guard let self = self else { return }
                    
                    let success = await SupabaseManager.shared.updateUserName(newName: newName, oldData: userData)
                    
                    if success {
                        print("Успешное изменение имени")
                        self.userData["name"] = newName
                        await self.delegate?.didChangeName()
                        
                        DispatchQueue.main.async {
                            self.setupUI()
                        }
                    } else {
                        print("Не удалось изменить имя")
                    }
                }
            } else {
                print("Имя не может быть пустым")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    private func setupUI() {
        infoLabel.text = """
        Name: \(String(describing: self.userData["name"]!))
        Identifier: \(String(describing: self.userData["identifier"]!))
        Access level: \(String(describing: self.userData["accessLevel"]!))
        """
    }
}
