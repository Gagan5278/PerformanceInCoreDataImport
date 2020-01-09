//
//  Constants.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation

///Import progress callback
typealias importProgressCallBack = (Float) -> Void


enum Constants {
    enum KeysConstants {
        public static let UFO_KEY_COREDATA_GUID  = "guid"
        public static let  UFO_KEY_COREDATA_SIGHTED  = "sighted"
        public static let  UFO_KEY_COREDATA_REPORTED  = "reported"
        public static let  UFO_KEY_COREDATA_LOCAT = "shape"
        public static let  UFO_KEY_COREDATA_DURATION = "duration"
        public static let  UFO_KEY_COREDATA_DESC  = "desc"
        
        public static let UFO_KEY_JSON_GUID  = "guid"
        public static let UFO_KEY_JSON_SIGHTED  = "sighted_at"
        public static let UFO_KEY_JSON_REPORTED  = "reported_at"
        public static let UFO_KEY_JSON_LOCATION = "location"
        public static let UFO_KEY_JSON_SHAPE  = "shape"
        public static let UFO_KEY_JSON_DURATION  = "duration"
        public static let UFO_KEY_JSON_DESC  = "description"
    }
    
    enum BatchSizeConstants {
        public static let ImportBatchSize = 1000
        public static let SaveBatchSize = 1000
    }
    
    enum NotificationName {
        public static let IMPORT_OPERATION_COMPLETED = "IMPORT_OPERATION_COMPLETED"
    }
    
    enum TimeConstant {
        public static let TICK  = NSDate()
        public static let TOCK = -TICK.timeIntervalSinceNow
    }
    
    enum AlertMessage {
        public static let cancelImportTitle = "Cancel Import"
        public static let cancelImportMessage = "Import operation is currently running. Would you like to cancel it?"
    }
    
    enum FileConstants {
        public static let jsonFileName = "jsonData"
        public static let sqliteFileName = "jsonData.sqlite"
        public static let josnModelFileName = "CoreDataPerformance"
        public static let josnModelFileExtension = "momd"
    }
    
    enum NotificationConstants {
        public static let notificationImportOperationCompleted =  "Notification_Import_Operation_Completed"
    }
}
