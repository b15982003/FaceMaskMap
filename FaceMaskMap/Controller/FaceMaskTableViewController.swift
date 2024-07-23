//
//  FaceMaskTableTableViewController.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/23.
//

import UIKit
import CoreData

class FaceMaskTableViewController: UITableViewController {
    
    var faceMaskList: [FaceMask] = []
    var fetchResultController: NSFetchedResultsController<FaceMask>!
    lazy var dataSource = configureDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        fetchMaskData()
    }
    
    func fetchData() {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
            let fetchRequest: NSFetchRequest<FaceMask> = FaceMask.fetchRequest()
            guard let request = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest), request.isEmpty == false else { return }
            print("requestData = \(request.count)" )
            faceMaskList = request
        }
//        NetworkController.shared.getMaskListNetworkRequest()
    }
    
    // MARK: - 資料庫拿資料
    func fetchMaskData() {
        // 從資料庫取得資料
        let fetchRequest: NSFetchRequest<FaceMask> = FaceMask.fetchRequest()
        
        // 排序
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                updateSnapshot()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - 更新 UI
    func updateSnapshot(animatingChange: Bool = false) {
        //  確認控制器中是否有包含所有的讀取物件
        if let fetcheckObjects = fetchResultController.fetchedObjects {
            faceMaskList = fetcheckObjects
        }
        
        // 建立快照並填入資料
        var snapshot = NSDiffableDataSourceSnapshot<Section, FaceMask>()
        snapshot.appendSections([.all])
        snapshot.appendItems(faceMaskList, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, FaceMask> {
        let cellIdentifier = "dataCell"
        
        let dataSource = UITableViewDiffableDataSource<Section, FaceMask>(
            tableView: tableView) { tableView, indexPath, faceMask in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FaceMaskTableViewCell
                
                cell.countryLabel.text = "\(faceMask.county) - \(faceMask.town) - \(faceMask.cunli)"
                cell.nameLabel.text = faceMask.name
                cell.phoneLabel.text = faceMask.phone
                cell.maskAdNumLabel.text = "成人：\(String(faceMask.mask_adult))"
                cell.maskChNumLabel.text = "小孩：\(String(faceMask.mask_child))"
                cell.dateLabel.text = faceMask.updated_date
                
                return cell
            }
        return dataSource
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return faceMaskList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    // MARK: - 刪除資料
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let faceMask = self.dataSource.itemIdentifier(for: indexPath) else {
            return UISwipeActionsConfiguration()
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext

                context.delete(faceMask)
                appDelegate.saveContext()
                
                self.updateSnapshot(animatingChange: true)
            }

            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
            
        return swipeConfiguration
    }
}

extension FaceMaskTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

enum Section {
    case all
}
