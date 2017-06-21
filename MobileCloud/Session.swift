//
//  Session.swift
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol SessionDelegate {
    func connecting(_ myPeerID: MCPeerID, toPeer peer: MCPeerID)
    func connected(_ myPeerID: MCPeerID, toPeer peer: MCPeerID)
    func disconnected(_ myPeerID: MCPeerID, fromPeer peer: MCPeerID)
    func receivedData(_ myPeerID: MCPeerID, data: Data, fromPeer peer: MCPeerID)
    func finishReceivingResource(_ myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: URL)
}

open class Session: NSObject, MCSessionDelegate {
    var delegate: SessionDelegate?
    public private(set) var myPeerID: MCPeerID

//    var myPeerSessions = [String: MCSession]()
//    open let myPeerId = MCPeerID(displayName: PeerKit.myName!)
    public private(set) var mcSession: MCSession

    public init(displayName: String, delegate: SessionDelegate? = nil) {
    //    self.delegate = delegate
    //    super.init()
    //    myPeerSessions[String(myPeerSessions.count)] = self.availableSession(displayName, peerName: displayName)

        myPeerID = MCPeerID(displayName: displayName)
        self.delegate = delegate
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        super.init()
        mcSession.delegate = self
    }

//    open func disconnect(_ displayName: String) {
//
//        if let session = self.getSession(displayName) {
//            session.delegate = nil
//            session.disconnect()
//            myPeerSessions.removeValue(forKey: displayName)
//        }
//    }
    
    public func disconnect() {
        self.delegate = nil
        mcSession.delegate = nil
        mcSession.disconnect()
    }

//    func getSession(_ displayName: String) -> MCSession? {
//        guard myPeerSessions.index(forKey: displayName) != nil else {
//            return nil
//        }
//
//        return myPeerSessions[displayName]!
//    }
//
//    func getPeerId() -> MCPeerID {
//        return myPeerId
//    }
//
//    // Some functions below adopted from:
//    // http://stackoverflow.com/questions/23014523/multipeer-connectivity-framework-lost-peer-stays-in-session/23017463#23017463
//
//    open func allConnectedPeers() -> [MCPeerID] {
//        var allPeers: [MCPeerID] = []
//        for (_, session) in myPeerSessions {
//            for peer in session.connectedPeers {
//                allPeers.append(peer)
//             }
//        }
//        return allPeers
//    }
//
//    open func allConnectedSessions() -> [MCSession] {
//        var allSessions: [MCSession] = []
//        
//        for (_, session) in myPeerSessions {
//            allSessions.append(session)
//        }
//
//        print(allSessions)
//
//        return allSessions
//    }
//
//    func availableSession(_ displayName: String, peerName: String) -> MCSession {
//        var notFound = true
//        var availableSession: MCSession? = nil
//
//        //Try and use an existing session (_sessions is a mutable array)
//        for (_, session) in myPeerSessions {
//            if (session.connectedPeers.count < kMCSessionMaximumNumberOfPeers) {
//                notFound = false
//                availableSession = session
//                break
//            }
//        }
//
//        if notFound {
//            availableSession = self.newSession(displayName, peerName: peerName)
//        }
//
//        return availableSession!
//    }
//
//    func newSession(_ displayName: String, peerName: String) -> MCSession {
//        // swift 3 had problem so disabled encryption based on this: https://stackoverflow.com/questions/38745370/multipeer-connectivity-not-connecting-programmatically
//        
//        
//        
//        let newSession = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none )
//
//        print("CREATING NEW SESSION！！！！！ \(newSession.description)")
//        newSession.delegate = self
//        myPeerSessions[String(myPeerSessions.count)] = newSession
//
//        return newSession
//    }

//    func sendData(_ data: Data, toPeers peerIDs: [MCPeerID], withMode: MCSessionSendDataMode) {
//        guard peerIDs.count != 0  else {
//            return
//        }
//
//        // Match up peers to their session
//        for session: MCSession in allConnectedSessions() {
//            do {
//                try session.send(data, toPeers: peerIDs, with: withMode)
//            } catch let errors as NSError{
//                NSLog("Session error in sendData: \(errors.localizedDescription)")
//            }
//        }
//    }

    // MARK: MCSessionDelegate

    open func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            delegate?.connecting(session.myPeerID, toPeer: peerID)
//            connectingPeersDictionary.setObject(peerID, forKey: myPeerId as NSCopying)
//            disconnectedPeersDictionary.removeObject(forKey: myPeerId)

        case .connected:
        //    myPeerSessions[session.myPeerID.displayName] = session
            delegate?.connected(session.myPeerID, toPeer: peerID)
//            connectedPeersDictionary.setObject(peerID, forKey: myPeerId as NSCopying)
//            connectingPeersDictionary.removeObject(forKey: myPeerId)
//            disconnectedPeersDictionary.removeObject(forKey: myPeerId)
            
        case .notConnected:
        //    self.disconnect(peerID.displayName)
            delegate?.disconnected(session.myPeerID, fromPeer: peerID)
//            connectingPeersDictionary.removeObject(forKey: myPeerId)
        }
        
    }

    open func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.delegate?.receivedData(session.myPeerID, data: data, fromPeer: peerID)
    }

    open func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // unused
    }

    open func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // unused
    }

    open func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
        if error == nil {
            debugPrint("Error didFinishReceivingResourceWithName: \(String(describing: error))")
        }
        if (error != nil) {
            delegate?.finishReceivingResource(session.myPeerID, resourceName: resourceName, fromPeer: peerID, atURL: localURL)
        }
    }

//    open func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
//        certificateHandler(true)
//    }
}
