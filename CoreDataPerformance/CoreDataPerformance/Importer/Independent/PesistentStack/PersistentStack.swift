//
//  PesistentStack.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/13.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

class PersistentStack {
    let modelURL: URL!
    let storeURL: URL!
    var managedObjectContext: NSManagedObjectContext?
    var disableMergeNotifications: Bool = false
    
    //MARK:- Init
    init(modelURL: URL, storeURL: URL){
        self.modelURL = modelURL
        self.storeURL = storeURL
        self.setupPersistentStack()
    }
    
    //MARK:- Setup persistent stack
    fileprivate func setupPersistentStack(){
        //1. NSManagedObjectModel
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: self.modelURL) else {
            assert(true, "ERROR: Cannot generate persistent store as no model exist")
            return
        }
        //2. NSPersistentStoreCoordinator
         let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        //3.
        let dictionary = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        //4.
         do
         {
           let _ = try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: dictionary)
            //create managed Object Context
            self.managedObjectContext =  NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator
            if self.managedObjectContext == nil {
                assert(true, "ASSERT: NSManagedObjectContext is nil")
            }
            //setup save notification
            saveNotification()
        }
         catch {
            print("Error is :\(error)")
        }
    }
    
    //MARK:- Add Observer for NSManagedObjectContextDidSave
    fileprivate func saveNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSaveNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    //MARK:- Save on notification
    @objc func managedObjectContextDidSaveNotification(notification: Notification) {
        if !disableMergeNotifications {
            let mainManagedObjectContext = self.managedObjectContext
            if let notificationManagedObjectContext = notification.object as? NSManagedObjectContext  /*mainManagedObjectContext != notificationManagedObjectContext*/ {
                mainManagedObjectContext?.performAndWait ({
                    mainManagedObjectContext?.mergeChanges(fromContextDidSave: notification)
                })
            }
        }
    }
    
    //MARK:- Create new Private Managed Object Context
    func createNewPrivateManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.managedObjectContext?.persistentStoreCoordinator
        return managedObjectContext
    }
    
    //MARK:- Create New Private ManagedObjectContext With New PersistentStoreCoordinator
    func createNewPrivateManagedObjectContextWithNewPersistentStoreCoordinator() -> NSManagedObjectContext {
        //1. NSManagedObjectModel
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: self.modelURL) else {
            assert(true, "ERROR: Cannot generate persistent store as no model exist")
            return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        //2. NSPersistentStoreCoordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        //3.
        let dictionary = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        //4.
        do {
            let _ =  try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName:nil, at: self.storeURL, options: dictionary)
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator = persistentStoreCoordinator
            return privateContext
        }
        catch {
            print("Error is :\(error)")
            assert(true, "ERROR: Cannot generate persistent store as no model exist")
        }
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }
}

