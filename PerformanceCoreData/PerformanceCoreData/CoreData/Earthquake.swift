//
//  Earthquake.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

class Earthquake: NSManagedObject {
    
    //MARK:- Insert new Object
    class func insertNewRecord(from property: EarthquakeProperties, context: NSManagedObjectContext) -> Earthquake? {
        if let earthquakeObject =  self.findOrCreateNewInstance(into: context, for: property.code) {
            earthquakeObject.magnitude = property.mag
            earthquakeObject.code = property.code
            earthquakeObject.place = property.place
            earthquakeObject.time =  (property.time/1000).dateFull
            return earthquakeObject
        }
        return nil
    }
    
    //MARK:- Check if item already exist. If does not exist then create a new one
    class func findOrCreateNewInstance(into context: NSManagedObjectContext, for identifier: String) -> Earthquake? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.getEntityName())
       // print(identifier)
        fetchRequest.predicate = NSPredicate(format: "code == %@", identifier)
        fetchRequest.fetchLimit = 1
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            if fetchedObjects.isEmpty {
                return self.createANewInstance(in: context)
            }
            else {
                return fetchedObjects.last as? Earthquake
            }
        }
        catch {
            print(error)
        }
        return nil
    }
    
    //MARK:- Create a new intance and return created instance
    class func createANewInstance(in context: NSManagedObjectContext) -> Earthquake {
        return NSEntityDescription.insertNewObject(forEntityName: self.getEntityName(), into: context) as! Earthquake
    }
    
    //MARK:- Get Entity name
    class func getEntityName() -> String {
        return String(describing: Earthquake.self)
    }
}
