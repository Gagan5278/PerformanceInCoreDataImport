//
//  String+Date.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation

extension String {
    func getHumanReadableDate() -> Date {
        if let interVal = Int(self)  {
            return Date(timeIntervalSince1970: TimeInterval(interVal))
        }
        return  Date()
    }
}
