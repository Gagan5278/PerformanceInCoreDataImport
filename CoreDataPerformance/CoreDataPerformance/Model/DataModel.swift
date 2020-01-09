//
//  DataModel.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation

struct DataModel: Decodable {
    let description: String?
    let reported_at: String
    let shape: String
    let location: String
    let duration: String?
    let sighted_at: String
    let guid: String
    
    private enum CodingKeys: String, CodingKey {
        case guid
        case sighted_at
        case reported_at
        case location
        case shape
        case duration
        case description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.reported_at = try container.decode(String.self, forKey: .reported_at)
        self.shape = try container.decode(String.self, forKey: .shape)
        self.location = try container.decode(String.self, forKey: .location)
        self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
        self.sighted_at = try container.decode(String.self, forKey: .sighted_at)
        self.guid = try container.decode(String.self, forKey: .guid)
    }
}
