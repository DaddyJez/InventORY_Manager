//
//  CabinetsInfoController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 17.03.2025.
//

import Foundation
import UIKit

class CabinetsInfoController: UIViewController {
    @IBOutlet weak var cabunetNumLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var cabinetData: [String: String]!
    var cabinetNum: Int!
    var selfData: [String: String]!
    
    weak var delegate: CabinetsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        if self.cabinetData != nil {
            self.cabunetNumLabel.text = "\(cabinetData["cabinetNum"]!) Cabinet"
            self.descriptionLabel.text = """
            Responsible: \(cabinetData["responsibleName"]!) (\(cabinetData["responsible"]!))
            Floor: \(cabinetData["floor"]!)
            
            Items:
            """
        } else if cabinetNum != nil {
            // cabinetData = 
            configure()
        }
    }
}
