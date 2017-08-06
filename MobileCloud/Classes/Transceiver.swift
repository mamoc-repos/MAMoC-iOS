//
//  Transceiver.swift
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum TransceiverMode {
    case Browse, Advertise, Both
}

open class Transceiver: SessionDelegate {

    var transceiverMode = TransceiverMode.Both
    let session: Session
    let advertiser: Advertiser
    let browser: Browser
    let displayName: String
    
    public init(displayName: String!) {
        self.displayName = displayName
        session = Session(displayName: displayName, delegate: nil)
        advertiser = Advertiser(mcSession: session.mcSession)
        browser = Browser(mcSession: session.mcSession)
        session.delegate = self
    }

    open func startTransceiving(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        browser.startBrowsing(serviceType)
    }

    func stopTransceiving() {
        session.delegate = nil
        advertiser.stopAdvertising()
        browser.stopBrowsing()
        session.disconnect()
    }

    func startAdvertising(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        transceiverMode = .Advertise
    }

    func startBrowsing(serviceType: String) {
        browser.startBrowsing(serviceType)
        transceiverMode = .Browse
    }

    open func connecting(_ myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        if let onConnecting = onConnecting {
            DispatchQueue.main.async {
                onConnecting(myPeerID, peer)
            }
        }
    }

    open func connected(_ myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        if let onConnect = onConnect {
            DispatchQueue.main.async {
                onConnect(myPeerID, peer)
            }
        }
    }

    open func disconnected(_ myPeerID: MCPeerID, fromPeer peer: MCPeerID) {
        if let onDisconnect = onDisconnect {
            DispatchQueue.main.async {
                onDisconnect(myPeerID, peer)
            }

        }
    }

    open func receivedData(_ myPeerID: MCPeerID, data: Data, fromPeer peer: MCPeerID) {
        debugPrint("receivedData from \(peer.displayName) (on \(myPeerID.displayName))")
        if let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: AnyObject] {
            if let event = dict["event"] as? String {
                if let object = dict["object"] {
                    DispatchQueue.main.async {
                        if let onEvent = onEvent {
                            print(onEvent)
                            onEvent(peer, event, object)
                        }
                        if let eventBlock = eventBlocks[event] {
                            print(eventBlock)
                            eventBlock(peer, object)
                        }
                    }
                }
            }
        }
    }

    open func finishReceivingResource(_ myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: URL) {
        if let onFinishReceivingResource = onFinishReceivingResource {
            DispatchQueue.main.async {
                onFinishReceivingResource(myPeerID, resourceName, peer, localURL)
            }
        }
    }
}
