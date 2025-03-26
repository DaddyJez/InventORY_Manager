//
//  StorageJournalViewController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 26.03.2025.
//

import Foundation
import UIKit

class StorageJournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var tableData: [StorageJournalModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Task {
            self.tableData = await Server.shared.fetchStorageJournal()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageJournalTableViewCell", for: indexPath) as! StorageJournalTableViewCell
        
        cell.configure(with: tableData[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
