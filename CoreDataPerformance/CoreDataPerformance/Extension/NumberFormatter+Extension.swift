//
//  NumberFormatter+Extension.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/12.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation

extension Float {
    func getNearestFloatValue() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        guard let formattedString = formatter.string(for: self) else {
            return ""
        }
        return formattedString
    }
}
