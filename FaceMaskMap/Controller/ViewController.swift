//
//  ViewController.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                try await fetchData()
            } catch {
                print(error)
            }
        }
    }
    
    func fetchData() async throws {
        NetworkController.shared.getMaskListNetworkRequest()
    }
}

