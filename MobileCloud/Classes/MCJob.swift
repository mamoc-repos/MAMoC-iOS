//
//  MCTask.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 05/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

open class MCJob {
    public init(){
        
    }
    
    open func id() -> UInt32 {
        return 4229232399
    }

    open func name() -> String {
        return "job name"
    }
    
    open func initTask(_ node:MCNode, nodeNumber:UInt, totalNodes:UInt) -> MCTask {
        return MCTask()
    }
    
    open func executeTask(_ node:MCNode, fromNode:MCNode, task: MCTask) -> MCResult {
        return MCResult()
    }
    
    open func mergeResults(_ node:MCNode, nodeToResult: [MCNode:MCResult]) {
    
    }
    
    open func onPeerConnect(_ myNode:MCNode, connectedNode:MCNode) {
        
    }
    
    open func onPeerDisconnect(_ myNode:MCNode, disconnectedNode:MCNode) {
        
    }
    
    open func onLog(_ format:String) {
        
    }
}
