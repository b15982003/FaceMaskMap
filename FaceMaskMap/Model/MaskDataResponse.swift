//
//  MaskData.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/21.
//

import Foundation

struct MaskDataResponse: Codable {
    var type: String = ""
    var features: [Features]
}

struct Features: Codable {
    var type: String = ""
    var properties: Properties
    var geometry: Geometry
}

struct Properties: Codable {
    var id: String = ""
    var name: String = ""
    var phone: String = ""
    var address: String = ""
    var updated: String = ""
    var available: String = ""
    var note: String = ""
    var custom_note: String = ""
    var website: String = ""
    var county: String = ""
    var town: String = ""
    var cunli: String = ""
    var service_periods = ""
    var mask_adult: Int64 = 0
    var mask_child: Int64 = 0
}

struct Geometry: Codable {
    var type: String
    var coordinates: [Double]
}


