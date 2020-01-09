//
//  NotificationImporter.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/10.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

class NotificationImporter: Operation
{
    var progressBlock: importProgressCallBack?
    //main managed object context
    let mainManagedObjectContext: NSManagedObjectContext
    //private managed object context
    var privateQueueManagedObjectContext:NSManagedObjectContext!
    //json filename to import
    let fileNameString: String
    init(context:NSManagedObjectContext, fileName: String) {
        self.mainManagedObjectContext = context
        self.fileNameString =  fileName
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
    
    //main
    override func main() {
        //1.
        if isCancelled {
            return
        }
        NotificationCenter.default.addObserver(self, selector:#selector(didSaveNotificationOnPrivateQueue(notiofication:)), name:NSNotification.Name.NSManagedObjectContextDidSave , object: nil)
        //2.
        self.privateQueueManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        //3. Set persistentStoreCoordinator
        self.privateQueueManagedObjectContext.persistentStoreCoordinator = self.mainManagedObjectContext.persistentStoreCoordinator
        //4.
        self.privateQueueManagedObjectContext.undoManager = nil
        //5.
        self.privateQueueManagedObjectContext.performAndWait {
            _ = Constants.TimeConstant.TICK
            self.importData()
            print("Total elapsed time Notification import is: \(Constants.TimeConstant.TOCK)")
        }
    }
    
    //MARK:- Import Data
    fileprivate func importData() {
        if let object = try? DataModel.fromJSON("jsonData") as [DataModel]? {
            //1.
            let totalCount = object.count
            let progressCounter = totalCount/100

            var counter = 0
            //2.
            for item in object {
                if isCancelled {
                    finish(true)
                    break
                }
                counter += 1
                _ = DataEntity.importData(from: item, in: self.privateQueueManagedObjectContext)
                if counter%progressCounter == 0
                {
                    self.saveProgress(progress: Float(counter)/Float(totalCount))
                }
                
                if counter%(Constants.BatchSizeConstants.SaveBatchSize) == 0
                {
                    self.saveInBatch()
                }
            }
        }
    }
    
    //MARK:- Batch Saving
    fileprivate func saveInBatch()
    {
        if self.privateQueueManagedObjectContext.hasChanges {
            do {
                try self.privateQueueManagedObjectContext.save()
            }
            catch let error as NSError
            {
                print("error is : \(error.localizedDescription)")
            }
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
    
    //ManageObjectContext Save Notiofication
    @objc func didSaveNotificationOnPrivateQueue(notiofication : NSNotification)
    {
        let queue = DispatchQueue(label: "messages.queue", attributes: .concurrent)
        queue.sync(flags: .barrier){
            self.mainManagedObjectContext.mergeChanges(fromContextDidSave: notiofication as Notification)
        }
    }
}
