//
//  DataEntity+Properties.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

extension DataEntity {
    @NSManaged var desc: String?
    @NSManaged var duration: String?
    @NSManaged var guid: String
    @NSManaged var location: String
    @NSManaged var reportedDate: Date
    @NSManaged var shape: String
    @NSManaged var sighted: Date
    
    @nonobjc public class func getFetchRequest() -> NSFetchRequest<DataEntity> {
        return NSFetchRequest<DataEntity>(entityName: "DataEntity")
    }
}
