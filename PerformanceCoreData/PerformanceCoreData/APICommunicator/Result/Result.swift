//
//  Result.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2019/12/31.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
enum Result<T, U> where U : Error {
    case success(T)
    case failuer(U)
}
