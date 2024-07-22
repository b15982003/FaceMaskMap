//
//  MaskListNetworkRequest.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/21.
//

import Foundation

class MaskListNetworkRequest: NetworkRequestOperation {
    
    override init() {
        super.init()
        let maskListURLString = "https://raw.githubusercontent.com/kiang/pharmacies/master/json/points.json"
        let maskListURLStringURL = URL(string: maskListURLString)!
        print("1")
        initSession(maskListURLStringURL, method: "GET")
    }

    override func success(_ data: Data) {
        super.success(data)
        
        var result: MaskData?
        
        do {
            result = try JSONDecoder().decode(MaskData.self, from: data)
        } catch {
            print("Fail \(error.localizedDescription)")
        }
        
        guard let json = result else {
            return
        }
        
        print(json.features[0].properties.name)
    }

    override func failure(_ error: NSError, _ data: Data) {
        super.failure(error, data)
    }
}
