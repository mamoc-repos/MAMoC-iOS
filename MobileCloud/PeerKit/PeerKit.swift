//
//  PeerKit.swift
//
//  Created by JP Simard on 11/5/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

#if os(iOS)
    import UIKit
#endif

    // MARK: Type Aliases

    public typealias PeerBlock = ((_ myPeerID: MCPeerID, _ peerID: MCPeerID) -> Void)
    public typealias EventBlock = ((_ peerID: MCPeerID, _ event: String, _ object: AnyObject?) -> Void)
    public typealias ObjectBlock = ((_ peerID: MCPeerID, _ object: AnyObject?) -> Void)
    public typealias ResourceBlock = ((_ myPeerID: MCPeerID, _ resourceName: String, _ peer: MCPeerID, _ localURL: URL) -> Void)

    // MARK: Event Blocks

    public var onConnecting: PeerBlock?
    public var onConnect: PeerBlock?
    public var onDisconnect: PeerBlock?
    public var onEvent: EventBlock?
    public var onEventObject: ObjectBlock?
    public var onFinishReceivingResource: ResourceBlock?
    public var eventBlocks = [String: ObjectBlock]()

    // MARK: PeerKit Globals

    #if os(iOS)
        // Use the device name, along with the UUID for the device separated by a tab character
        let name = UIDevice.current.name
    //    let id = UIDevice.current.identifierForVendor!.uuidString
        public let myName = name
    #elseif os(OSX)
        let name = NSHost.currentHost().localizedName ?? ""
    //    let id = NSHost.currentHost().address
        public let myName = name
    #endif

    public var transceiver = Transceiver(displayName: myName)
    public var session = transceiver.session.mcSession

        //Session(displayName: myName!, delegate: nil)

    // MARK: Event Handling

    // MARK: Events

     public func sendEvent(_ event: String, object: AnyObject? = nil, toPeers peers: [MCPeerID]? = session.connectedPeers) {
        guard let peers = peers, !peers.isEmpty else {
            return
        }

        var rootObject: [String: AnyObject] = ["event": event as AnyObject]

        if let object: AnyObject = object {
            rootObject["object"] = object
        }

        let data = NSKeyedArchiver.archivedData(withRootObject: rootObject)

        do {
            try session.send(data, toPeers: peers, with: .reliable)
        } catch _ {
        }
    }
