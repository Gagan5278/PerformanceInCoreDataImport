//
//  EarthquakeModel.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
struct EarthquakeModel: Decodable {
    let features:  [Properties]
    private enum RootCodingKeys: String, CodingKey {
        case features
    }

    //MARK:- Decodable init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.features = try container.decode([Properties].self, forKey: .features)//nestedUnkeyedContainer(forKey: .features)
    }
}

struct Properties: Decodable {
    let properties : EarthquakeProperties
    private enum FeatureCodingKeys: String, CodingKey {
        case properties
    }
    
    init(from decoder: Decoder) throws {
        let propertiesContainer = try decoder.container(keyedBy: FeatureCodingKeys.self)
        self.properties = try propertiesContainer.decode(EarthquakeProperties.self, forKey: .properties)
    }
}
/**
 A struct encapsulating the properties of a Quake. All members are
 optional in case they are missing from the data.
 */
struct EarthquakeProperties: Decodable {
    let mag: Float         // 1.9
    let place: String     // "21km ENE of Honaunau-Napoopoo, Hawaii"
    let time: Double      // 1539187727610
    let code: String      // "70643082"
}
