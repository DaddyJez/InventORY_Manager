//
//  StorageJournalTableViewCell.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 26.03.2025.
//

import Foundation
import UIKit

class StorageJournalTableViewCell: UITableViewCell {
    
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var quantCostLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var workerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with info: StorageJournalModel) {
        if info.cost != 0 {
            if info.quantity > 1 {
                quantCostLabel.text = "Quant.: \(info.quantity), cost: \(info.cost) $"
            } else {
                quantCostLabel.text = "Cost: \(info.cost) $"
            }
        } else {
            if info.quantity > 1 {
                quantCostLabel.text = "Quant.: \(info.quantity)"
            } else {
                quantCostLabel.text = ""
            }
        }
        
        // else
        typeLabel.text = info.type
        productNameLabel.text = "(\(info.itemArticul)) \(info.storage!.name)"
        workerNameLabel.text = "By \(info.users!.name) (\(info.personalName))"
        
        let timeFormatted = formatTimestamp(info.created_at)
        dateTimeLabel.text = timeFormatted
    }
    
    // time parsing
    func formatTimestamp(_ input: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yyyy // HH:mm"
        outputFormatter.timeZone = TimeZone.current

        guard let date = inputFormatter.date(from: input) else {
            return nil
        }
        return outputFormatter.string(from: date)
    }
}
