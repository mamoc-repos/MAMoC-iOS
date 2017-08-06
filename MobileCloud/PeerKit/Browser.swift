//
//  Browser.swift
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let timeStarted = NSDate()

class Browser: NSObject, MCNearbyServiceBrowserDelegate {
//    let displayName: String
    let mcSession: MCSession
    
    init(mcSession: MCSession) {
        self.mcSession = mcSession
        super.init()
    }
    
    var mcBrowser: MCNearbyServiceBrowser?
    var MCDelegate: MCManagerDelegate?

    func startBrowsing(_ serviceType: String) {
        mcBrowser = MCNearbyServiceBrowser(peer: mcSession.myPeerID, serviceType: serviceType)
        mcBrowser?.delegate = self
        mcBrowser?.startBrowsingForPeers()
    }

    func stopBrowsing() {
        mcBrowser?.delegate = nil
        mcBrowser?.stopBrowsingForPeers()
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        guard displayName != peerID.displayName else {
//            return
//        }
//        
//        debugPrint("\tBrowser \(browser.myPeerID.displayName) found peerID \(peerID.displayName)")
//
//        //Only invite from one side. Example: For devices A and B, only one should invite the other.
//        let hasInvite = (displayName.components(separatedBy: PeerKit.ID_DELIMITER)[1] > peerID.displayName.components(separatedBy: PeerKit.ID_DELIMITER)[1])
//
//       if (hasInvite) {
//            debugPrint("\tBrowser sending invitePeer")
//            let aSession = PeerKit.session.availableSession(displayName, peerName: peerID.displayName)
//            browser.invitePeer(peerID, to: aSession, withContext: nil, timeout: 30.0)
//        }
//        else {
//            debugPrint("\tBrowser NOT sending invitePeer")
//        }
        
        MCDelegate?.foundPeer()
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 30)

    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        MCDelegate?.lostPeer()
        debugPrint("\tBrowser \(browser.myPeerID.displayName) lost peer \(peerID.displayName)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        debugPrint("\tBrowser didNotStartBrowsingForPeers: \(error.localizedDescription)")
    }
}
