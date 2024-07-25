//
//  FaceMaskDetailViewCellViewController.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/24.
//

import UIKit

class FaceMaskDetailViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var maskAdNumLabel: UILabel!
    @IBOutlet var maskCnNumLabel: UILabel!
    
    var faceMaskData: FaceMask!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = faceMaskData.name
        phoneLabel.text = "電話: \(faceMaskData.phone)"
        addressLabel.text = "地址: \(faceMaskData.address)"
        maskAdNumLabel.text = "成人口罩: \(faceMaskData.mask_adult) 個"
        maskCnNumLabel.text = "小孩口罩: \(faceMaskData.mask_child) 個"
    }

}
