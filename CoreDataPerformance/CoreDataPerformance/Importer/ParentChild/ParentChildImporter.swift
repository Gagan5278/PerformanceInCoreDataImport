//
//  PareentChildImporter.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

class ParentChildImporter: Operation {
    var progress: importProgressCallBack?
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
    
    //MARK:- Main
    override func main() {
        //1.
        self.privateQueueManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        //2. Set Parent
        self.privateQueueManagedObjectContext.parent = self.mainManagedObjectContext
        //3.
        self.privateQueueManagedObjectContext.undoManager = nil
        //4.
        self.privateQueueManagedObjectContext.performAndWait {
            _ = Constants.TimeConstant.TICK
            self.importData()
            print("Total elapsed time from Parent-Child is: \(Constants.TimeConstant.TOCK)")
        }
    }
    
    fileprivate func importData() {
        if let object = try? DataModel.fromJSON("jsonData") as [DataModel]? {
            //1.
            let totalCount = object.count
            let progressCounter = totalCount/100

            var counter = 0
            //2.
            for item in object {
                //1.
                 if isCancelled {
                     return
                 }
                //2.
                counter += 1
                _ = DataEntity.importData(from: item, in: self.privateQueueManagedObjectContext)
                if counter%progressCounter == 0
                {
                    self.saveProgress(progress: Float(counter)/Float(totalCount))
                }
                
                if counter%(Constants.BatchSizeConstants.SaveBatchSize) == 0
                {
                    self.saveInBatchOpertaion()
                }
            }
        }
    }
    
    //MARK:- Save in Batch Operation
    func saveInBatchOpertaion()
    {
        if self.privateQueueManagedObjectContext.hasChanges
        {
            do
            {
                try self.privateQueueManagedObjectContext.save()
                ///Comment this code if you do not want to save data in main context.
                let queue = DispatchQueue(label: "messages.queue", attributes: .concurrent)
                try queue.sync(flags: .barrier){
                   try self.mainManagedObjectContext.save()
                }
            }
            catch let saveError as NSError
            {
                print("saveError is : \(saveError.localizedDescription)")
            }
        }
    }
    
    //MARK:- Save Progress
    func saveProgress(progress : Float)
    {
        if (self.progress != nil)
        {
            self.progress?(progress)
        }
    }
}
