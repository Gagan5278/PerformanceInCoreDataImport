//
//  Earthquake+Properties.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

extension Earthquake {
    @NSManaged var code: String
    @NSManaged var magnitude: Float
    @NSManaged var place: String
    @NSManaged var time: Date
    
    @nonobjc class func getFetchRequest() -> NSFetchRequest<Earthquake> {
         let fetchRequest =  NSFetchRequest<Earthquake>(entityName: self.getEntityName())
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
         return fetchRequest
    }
}

protocol EarthquakeProprty {
    var earthquakeItem: Earthquake {get}
    var humanReadableDate: String {get}
    var getRoundedMagnitude: Float {get}
    var getName: String {get}
}

extension Earthquake: EarthquakeProprty {
    var getName: String {
        return self.place
    }
    
    var getRoundedMagnitude: Float {
        return self.magnitude.roundTo(places: 4)
    }
    
    var humanReadableDate: String {
        let doubleTimeLong = self.time.timeIntervalSince1970
        return doubleTimeLong.toHumanReadable
    }
    
    var earthquakeItem: Earthquake {
        return self
    }

}
