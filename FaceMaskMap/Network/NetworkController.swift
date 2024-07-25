//
//  NetworkController.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/21.
//

import Foundation
import CoreData

protocol NetworkControllerDelegate: AnyObject {
    func completedNetworkRequest(_ requestClassName: String, response: Data?, error: NSError?)
}

class NetworkController: NSObject {
    static let shared: NetworkController = {
        let instance = NetworkController()
        return instance
    }()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "netqueue"
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
    
    private let observationOperationsQueue = DispatchQueue(label: "com.FaceMask.observationOperations")
    
    private var observationOperations: [NSObject] = []
    
    var delegates: [NetworkControllerDelegate] = []
    
    func addDelegate(_ delegate: NetworkControllerDelegate) {
        delegates.append(delegate)
    }

    func removeDelegate(_ delegate: NetworkControllerDelegate) {
        delegates = delegates.filter { $0 !== delegate }
    }

    private func addObservationOperation(_ operation: NSObject) {
        operation.addObserver(self, forKeyPath: "isFinished", options: .new, context: nil)
        observationOperationsQueue.sync {
            observationOperations.append(operation)
        }
    }

    private func removeObservationOperation(_ operation: NSObject) {
        operation.removeObserver(self, forKeyPath: "isFinished")
        observationOperationsQueue.sync {
            observationOperations = observationOperations.filter { $0 !== operation }
        }
    }
    
    var mainContext: NSManagedObjectContext?

//    func requestMyData() -> NSFetchedResultsController<NSFetchRequestResult> {
//        let cacheManager = CacheManager()
//        return cacheManager.getCacheFRC("testImage")
//    }

    func requestMyData(completion: () -> Bool) {
        
    }
    
    private func addOperationToQueue(_ operation: NetworkRequestOperation) {
        if queue.operations.contains(operation) {
            print("API request is Exist")
        } else {
            queue.addOperation(operation)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let operation = (object as? NetworkRequestOperation)!
        removeObservationOperation(operation)
        let className = String(describing: type(of: operation))

        for delegate in delegates {
            delegate.completedNetworkRequest(className,response: operation.data as Data?,error: operation.error)
        }
    }
}

extension NetworkController {
    func getMaskListNetworkRequest() {
        let operation = MaskListNetworkRequest()
        addObservationOperation(operation)
        addOperationToQueue(operation)
    }
}
