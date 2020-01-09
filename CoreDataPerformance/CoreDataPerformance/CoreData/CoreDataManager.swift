//
//  CoreDataManager.swift
//  IDNow
//
//  Created by Gagan Vishal on 2019/11/27.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

class  CoreDataManager {
    //Singelton Instance for CoreDataManager
    static let sharedInstance = CoreDataManager()
    //Managed Object Context
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = self.persistentStoreCoordinator.viewContext
        return managedObjectContext
    }()
    
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
    */
     private lazy var persistentStoreCoordinator: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataPerformance")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK:- Delete all ietms from core data
    func deleteAllItemsOnViewLoad(completionHandler: @escaping () -> Void) {
        let fetchRequest = DataEntity.getFetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try self.persistentStoreCoordinator.persistentStoreCoordinator.execute(deleteRequest, with: self.managedObjectContext)
            completionHandler()
        } catch let error as NSError {
            print(error)
            completionHandler()
        }
    }
}
