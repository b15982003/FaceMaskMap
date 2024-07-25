//
//  CoreDataHandler.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/22.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    static let shared = CoreDataHelper()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = mainManagedObjectContext
        return privateContext
    }()
    
    private func saveMainContext() {
        if mainManagedObjectContext.hasChanges {
            do {
                try mainManagedObjectContext.save()
            } catch {
                print("Error saving main managed object context: \(error)")
            }
        }
    }
    
    private func savePrivateContext() {
        if privateManagedObjectContext.hasChanges {
            do {
                try privateManagedObjectContext.save()
            } catch {
                print("Error saving private managed object context: \(error)")
            }
        }
    }
    
    private func saveChanges() {
        savePrivateContext()
        mainManagedObjectContext.performAndWait {
            saveMainContext()
        }
    }
    
    func saveData<T: NSManagedObject>(objects: [T]) {
        privateManagedObjectContext.perform {
            // Insert the objects into the private context
            for object in objects {
                self.privateManagedObjectContext.insert(object)
            }
            
            // Save changes to the private context and merge to the main context
            self.saveChanges()
        }
    }
    
    func deleteData<T: NSManagedObject>(objects: [T]) {
        privateManagedObjectContext.perform {
            // Delete the objects from the private context
            for object in objects {
                if object.managedObjectContext == self.privateManagedObjectContext {
                    self.privateManagedObjectContext.delete(object)
                } else {
                    if let objectInContext = self.privateManagedObjectContext.object(with: object.objectID) as? T {
                        self.privateManagedObjectContext.delete(objectInContext)
                    }
                }
            }
            
            self.saveChanges()
        }
    }
}

protocol NSManagedObjectType {
    static var entityName: String { get }
}

enum StackResult {
    case error(String)
    case success

    func getErrorMessage() -> String? {
        switch self {
        case .success:
            return nil
        case let .error(message):
            return message
        }
    }
}

// MARK: - NSManagedObjectContext extension

extension NSManagedObjectContext {
    func insertObject<T: NSManagedObject>() -> T where T: NSManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else {
            fatalError("Entity \(T.entityName) does not correspond to \(T.self)")
        }

        return obj
    }

    func saveContext() {
        performAndWait {
            if self.hasChanges {
                do {
                    try self.save()
                } catch {
                    let nsError = error as NSError

                    if nsError.code == 133_020 || nsError.code == 133_021 {
                        self.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                        self.saveContext()
                    }

                    print("Failed to save to data store \(nsError.localizedDescription), code = \(nsError.code)")

                    let detailErrors = nsError.userInfo[NSDetailedErrorsKey] as? NSArray

                    if let tempErrors = detailErrors, tempErrors.count > 0 {
                        for error in tempErrors {
                            if let tempError = error as? NSError {
                                print("save to data failed \(tempError.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
}
