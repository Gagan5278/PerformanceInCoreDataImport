//
//  Bindable.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation

class Bindable<T> {
    typealias Listener = ((T) -> Void)

    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    //MARK: Init
    init(_ v: T) {
        self.value = v
    }
    
    //MARK:- 1 Bind
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    //MARK:- Bind and Fire
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
