//
//  NetworkRequestOperation.swift
//  FaceMaskMap
//
//  Created by 張睿平 on 2024/7/21.
//

import Foundation
import CoreData

class NetworkRequestOperation: Operation {
    
    var data: Data?
    var error: NSError?
    var context: NSManagedObjectContext?

    private var innerContext: NSManagedObjectContext?
    private var task: URLSessionTask?
    private let incomingData = NSMutableData()
    private var session: Foundation.URLSession?

    var internalFinished: Bool = false
    
    func initSession(_ url: URL, method: String) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        let urlconfig = URLSessionConfiguration.default
        session = Foundation.URLSession(configuration: urlconfig,delegate: self,delegateQueue: nil)
        task = session!.dataTask(with: request as URLRequest)
    }
    
    override func main() {
        guard let task = task else {
            return
        }
        task.resume()
    }
    
    override var isFinished: Bool {
        get {
            return internalFinished
        }
        set (newAnswer) {
            willChangeValue(forKey: "isFinished")
            internalFinished = newAnswer
            didChangeValue(forKey: "isFinished")
        }
    }
    
    func success(_ data: Data) {
        self.data = data
    }
    
    func failure(_ error: NSError, _ data: Data) {
        self.error = error
        self.data = data
    }
}

extension NetworkRequestOperation:  URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_: Foundation.URLSession,
                    dataTask _: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (Foundation.URLSession.ResponseDisposition) -> Void) {
        
        if isCancelled {
            isFinished = true
            task!.cancel()
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode != 200 {
            return
        }
        
        completionHandler(.allow)
    }
    
    func urlSession(_: Foundation.URLSession,dataTask _: URLSessionDataTask,didReceive data: Data) {

        if isCancelled {
            isFinished = true
            task!.cancel()
            return
        }

        incomingData.append(data)
    }
    
    func urlSession(_: URLSession,task: URLSessionTask,didCompleteWithError error: Error?){

        if isCancelled {
           isFinished = true
           task.cancel()
           return
       }

        if error != nil {
            failure(error! as NSError, incomingData as Data)
        } else if !isFinished {
            success(incomingData as Data)
        }
        
        session?.finishTasksAndInvalidate()
        isFinished = true
   }
}
