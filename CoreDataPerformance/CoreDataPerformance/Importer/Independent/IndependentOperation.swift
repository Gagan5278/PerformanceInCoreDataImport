//
//  IndependentOperation.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/13.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData
class IndependentOperation: Operation {
    var progressBlock: importProgressCallBack?
    let persistentStack: PersistentStack!
    let fileName: String!
    var managedObjectContext: NSManagedObjectContext!
    init(stack:PersistentStack, fileName: String ) {
        self.persistentStack = stack
        self.fileName = fileName
    }
    
    private var _executing = false {
           willSet {
               willChangeValue(forKey: "isExecuting")
           }
           didSet {
               didChangeValue(forKey: "isExecuting")
           }
       }
       
       override var isExecuting: Bool {
           return _executing
       }
       
       private var _finished = false {
           willSet {
               willChangeValue(forKey: "isFinished")
           }
           
           didSet {
               didChangeValue(forKey: "isFinished")
           }
       }
       
       override var isFinished: Bool {
           return _finished
       }
       
       func executing(_ executing: Bool) {
           _executing = executing
       }
       
       func finish(_ finished: Bool) {
           _finished = finished
       }
    
    override func main() {
        //1. Worst case: Main Queue Context with find-or-create algorithm.
            self.managedObjectContext = self.persistentStack.managedObjectContext
            self.managedObjectContext.undoManager = nil
            self.managedObjectContext.performAndWait {[weak self] in
                self?.importData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationConstants.notificationImportOperationCompleted), object: nil, userInfo: nil)
            }
    }
    
    //MARK: 1
    fileprivate func importData() {
        if let object = try? DataModel.fromJSON("jsonData") as [DataModel]? {
            //1.
             let totalCount = object.count
             let progressCounter = totalCount/100
            var counter = 0
            for item in object {
                if self.isCancelled {
                    self.finish(true)
                    return
                }
                counter += 1
                _ = DataEntity.importData(from: item, in: self.managedObjectContext)
                if counter%progressCounter == 0
                {
                    self.saveProgress(progress: Float(counter)/Float(totalCount))
                }
                
                if counter%(Constants.BatchSizeConstants.SaveBatchSize) == 0
                {
                    self.saveManagedObjectContext()
                }
            }
        }
    }
    
    //MARK:- Saved notification
    fileprivate func saveManagedObjectContext() {
        do {
            try self.managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
    
    //MARK:- Save Progress
    func saveProgress(progress : Float)
    {
        if (progressBlock != nil)
        {
            self.progressBlock?(progress)
        }
    }
}
