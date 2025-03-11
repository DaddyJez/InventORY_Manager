//
//  ItemLocationCell.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 08.03.2025.
//

import Foundation
import UIKit

class ItemLocationCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cabinetLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    
    var item: LocationItem?
    var userLevel: Int?
    
    weak var delegate: StorageControllerDelegate?
    weak var locationDelegate: LocationControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: LocationItem, userLevel: Int) {
        self.item = item
        
        nameLabel.text = "(\(item.rowid)) \(item.storage!.name)"
        cabinetLabel.text = "\(item.cabinet)"
        
        if item.condition {
            conditionLabel.text = "✅"
        } else {
            conditionLabel.text = "❌"
        }
        
        if userLevel >= 3 {
            DispatchQueue.main.async {
                let interaction = UIContextMenuInteraction(delegate: self)
                self.addInteraction(interaction)
            }
        }
    }
}
extension ItemLocationCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let relocateAction = UIAction(title: "Relocate", image: UIImage(systemName: "info.triangle")) { [weak self] _ in
                print("delegate to be next")
                guard let self = self else { return }
                
                self.locationDelegate?.didLocatedItem(rowData: item!)
                self.delegate?.updateTable()
                }

            return UIMenu(title: "", children: [relocateAction])
        }
    }
}
