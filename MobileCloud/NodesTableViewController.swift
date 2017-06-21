//
//  NodesTableViewController.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 06/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import UIKit
import MultipeerConnectivity

public class NodesTableViewController: UITableViewController {

    let mc = MobileCloud.MCInstance
    
    @IBAction func dismissBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    open override func viewDidLoad() {

        self.refreshControl?.addTarget(self, action: Selector(("refresh:")), for: UIControlEvents.valueChanged)

    }

    open func sessionDidChangeState() {
        print("session did change state called")
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func refresh(sender:AnyObject) {
    
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source

    open override func numberOfSections(in tableView: UITableView) -> Int {
        // We have 3 sections in our grouped table view, one for each MCSessionState
        return 3
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        // Each tableView section represents an MCSessionState
        let sessionState = MCSessionState(rawValue: section)
        
        switch sessionState! {
        case .connecting:
            rows = 1
                //mc.connectingPeers.count
            
        case .connected:
            rows = (session.connectedPeers.count)
            
        case .notConnected:
            rows = 1
                //mc.disconnectedPeers.count
        }
        
        // Always show at least 1 row for each MCSessionState.
        if (rows < 1) {
            rows = 1
        }
        
        return rows
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Each tableView section represents an MCSessionState
        let sessionState = MCSessionState(rawValue: section)
        return mc.stringForPeerConnectionState(sessionState!)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath)
        cell.textLabel?.text = "None"
        
        var peers: NSArray
        
        // Each tableView section represents an MCSessionState
        let sessionState = MCSessionState(rawValue: (indexPath as NSIndexPath).section)
        let peerIndex = (indexPath as NSIndexPath).row
        
        switch sessionState! {
        case .connecting:
            peers = []
                //mc.connectingPeers as NSArray
            
        case .connected:
            peers = mc.connectedNodes as NSArray
            
        case .notConnected:
            peers = []
//                mc.disconnectedPeers as NSArray
        }
        
        if (peers.count > 0) && (peerIndex < peers.count) {
            let peerID = peers.object(at: peerIndex) as! MCPeerID
            cell.textLabel?.text = peerID.displayName
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPeer: MCPeerID!
        
        let sessionState = MCSessionState(rawValue: (indexPath as NSIndexPath).section)
        //    let peerIndex = indexPath.row
        
        //        print("disconnected: \(mc.disconnectedPeers.count)")
        //        print("found peers: \(mc.foundPeers.count)")
        
        switch sessionState! {
        // do nothing when they are already connected
        case .connecting,.connected:
            return
            
        case .notConnected:
            return
//            if mc.disconnectedPeers.count > 0 {
//                selectedPeer = mc.disconnectedPeers[indexPath.row] as MCPeerID
//            }
//            else{
//                return
//            //    selectedPeer = mc.foundPeers[indexPath.row] as MCPeerID
//            }
            
//            debugPrint("\tBrowser sending invitePeer")
//            
//            var aSession:MCSession! = PeerKit.session.availableSession(selectedPeer.displayName, peerName: MCNode.getMe().nodeName)
//            
//            if aSession == nil {
//                aSession = PeerKit.session.newSession(selectedPeer.displayName, peerName: MCNode.getMe().nodeName)
//            }
//            
//            PeerKit.transceiver.browser.mcBrowser?.invitePeer(selectedPeer, to: aSession, withContext: nil, timeout: 30.0)
        }
    }
}
