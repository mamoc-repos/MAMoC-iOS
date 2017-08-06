//
//  MCTimer.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 05/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

open class MCTimer {
    fileprivate var startTime: CFAbsoluteTime
    fileprivate var stopTime: CFAbsoluteTime
    fileprivate var stopped: Bool = false
    
    public init() {
        stopped = false;
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = Double(startTime)
    }
    
    // MARK: Functions
    
    /**
     Start the timer
     */
    open func start() {
        stopped = false;
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = Double(startTime)
    }
    
    /**
     Stop the timer
     
     - returns: the elapsed time in seconds
     */
    open func stop() -> CFAbsoluteTime {
        stopTime = CFAbsoluteTimeGetCurrent()
        stopped = true;
        return getElapsedTimeInSeconds()
    }
    
    /**
     Get the elapsed time in seconds
     
     - returns: the elapsed time in seconds
     */
    open func getElapsedTimeInSeconds() -> CFAbsoluteTime {
        if(stopped) {
            return stopTime - startTime
        } else {
            return CFAbsoluteTimeGetCurrent() - startTime
        }
    }
}
