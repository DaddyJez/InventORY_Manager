//
//  WorkerTableViewCell.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 10.03.2025.
//

import Foundation
import UIKit

class WorkerTableViewCell: UITableViewCell {
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var imageEl: UIButton!
    
    private var selfId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with data: [String: String], selfId: String) {
        self.idLabel.text = data["identifier"]
        self.nameLabel.text = data["name"]
        self.levelLabel.text = data["accessLevel"]
        self.selfId = selfId
        
        if selfId == data["identifier"]! {
            if data["accessLevel"] == "5" {
                imageEl.setImage(UIImage(systemName: "person.badge.key"), for: .normal)
            } else {
                imageEl.setImage(UIImage(systemName: "person"), for: .normal)
            }
        } else if data["accessLevel"] == "5" {
            imageEl.setImage(UIImage(systemName: "person.badge.key.fill"), for: .normal)
        } else {
            imageEl.setImage(UIImage(systemName: "person.fill"), for: .normal)
        }
    }
}
