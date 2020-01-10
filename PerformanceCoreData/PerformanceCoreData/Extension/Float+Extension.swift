//
//  Float+Extension.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
extension Float {
    func roundTo(places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
