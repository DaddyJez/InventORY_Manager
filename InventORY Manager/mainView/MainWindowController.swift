//
//  MainWindowController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 26.03.2025.
//

import Foundation
import UIKit

class MainWindowController {
    private var dropdownWithJournals: UIButton
    
    /*
     TODO: adding:
     delegate
     tableview
     prototype cell
     
     initializer
     setup(er)
     */
    
    init(dropdownWithJournals: UIButton) {
        self.dropdownWithJournals = dropdownWithJournals
        
        self.configureDropDown()
    }
    
    private func configureDropDown() {
        let items = ["Storage", "Workers"]
        var actions = [UIAction]()
        let image = UIImage(systemName: "list.clipboard")!
                
        for item in items {
            let action = UIAction(title: item, image: image) { [weak self] _ in
                self?.handleActionSelection(item: item)
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Chose journal", children: actions)
        
        self.dropdownWithJournals.menu = menu
        self.dropdownWithJournals.showsMenuAsPrimaryAction = true
    }
    
    private func handleActionSelection(item: String) {
        print(item)
    }
}
