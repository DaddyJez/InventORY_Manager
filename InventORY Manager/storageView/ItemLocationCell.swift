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
        self.userLevel = userLevel
        
        nameLabel.text = "(\(item.rowid)) \(item.storage!.name)"
        cabinetLabel.text = "\(item.cabinet)"
        
        if item.condition {
            conditionLabel.text = "✅"
        } else {
            conditionLabel.text = "❌"
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
}
extension ItemLocationCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let cabinetInfoAction = UIAction(title: "See Cabinet", image: UIImage(systemName: "info.triangle")) { [weak self] _ in
                guard let self = self else { return }
                
                self.delegate?.didTapToSeeCabinets(cabinetNum: item!.cabinet)
            }
            
            if self.userLevel! >= 3 {
                let relocateAction = UIAction(title: "Relocate", image: UIImage(systemName: "info.triangle")) { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.locationDelegate?.didLocatedItem(rowData: item!)
                    self.delegate?.updateTable()
                }
                return UIMenu(title: "", children: [relocateAction, cabinetInfoAction])
            } else {
                return UIMenu(title: "", children: [cabinetInfoAction])
            }

            
        }
    }
}
