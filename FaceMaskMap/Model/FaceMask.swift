//
//  MaskData.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/22.
//

import Foundation
import CoreData
import UIKit

public class FaceMask: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FaceMask> {
        return NSFetchRequest<FaceMask>(entityName: "FaceMask")
    }
    
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var phone: String
    @NSManaged public var address: String
    @NSManaged public var mask_adult: Int64
    @NSManaged public var mask_child: Int64
    @NSManaged public var updated_date: String
    @NSManaged public var available: String
    @NSManaged public var note: String
    @NSManaged public var custom_note: String
    @NSManaged public var website: String
    @NSManaged public var county: String
    @NSManaged public var town: String
    @NSManaged public var cunli: String
    @NSManaged public var service_periods: String
    @NSManaged public var coordinates_lat: Double
    @NSManaged public var coordinates_lng: Double
}

extension FaceMask {
    
    static func setFaskMaskListFromServer(_ json: [Features], context: NSManagedObjectContext) {
        context.performAndWait {
            var faceMaskData: FaceMask
            
            for faceMask in json {
                faceMaskData = FaceMask(context: context)
                faceMaskData.id = faceMask.properties.id
                faceMaskData.name = faceMask.properties.name
                faceMaskData.phone = faceMask.properties.phone
                faceMaskData.address = faceMask.properties.address
                faceMaskData.mask_adult = faceMask.properties.mask_adult
                faceMaskData.mask_child = faceMask.properties.mask_child
                faceMaskData.updated_date = faceMask.properties.updated
                faceMaskData.available = faceMask.properties.available
                faceMaskData.note = faceMask.properties.note
                faceMaskData.custom_note = faceMask.properties.custom_note
                faceMaskData.website = faceMask.properties.website
                faceMaskData.county = faceMask.properties.county
                faceMaskData.town = faceMask.properties.town
                faceMaskData.cunli = faceMask.properties.cunli
                faceMaskData.service_periods = faceMask.properties.service_periods
                faceMaskData.coordinates_lat = faceMask.geometry.coordinates[0]
                faceMaskData.coordinates_lng = faceMask.geometry.coordinates[1]
                guard let _ = try? context.save() else { return }     
            }
        }
    }
    
    static func deleteFaceMaskList(_ context: NSManagedObjectContext) {
        context.performAndWait {
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<FaceMask>(entityName: "FaceMask")
                do {
                    let results = try context.fetch(request)
                    for result in results {
                        context.delete(result)
                        appDelegate.saveContext()
                    }
                } catch {
                    fatalError("Could not fetch. \(error)")
                }
            }
        }
    }
}
