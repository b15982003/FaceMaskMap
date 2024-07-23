//
//  ViewController.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() {
        // 從資料庫取得資料
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
            let fetchRequest: NSFetchRequest<FaceMask> = FaceMask.fetchRequest()
            guard let request = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest), request.isEmpty == false else { return }
            print("requestData = \(request.count)" )
        }
//        NetworkController.shared.getMaskListNetworkRequest()
    }
}

