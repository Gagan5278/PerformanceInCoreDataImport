//
//  Decodable+Extension.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
extension Decodable {
    static func fromJSON<T:Decodable>(_ fileName: String, fileExtension: String="json", bundle: Bundle = .main) throws -> T {
        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
