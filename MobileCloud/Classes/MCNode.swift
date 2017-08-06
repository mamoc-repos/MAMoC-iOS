//
//  MCNode.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 05/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
import MultipeerConnectivity

open class MCNode: CustomStringConvertible, Hashable, Equatable {

    open fileprivate(set) var nodeName: String
    open fileprivate(set) var mcPeerID: MCPeerID
    open var hashValue: Int
    
    public init(_ name:String, mcPeerID:MCPeerID){
        self.nodeName = name
        self.mcPeerID = mcPeerID
        self.hashValue = name.hash
    }
    
    open var description: String {
        return nodeName
    }
    
    static func getMe() -> MCNode {
        return MCNode(myName, mcPeerID: session.myPeerID)
    }
}

public func ==(lhs:MCNode, rhs:MCNode) -> Bool{
    return lhs.hashValue == rhs.hashValue
}
