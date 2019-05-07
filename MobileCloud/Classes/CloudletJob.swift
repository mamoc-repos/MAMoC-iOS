//
//  CloudletJob.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 30/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

open class CloudletJob: NSObject {
//    public init(){
//        
//    }
    
    open func id() -> UInt32 {
        return 4229232399
    }
    
    open func name() -> String {
        return "cloudlet job name"
    }
    
    open func initTask(_ cloudlet:Cloudlet) -> MCTask {
        return MCTask()
    }
    
    open func executeTask(_ cloudlet:Cloudlet, task: MCTask) {
        
    }
    
    open func onLog(_ format:String) {
        
    }
}
