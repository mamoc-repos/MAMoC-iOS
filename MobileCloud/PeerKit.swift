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

//open class PeerKit {

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

    let ID_DELIMITER: String = "\t"

    #if os(iOS)
        // Use the device name, along with the UUID for the device separated by a tab character
        let name = UIDevice.current.name
        let id = UIDevice.current.identifierForVendor!.uuidString
        public let myName = String(name + ID_DELIMITER + id)
    #elseif os(OSX)
        let name = NSHost.currentHost().localizedName ?? ""
        let id = NSHost.currentHost().address
        public let myName = String(name + ID_DELIMITER + id)
    #endif

    public var transceiver = Transceiver(displayName: myName)
//    static open var session: Session = Session(displayName: myName!, delegate: nil)
    public var session = transceiver.session.mcSession
        //Session(displayName: myName!, delegate: nil)

    // MARK: Event Handling

    // MARK: Advertise/Browse
    
//    public func transceive(serviceType: String, discoveryInfo: [String: String]? = nil) {
//        transceiver.startTransceiving(serviceType: serviceType, discoveryInfo: discoveryInfo)
//    }
//    
//    public func advertise(serviceType: String, discoveryInfo: [String: String]? = nil) {
//        transceiver.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
//    }
//    
//    public func browse(serviceType: String) {
//        transceiver.startBrowsing(serviceType: serviceType)
//    }
//    
//    public func stopTransceiving() {
//        transceiver.stopTransceiving()
//        session = nil
//    }

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
//}
