//
//  Constants.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2019/12/31.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
enum Constants {
    enum Web_API {
        public static let base_url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"
    }
    
    enum User_Message {
        public static let empty_state_message = "There are no records available."
        
        public static let error_state_message = "Something went wrong. Please try again later."
    }
    
    enum Batch_Size {
        public static let batch_size = 256
    }
}
