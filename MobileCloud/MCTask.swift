//
//  MCTask.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 05/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

enum Task: String {
    case offloadingEvent = "offloadingEvent"
    case fetchingResult = "sendResultEvent"
}

open class MCTask: MCCoding {
    
    // MARK: NSObject
    
    public override init() {
        super.init()
    }
    
    // MARK: MCCoding
    
    required public init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder);
    }

    
}
