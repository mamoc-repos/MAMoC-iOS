//
//  NodesTableViewController.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 06/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NodesTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var remoteCloudButton: UIButton!
    @IBOutlet var cloudletButton: UIButton!
    @IBOutlet var remoteCloudConnected: UILabel!
    @IBOutlet var CloudletConnected: UILabel!
    @IBOutlet var remoteCloudTextField: UITextField!
    @IBOutlet var cloudletTextField: UITextField!
    
    var connectedPeers: [MCPeerID] {
        get {
            return session.connectedPeers
        }
    }
    
    var connectingPeers: [MCPeerID] {
        get {
            return connectingPeersDictionary.allValues as! [MCPeerID]
        }
    }
    
    var disconnectedPeers: [MCPeerID] {
        get {
            return disconnectedPeersDictionary.allValues as! [MCPeerID]
        }
    }
    
    @IBAction func connectToRemoteCloud(_ sender: Any) {
        
    }
    
    @IBAction func connectToCloudlet(_ sender: Any) {
        
        guard cloudletTextField.text != nil else {
            return
        }
        
        let ip = cloudletTextField.text!
        
        // use user provided cloudlet IP address, otherwise use default cloudlet IP address
        if !(ip.isEmpty) {
           MobileCloud.MCInstance.cloudletInstance.url = URL(string:"ws://\(ip)/connect")!
        }
        
        webSocket.connect()
    }
    
    open override func viewDidLoad() {
        
        setupWebSocketSettings()
        
        if let cp = UserDefaults.standard.value(forKey: "cloudIP") {
            remoteCloudTextField.text = cp as? String
            connectToRemoteCloud(self)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            self.tableView.refreshControl = refreshControl
        }
    }

    @objc private func refreshOptions(sender: UIRefreshControl) {
        
        self.tableView.reloadData()
        sender.endRefreshing()
    }
    
    func setupWebSocketSettings() {
    
        CloudletConnected.textColor = UIColor.red
        remoteCloudConnected.textColor = UIColor.red
        
        // if cloudlet IP and remote cloud IPs have been previously set, update the value of textfields and start connecting
        
        if let cl = UserDefaults.standard.value(forKey: "cloudletIP") {
            cloudletTextField.text = cl as? String
            connectToCloudlet(self)
        }

        //set this you want to ignore SSL cert validation, so a self signed SSL certificate can be used.
        webSocket.disableSSLCertValidation = true
    
        // MARK: Web sockets delegate
        
        webSocket.onConnect = { [webSocket, weak self] in
            webSocket?.write(string:"{\"username\":\"\(myName)\"}")
        }
        
        webSocket.onText = { [unowned self] text in
            guard let data = text.data(using: String.Encoding.utf8) else { return }
            guard let js = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else { return }
            guard let content = js["message"] as? String
                else { return }
            if content == myName {
                
                isCloudletConnected = true
                
                self.CloudletConnected.text = "Connected"
                self.CloudletConnected.textColor = UIColor.green
                self.cloudletTextField.text = CloudletDefaultURL
                
                // disable both the textfield and button
                self.cloudletButton.isEnabled = false
                self.cloudletTextField.isEnabled = false
                
                self.view.setNeedsDisplay()
            }
        }
        
        webSocket.onDisconnect = { [unowned self] err in
            
            isCloudletConnected = false
            
            self.CloudletConnected.text = "Not Connected"
            self.CloudletConnected.textColor = UIColor.red
            self.cloudletTextField.text = ""
            
            // enable both the textfield and button
            self.cloudletButton.isEnabled = true
            self.cloudletTextField.isEnabled = true
            
            self.view.setNeedsDisplay()
        }
    }
}

extension NodesTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Table view data source
    
    open  func numberOfSections(in tableView: UITableView) -> Int {
        // We have 3 sections in our grouped table view, one for each MCSessionState
        return 3
    }
    
    open  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        // Each tableView section represents an MCSessionState
        let sessionState = MCSessionState(rawValue: section)
        
        switch sessionState! {
        case .connecting:
            rows = connectingPeers.count
            
        case .connected:
            rows = connectedPeers.count
            
        case .notConnected:
            rows = disconnectedPeers.count
        }
        
        // Always show at least 1 row for each MCSessionState.
        if (rows < 1) {
            rows = 1
        }
        
        return rows
    }
    
    open  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Each tableView section represents an MCSessionState
        let sessionState = MCSessionState(rawValue: section)
        return stringForPeerConnectionState(sessionState!)
    }
    
    open  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath)
        cell.textLabel?.text = "None"
        
        var peers: NSArray
        
        // Each tableView section represents an MCSessionState
        let sessionState = MCSessionState(rawValue: (indexPath as NSIndexPath).section)
        let peerIndex = (indexPath as NSIndexPath).row
        
        switch sessionState! {
        case .connecting:
            peers = connectingPeers as NSArray
            
        case .connected:
            peers = connectedPeers as NSArray
            
        case .notConnected:
            peers = disconnectedPeers as NSArray
        }
        
        if (peers.count > 0) && (peerIndex < peers.count) {
            let peerID = peers.object(at: peerIndex) as! MCPeerID
            cell.textLabel?.text = peerID.displayName
        }
        
        return cell
    }
    
    open  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            if disconnectedPeers.count > 0 {
                selectedPeer = disconnectedPeers[indexPath.row] as MCPeerID
            }
            else{
                return
                //    selectedPeer = foundPeers[indexPath.row] as MCPeerID
            }
            
            debugPrint("\tBrowser sending invitePeer")
            //
            //            var aSession:MCSession! = PeerKit.session.availableSession(selectedPeer.displayName, peerName: MCNode.getMe().nodeName)
            //
            //            if aSession == nil {
            //                aSession = PeerKit.session.newSession(selectedPeer.displayName, peerName: MCNode.getMe().nodeName)
            //            }
            //
            // send an invite to the disconnected node
            transceiver.browser.mcBrowser?.invitePeer(selectedPeer, to: session, withContext: nil, timeout: 30.0)
        }
    }
}

extension NodesTableViewController: MCManagerDelegate {

    func foundPeer() {
        self.tableView.reloadData()
    }
    
    func lostPeer() {
        self.tableView.reloadData()
    }
    
    func sessionDidChange() {
        print("session did change state called")
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
}
