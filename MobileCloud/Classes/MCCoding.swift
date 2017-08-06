//
//  MCCoding.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 06/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

open class MCCoding: NSObject, NSCoding {
    
    /// A uuid to identify this information
    open fileprivate(set) var uuid: String = UUID().uuidString
    
    // MARK: NSObject
    
    public override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
    required public init(coder decoder: NSCoder) {
        self.uuid = decoder.decodeObject(forKey: "uuid") as! String
    }
    
    open func encode(with coder: NSCoder) {
        coder.encode(self.uuid, forKey: "uuid")
    }
}
