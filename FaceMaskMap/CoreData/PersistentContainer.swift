//
//  PersistentContainer.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/22.
//

import Foundation
import CoreData
import UIKit

final class PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex - 1]
        return docURL
    }
}
