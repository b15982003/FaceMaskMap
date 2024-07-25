//
//  MaskListNetworkRequest.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/21.
//

import Foundation
import UIKit

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
        var result: MaskDataResponse?
        do {
            result = try JSONDecoder().decode(MaskDataResponse.self, from: data)
        } catch {
            print("Fail \(error.localizedDescription)")
        }
        
        guard let json = result else {
            return
        }
        
        DispatchQueue.main.async {
            let context = CoreDataHelper.shared.mainManagedObjectContext
            FaceMask.deleteFaceMaskList(context)
            FaceMask.setFaskMaskListFromServer(json.features , context: context)
        }
    }

    override func failure(_ error: NSError, _ data: Data) {
        super.failure(error, data)
    }
}
