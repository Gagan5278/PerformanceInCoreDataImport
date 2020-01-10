//
//  CoreDataStackInMemory.swift
//  PerformanceCoreDataTests
//
//  Created by Gagan Vishal on 2020/01/09.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

/*
   Create IN-MEEMORY Core data stack
 */
 class CoreDataStackInMemory {
    static let sharedInstance = CoreDataStackInMemory()
    
    //PersistentContainer
    lazy var persistentConatiner: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PerformanceCoreData")
        //Create NSPersistentStoreDescription
        let persistentDecsription = NSPersistentStoreDescription()
        //set memory type
        persistentDecsription.type = NSInMemoryStoreType
        //set description to NSPersistentContainer
        container.persistentStoreDescriptions = [persistentDecsription]
        //load container
        container.loadPersistentStores { (description, error) in
            if let _ = error {
                fatalError("Something went wrong")
            }
        }
        return container
    }()
    
    //MARK:- Managed object Context
    lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentConatiner.viewContext
    }()
}
