////
////  CoreDataHandler.swift
////  FaceMaskMap
////
////  Created by 張睿平 on 2024/7/22.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//class CoreDataHandler: NSObject {
//    static let shared = CoreDataHandler()
//
//    private var persistentContainer: NSPersistentContainer!
//
//    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext
//
//    lazy var backgroundContext: NSManagedObjectContext = persistentContainer.newBackgroundContext()
//
//    func start(completion: @escaping () -> Void) {
//        let container = PersistentContainer(name: "FaceMaskMap")
//        container.loadPersistentStores { _, error in
//            guard error == nil else { fatalError("Failed to load store: \(error!)") }
//            DispatchQueue.main.async {
//                container.viewContext.automaticallyMergesChangesFromParent = true
//                self.persistentContainer = container
//                completion()
//            }
//        }
//    }
//
//    func createBackup(filename: String, didBackupHandler: (TemporaryFile) -> Void) {
//        do {
//            let backupFile = try persistentContainer.persistentStoreCoordinator.backupPersistentStore(atIndex: 0, filename: filename)
//            defer {
//                // Delete temporary directory when done
//                try? backupFile.deleteDirectory()
//            }
//            print("The backup is at \"\(backupFile.fileURL.path)\"")
//            didBackupHandler(backupFile)
//        } catch {
//            print("Error backing up Core Data store: \(error)")
//        }
//    }
//}
//
//protocol NSManagedObjectType {
//    static var entityName: String { get }
//}
//
//enum StackResult {
//    case error(String)
//    case success
//
//    func getErrorMessage() -> String? {
//        switch self {
//        case .success:
//            return nil
//        case let .error(message):
//            return message
//        }
//    }
//}
//
//// MARK: - NSManagedObjectContext extension
//
//extension NSManagedObjectContext {
//    func insertObject<T: NSManagedObject>() -> T where T: NSManagedObjectType {
//        guard let obj = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else {
//            fatalError("Entity \(T.entityName) does not correspond to \(T.self)")
//        }
//
//        return obj
//    }
//
//    func saveContext() {
//        performAndWait {
//            if self.hasChanges {
//                do {
//                    try self.save()
//                } catch {
//                    let nsError = error as NSError
//
//                    if nsError.code == 133_020 || nsError.code == 133_021 {
//                        self.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//                        self.saveContext()
//                    }
//
//                    print("Failed to save to data store \(nsError.localizedDescription), code = \(nsError.code)")
//
//                    let detailErrors = nsError.userInfo[NSDetailedErrorsKey] as? NSArray
//
//                    if let tempErrors = detailErrors, tempErrors.count > 0 {
//                        for error in tempErrors {
//                            if let tempError = error as? NSError {
//                                print("save to data failed \(tempError.userInfo)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
