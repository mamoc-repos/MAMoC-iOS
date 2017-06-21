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

    open fileprivate(set) var nodeID: String
    open fileprivate(set) var nodeName: String
    open fileprivate(set) var mcPeerID: MCPeerID
    open var hashValue: Int
    
    public init(_ ID:String, name:String, mcPeerID:MCPeerID){
        self.nodeID = ID
        self.nodeName = name
        self.mcPeerID = mcPeerID
        self.hashValue = ID.hash
    }
    
    open var description: String {
        return nodeName + " " + nodeID
    }
    
    static func getMe() -> MCNode {
        print(session.myPeerID.displayName )
        return MCNode(myName!.components(separatedBy: ID_DELIMITER)[1], name: myName!.components(separatedBy: ID_DELIMITER)[0], mcPeerID: (session.myPeerID))
    }
}


public func ==(lhs:MCNode, rhs:MCNode) -> Bool{
    return lhs.nodeID == rhs.nodeID
}
