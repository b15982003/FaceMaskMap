//
//  MaskData.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/21.
//

import Foundation

struct MaskData: Hashable {
    var type: String = ""
    var properties: Properties
    var geometry: Geometry
}

struct Properties: Hashable {
    var id: String = ""
    var name: String = ""
    var phone: String = ""
    var address: String = ""
    var mask_adult: Int = 0
    var mask_child: Int = 0
    var updated: Data
    var available: String = ""
    var note: String = ""
    var custom_note: String = ""
    var website = ""
    var county = ""
    var town = ""
    var cunli = ""
    var service_periods = ""
}

struct Geometry: Hashable {
    var type: String
    var coordinates: [String]
}
