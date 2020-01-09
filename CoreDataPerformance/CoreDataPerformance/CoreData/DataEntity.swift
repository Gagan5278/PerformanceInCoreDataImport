//
//  DataEntity.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData
class DataEntity: NSManagedObject {
    class func importData(from model: DataModel, in context: NSManagedObjectContext) -> DataEntity? {
        if let dataEntity = self.searchOrCreateObjectIfNotExist(with: model.guid, in: context) {
            dataEntity.guid = model.guid
            dataEntity.duration = model.duration ?? ""
            dataEntity.desc = model.description ?? ""
            dataEntity.location = model.location
            dataEntity.shape = model.shape
            dataEntity.reportedDate = model.reported_at.getHumanReadableDate()
            dataEntity.sighted = model.sighted_at.getHumanReadableDate()
            return dataEntity
        }
        return nil
    }
    
    //MARK:- Search Object if available or create a new one
    class func searchOrCreateObjectIfNotExist(with identifier: String, in context: NSManagedObjectContext) -> DataEntity?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.getEntityName())
        fetchRequest.predicate = NSPredicate(format: "%@==%@", Constants.KeysConstants.UFO_KEY_COREDATA_GUID, identifier)
        fetchRequest.fetchLimit = 1
        do {
            let arrrayOfObjectFound = try context.fetch(fetchRequest)
            if arrrayOfObjectFound.isEmpty {
                return self.insertNeweObjectIn(context: context)
            }
            else {
                return (arrrayOfObjectFound.first as! DataEntity)
            }
        }
        catch {
            return nil
        }
    }
    
    //MARK:- Create and Insert a new object
    class func insertNeweObjectIn(context: NSManagedObjectContext) -> DataEntity {
        return NSEntityDescription.insertNewObject(forEntityName: self.getEntityName(), into: context) as! DataEntity
    }
    
    //MARK:- Entity name
    class func getEntityName() -> String {
        return String(describing: self)
    }
}
