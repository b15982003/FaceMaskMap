//
//  FaceMaskTableViewCell.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/23.
//

import UIKit

class FaceMaskTableViewCell: UITableViewCell {

    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var maskAdNumLabel: UILabel!
    @IBOutlet var maskChNumLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
