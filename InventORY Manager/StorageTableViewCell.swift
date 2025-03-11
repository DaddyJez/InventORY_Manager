//
//  StorageTableViewCell.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 07.03.2025.
//

import Foundation

import UIKit

class StorageTableCell: UITableViewCell {
    @IBOutlet weak var imageLabel: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantLabel: UILabel!
    @IBOutlet weak var identLabel: UILabel!
    
    weak var delegate: StorageControllerDelegate?
    
    var rowData: [String: String]!
    
    var userLevel: Int!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with data: [String: String]) {
        self.rowData = data
        
        DispatchQueue.main.async {
            if self.userLevel > 3 {
                let interaction = UIContextMenuInteraction(delegate: self)
                self.addInteraction(interaction)
            }
        }
        
        nameLabel.text = data["name"]
        quantLabel.text = data["quantity"]
        
        switch data["category"] {
        case "Computers":
            imageLabel.setImage(UIImage(systemName: "desktopcomputer.and.macbook"), for: .normal)
        case "Monitors":
            imageLabel.setImage(UIImage(systemName: "desktopcomputer"), for: .normal)
        case "Printers":
            imageLabel.setImage(UIImage(systemName: "printer.fill"), for: .normal)
        case "Storage":
            imageLabel.setImage(UIImage(systemName: "externaldrive.fill"), for: .normal)
        case "Switches":
            imageLabel.setImage(UIImage(systemName: "xserve"), for: .normal)
        case "Mice":
            imageLabel.setImage(UIImage(systemName: "computermouse.fill"), for: .normal)
        case "Keyboards":
            imageLabel.setImage(UIImage(systemName: "keyboard.fill"), for: .normal)
        case "Routers":
            imageLabel.setImage(UIImage(systemName: "wifi"), for: .normal)
        case "Laptops":
            imageLabel.setImage(UIImage(systemName: "laptopcomputer"), for: .normal)
        case "Servers":
            imageLabel.setImage(UIImage(systemName: "server.rack"), for: .normal)
        default:
            imageLabel.setImage(UIImage(systemName: "personalhotspot.slash"), for: .normal)
        }
        
        if data["fullyIdentified"] == "true" {
            identLabel.text = "✅"
        } else {
            identLabel.text = "❌"
        }
    }
}

extension StorageTableCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let deleteAction = UIAction(title: "Remove", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                Task {
                    if await Server.shared.deleteFromStorage(articul: self.rowData["articul"]!) {
                        self.delegate?.updateTable()
                    }
                }
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }
}
