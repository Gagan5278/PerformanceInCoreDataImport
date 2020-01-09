//
//  GlobalTimer.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/12.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import UIKit

class GlobalTimer {
    //Shared instance for class
    static let sharedInstance = GlobalTimer()
    
    var internalTimer: Timer?
    //MARK:- STart Time
    func startTimer(withInterval interval: Double, controller: UIViewController, andJob job: Selector) {
        if internalTimer == nil {
            internalTimer?.invalidate()
        }
        internalTimer = Timer.scheduledTimer(timeInterval: interval, target: controller, selector: job, userInfo: nil, repeats: true)
    }

    //MARK:- Pause Timer
    func pauseTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        internalTimer?.invalidate()
    }

    //MARK:- Stop Timer
    func stopTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        internalTimer?.invalidate()
    }
}
