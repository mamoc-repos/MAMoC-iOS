//
//  Advertiser.swift
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Advertiser: NSObject, MCNearbyServiceAdvertiserDelegate {
//    let displayName: String
    fileprivate var advertiser: MCNearbyServiceAdvertiser?

//    init(displayName: String) {
//        self.displayName = displayName
//        super.init()
//    }

    let mcSession: MCSession
    
    init(mcSession: MCSession) {
        self.mcSession = mcSession
        super.init()
    }
    
    func startAdvertising(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser = MCNearbyServiceAdvertiser(peer: mcSession.myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.delegate = nil
        advertiser?.stopAdvertisingPeer()
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        guard displayName != peerID.displayName else {
//            return
//        }
//        
//        let aSession = PeerKit.session.availableSession(displayName, peerName: peerID.displayName)
//        invitationHandler(true, aSession)
//        
//        advertiser.stopAdvertisingPeer()
//        
//        debugPrint("Advertiser \(advertiser.myPeerID.displayName) accepting \(peerID.displayName)")

        let accept = mcSession.myPeerID.hashValue > peerID.hashValue
        invitationHandler(accept, mcSession)
        if accept {
            stopAdvertising()
        }

    }
    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
//        debugPrint("Advertiser didNotStartAdvertisingPeer: \(error.localizedDescription)")
//    }
}
