//
//  FaceMaskTableTableViewController.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/23.
//

import UIKit
import CoreData

class FaceMaskTableViewController: UITableViewController {
    
    lazy var dataSource = configureDataSource()
    var faceMaskList: [FaceMask] = []
    var fetchResultController: NSFetchedResultsController<FaceMask>!
    var countries: [String] = []
    
    let screenWith = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 7
    var selectRow = 0
    var selectitem = ""
    
    var refresh = UIRefreshControl()
    
    @IBOutlet var btnPickerView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = refresh
        self.refreshControl?.attributedTitle = NSAttributedString(string: "refresh")
        self.refreshControl?.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl!)

        fetchMaskData()
    }
   
    // MARK: - 下拉做事
    @objc func loadData(){
        callFaceMaskListAPI()
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
            
            // 確認有沒有資料
            guard let request = fetchResultController.fetchedObjects, request.isEmpty == false else {
                callFaceMaskListAPI()
                return
            }
        
            faceMaskList = request
            upDateSelectItem()
        }
    }
    
    private func callFaceMaskListAPI() {
        NetworkController.shared.getMaskListNetworkRequest()
        NetworkController.shared.addDelegate(self)
    }
    
    // MARK: - 更新 UI
    func updateSnapshot(animatingChange: Bool = false) {
        //  確認控制器中是否有包含所有的讀取物件
        print(self.selectitem)
        print(self.selectitem.isEmpty)
        if self.selectitem.isEmpty || self.selectitem.contains("全部"){
            if let fetcheckObjects = fetchResultController.fetchedObjects {
                faceMaskList = fetcheckObjects
            }
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
    
    // MARK: - 更新快速搜尋清單
    func upDateSelectItem(){
        countries.removeAll()
        countries.append("全部")
        for faceMask in faceMaskList {
            if !countries.contains(faceMask.county) && !faceMask.county.isEmpty{
                countries.append(faceMask.county)
            }
        }
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
    
    @IBAction func popUpPicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWith, height: screenHeight)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWith / 2, height: screenHeight))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(selectRow, inComponent: 0, animated: false)
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "選擇區域", message: "", preferredStyle: .alert)
        alert.popoverPresentationController?.sourceView = btnPickerView
        alert.popoverPresentationController?.sourceRect = btnPickerView.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectRow = pickerView.selectedRow(inComponent: 0)
            self.selectitem = self.countries[self.selectRow]
            self.btnPickerView.setTitle(self.selectitem, for: .normal)
            self.faceMaskList = self.faceMaskList.filter({ $0.county.contains(self.selectitem)})
            self.updateSnapshot(animatingChange: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension FaceMaskTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

extension FaceMaskTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWith, height: screenHeight))
        label.text = countries[row]
        label.sizeToFit()
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}

extension FaceMaskTableViewController: NetworkControllerDelegate {
    func completedNetworkRequest(_ requestClassName: String, response: Data?, error: NSError?) {
        print("API Success")
        NetworkController.shared.removeDelegate(self)
        DispatchQueue.main.sync {
            if self.refreshControl?.isRefreshing == true {
                self.refreshControl?.endRefreshing()
            }
        }
    }
}

enum Section {
    case all
}
