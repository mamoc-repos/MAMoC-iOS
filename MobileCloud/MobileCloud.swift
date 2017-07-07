//
//  MobileCloud.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 05/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MCManagerDelegate {
    func foundPeer()
    func lostPeer()
    func sessionDidChange()
}

open class MobileCloud {
    open static let MCInstance = MobileCloud() // singleton
    
    fileprivate var job: MCJob = MCJob()
    fileprivate var cloudletJob: CloudletJob = CloudletJob()
    
    // used to time stuff
    fileprivate let processTaskTimer:MCTimer = MCTimer()
    fileprivate let executionTimer:MCTimer = MCTimer()
    fileprivate let mergeResultsTimer:MCTimer = MCTimer()
    
    public var PeerName = MCNode.getMe().nodeName
    
    public var connectedNodes: [MCNode] {
        var nodes: [MCNode] = []
        
        let mcPeerIDs: [MCPeerID] = (session.connectedPeers)
        for peerID in mcPeerIDs {
            nodes.append(MCNode(peerID.displayName, mcPeerID: peerID))
        }
        return nodes
    }
    
    var allLocalNodes: [MCNode] { return [MCNode.getMe()] + connectedNodes }

    // TODO: create session to manage multiple cloudlets
    // open var allCloudlets: [Cloudlet]
    
    public var cloudletInstance: Cloudlet!

    // MARK: Start
    public func start() {
        // for nearby iOS devices
        let ServiceType:String = "MC2017"
        self.MCLog("Searching for peers with service type " + ServiceType)
        transceiver.startTransceiving(serviceType: ServiceType)
        
        // for cloudlet connection
        cloudletInstance = Cloudlet(name: "cloudlet")
    }
    
    fileprivate func MCLog(_ format:String) {
        job.onLog(format)
    }
    
    open func getJob() -> MCJob {
        return job
    }
    
    public func setJob(job: MCJob){
        self.job = job
                
        // When a peer connects, log the connection and delegate to the tool
        onConnect = { (myPeerID: MCPeerID, connectedpeerID: MCPeerID) -> Void in
            let selfNode:MCNode = MCNode.getMe()
            let peerNode:MCNode = MCNode(connectedpeerID.displayName, mcPeerID: connectedpeerID)
            
            // make sure this is you!
            if(myPeerID != selfNode.mcPeerID) {
                self.MCLog("ERROR: Node id: " + selfNode.mcPeerID.displayName + " does not match peerID: " + myPeerID.displayName + ".")
            }
            
            self.MCLog(selfNode.description + " connected to " + peerNode.description)
            job.onPeerConnect(selfNode, connectedNode: peerNode)
        }
        
        // When a peer disconnects, log the disconnection and delegate to the tool
        onDisconnect = { (myPeerID: MCPeerID, disconnectedpeerID: MCPeerID) -> Void in
            let selfNode:MCNode = MCNode.getMe()
            let peerNode:MCNode = MCNode(disconnectedpeerID.displayName, mcPeerID: disconnectedpeerID)
            
            // make sure this is you!
            if(myPeerID != selfNode.mcPeerID) {
                self.MCLog("ERROR: Node id: " + selfNode.mcPeerID.displayName + " does not match peerID: " + myPeerID.displayName + ".")
            }
            
            self.MCLog(peerNode.description + " disconnected from " + selfNode.description)
            job.onPeerDisconnect(selfNode, disconnectedNode: peerNode)
        }
        
        // when a work request comes over the air, have the tool process the work
        eventBlocks[Task.offloadingEvent.rawValue + String(job.id())] = { (fromPeerID: MCPeerID, object: AnyObject?) -> Void in
            
            // run on background thread
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
                let selfNode:MCNode = MCNode.getMe()
                let fromNode:MCNode = MCNode(fromPeerID.displayName, mcPeerID: fromPeerID)
                
                // deserialize the work
                let dataReceived = NSKeyedUnarchiver.unarchiveObject(with: object as! Data) as! [String: NSObject]
                let sessionUUID:String = dataReceived["SessionID"] as! String
                let peerTask:MCTask =  NSKeyedUnarchiver.unarchiveObject(with: dataReceived["MCTask"] as! Data) as! MCTask
                
                let workMirror = Mirror(reflecting: peerTask)
                
                self.MCLog(selfNode.description + " received \(workMirror.subjectType) to process from " + fromNode.description + " for session " + sessionUUID + ".  Starting to process work.")
                
                // process the work, and get a result
                self.processTaskTimer.start()
                let peerResult:MCResult = self.job.executeTask(fromNode, fromNode: fromNode, task: peerTask)
                self.processTaskTimer.stop()
                
                let dataToSend:[String:NSObject] =
                    ["MCResult": NSKeyedArchiver.archivedData(withRootObject: peerResult) as NSObject,
                     "processTaskTimer": self.processTaskTimer.getElapsedTimeInSeconds() as NSObject,
                     "SessionID": sessionUUID as NSObject]
                
                let peerResultMirror = Mirror(reflecting: peerResult)
                
                self.MCLog(selfNode.description + " done processing work.  Sending \(peerResultMirror.subjectType) back.")
                
                // send the result back to the session
                sendEvent(Task.fetchingResult.rawValue + sessionUUID, object: NSKeyedArchiver.archivedData(withRootObject: dataToSend) as AnyObject, toPeers: [fromPeerID])
                self.MCLog("Sent result.")
            }
        }
        
        onCloudletConnect = { (myPeerID: MCPeerID, cloudlet: Cloudlet) -> Void in
            let selfNode:MCNode = MCNode.getMe()
            let cloudletNode:Cloudlet = Cloudlet(name:cloudlet.displayName)
            
            // make sure this is you!
            if(myPeerID != selfNode.mcPeerID) {
                self.MCLog("ERROR: Node id: " + selfNode.mcPeerID.displayName + " does not match peerID: " + myPeerID.displayName + ".")
            }
            
            self.MCLog(selfNode.description + " connected to " + cloudletNode.displayName)
        }
    }
    
    /*
    MARK: Custom app should call this method.
     */
    public func execute(type: OffloadingType) -> Void {
        
        switch type {
            
        case .local:
            // run on background thread
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
                self.executeOnThread(self.allLocalNodes)
            }
            break
    
        case .cloudlet:
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
                self.executeOnCloudlet()
            }
            break
    
        case .remote:
            self.executeOnRemote()
            break
        
        case .auto:
            break
            
            }
    }
    
    public func getCloudletJob() -> CloudletJob{
        return cloudletJob
    }
    
    public func setCloudletJob(job: CloudletJob) {
        self.cloudletJob = job
    }
    
    func executeOnCloudlet(){
        
        let cloudletTask:MCTask = self.cloudletJob.initTask(cloudletInstance)
        self.MCLog("Creating task for \(cloudletInstance.displayName)")
        
        self.cloudletJob.executeTask(cloudletInstance, task: cloudletTask)
        self.MCLog("Sending task to \(cloudletInstance.displayName)")

        webSocket.onText = { [unowned self] text in
            guard let data = text.data(using: String.Encoding.utf8) else { return }
            guard let js = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary else { return }
            guard let result = js["result"] as? Int, let time = js["timeInSec"] as? Double
                else { return }
            
            self.MCLog(self.cloudletInstance.displayName + " returned the result: \(result) in \(time) seconds")
        }
    }
    
    func executeOnRemote(){
        
    }
    
    /**
     Runs your FMTool on a subset of the nodes in the network.  Your app should call this or execute().
     
     - parameter onNodes: A subset of the nodes in your network that should run your tool.
     */
    public func execute(_ onNodes:[MCNode]) -> Void {
        
        // make sure the nodes your app passed in are actually still in the network
        var nodesInNetwork:[MCNode] = []
        for n in onNodes {
            if(connectedNodes.contains(n)) {
                nodesInNetwork.append(n)
            } else {
                MCLog("Network does not contain node \(n.description).  Excluding this node from execution.")
            }
        }
        
        // run on background thread
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            self.executeOnThread(nodesInNetwork)
        }
    }
    
    /**
     
     Runs your FMTool.
     
     */
    fileprivate func executeOnThread(_ onNodes:[MCNode]) -> Void {
        // time how long the entire execution takes
        executionTimer.start()
        
        // this is a uuid to keep track on this session (a round of execution).  It's mostly used to make sure requests and responses happen correctly for a single session.
        let sessionUUID:String = UUID().uuidString
        
        // create new data structures for this session
        mcPeerIDToNode[sessionUUID] = [MCPeerID:MCNode]()
        nodeToWork[sessionUUID] = [MCNode:MCTask]()
        nodeToResult[sessionUUID] = [MCNode:MCResult]()
        nodeToRoundTripTimer[sessionUUID] = [MCNode:MCTimer]()
        
        for node in onNodes {
            mcPeerIDToNode[sessionUUID]![node.mcPeerID] = node
        }
        
        let numberOfNodes:UInt = UInt(mcPeerIDToNode[sessionUUID]!.count)
        self.MCLog("Executing " + job.name() + " in session " + sessionUUID + " on \(numberOfNodes) nodes (including myself).")
        
        // when a result comes back over the air for this session
        eventBlocks[Task.fetchingResult.rawValue + sessionUUID] = { (fromPeerID: MCPeerID, object: AnyObject?) -> Void in
            let selfNode:MCNode = MCNode.getMe()
            
            // deserialize the result!
            let dataReceived:[String: NSObject] = NSKeyedUnarchiver.unarchiveObject(with: object as! Data) as! [String: NSObject]
            let receivedSessionUUID:String = dataReceived["SessionID"] as! String
            let processWorkTime:Double = dataReceived["processTaskTimer"] as! Double
            
            // make sure this is the same session!
            if(mcPeerIDToNode.keys.contains(receivedSessionUUID)) {
                // store the result and merge results if needed
                lock.sync {
                    let fromNode:MCNode = mcPeerIDToNode[receivedSessionUUID]![fromPeerID]!
                    let peerResult:MCResult = NSKeyedUnarchiver.unarchiveObject(with: dataReceived["MCResult"] as! Data) as! MCResult
                    let peerResultMirror = Mirror(reflecting: peerResult)
                    
                    let roundTripTime:CFAbsoluteTime = (nodeToRoundTripTimer[receivedSessionUUID]![fromNode]?.stop())!
                    self.MCLog(selfNode.description + " received \(peerResultMirror.subjectType) in session " + receivedSessionUUID + " from " + fromNode.description + ", storing result.")
                    self.MCLog(fromNode.description + " round trip time: " + String(format: "%.3f", roundTripTime) + " seconds.")
                    self.MCLog(fromNode.description + " process work time: " + String(format: "%.3f", processWorkTime) + " seconds.")
                    self.MCLog(fromNode.description + " network/data transfer and overhead time: " + String(format: "%.3f", roundTripTime - processWorkTime) + " seconds.")
                    
                    nodeToResult[receivedSessionUUID]![fromNode] = peerResult
                    self.finishAndMerge(fromNode, sessionUUID: receivedSessionUUID)
                }
            } else {
                // the likelyhood of this occuring is small.
                self.MCLog(selfNode.description + " received result for session " + receivedSessionUUID + ", but that session no longer exists.  Discarding work.")
            }
        }
        
        // my work
        var selfWork:MCTask?
        // make the work for each node
        var nodeCount:UInt = 0
        for (_, node) in mcPeerIDToNode[sessionUUID]! {
            if(node == MCNode.getMe()) {
                self.MCLog("Creating self work.")
            } else {
                self.MCLog("Creating work for " + node.description)
            }
            let work:MCTask = self.job.initTask(node, nodeNumber: nodeCount, totalNodes: numberOfNodes)
            if(node == MCNode.getMe()) {
                selfWork = work
            }
            nodeToWork[sessionUUID]![node] = work
            nodeToRoundTripTimer[sessionUUID]![node] = MCTimer()
            nodeCount += 1
        }
        
        // send out all the work
        for (node, work) in nodeToWork[sessionUUID]! {
            if(node != MCNode.getMe()) {
                self.MCLog("Sending work to " + node.description)
                
                let data:[String:NSObject] =
                    ["MCTask": NSKeyedArchiver.archivedData(withRootObject: work) as NSObject,
                     "SessionID": sessionUUID as NSObject]
                lock.sync {
                    nodeToRoundTripTimer[sessionUUID]![node]?.start()
                }
                
                sendEvent(Task.offloadingEvent.rawValue + String(job.id()), object: NSKeyedArchiver.archivedData(withRootObject: data) as AnyObject, toPeers: [node.mcPeerID])
            }
        }
        
        var selfResult:MCResult?
        if(selfWork != nil) {
            // process your own work
            self.MCLog("Processing self work.")
            lock.sync {
                nodeToRoundTripTimer[sessionUUID]![MCNode.getMe()]?.start()
            }
            
            selfResult = self.job.executeTask(MCNode.getMe(), fromNode: MCNode.getMe(), task: selfWork!)
        }
        
        // store the result and merge results if needed
        lock.sync {
            var selfTimeToFinish:Double = 0
            if(selfResult != nil) {
                selfTimeToFinish = (nodeToRoundTripTimer[sessionUUID]![MCNode.getMe()]?.stop())!
                self.MCLog(MCNode.getMe().description + " process work time: " + String(format: "%.3f", selfTimeToFinish) + " seconds.")
                self.MCLog("Storing self work result.")
                nodeToResult[sessionUUID]![MCNode.getMe()] = selfResult!
            }
            
            let status = finishAndMerge(MCNode.getMe(), sessionUUID: sessionUUID)
            // schedule the reprocessing stuff
            if(status == false) {
            //    let data:[String:NSObject] = ["SessionID": sessionUUID as NSObject, "SelfTimeToFinish":selfTimeToFinish as NSObject]
                DispatchQueue.main.async {
                    // wait the minTime before startinf to reprocess
//                    Timer.scheduledTimer(timeInterval: self.minWaitTimeToStartReprocessingWorkInSeconds, target: self, selector: #selector(MobileCloud.scheduleReprocessWork(_:)), userInfo: data, repeats: false)
                    debugPrint("work did not complete successfully. need to reprocess")
                }
            }
        }
    }
    
    fileprivate func finishAndMerge(_ callerNode:MCNode, sessionUUID:String) -> Bool {
        var status:Bool = false
        // did we get all the results, yet?
        if(nodeToWork[sessionUUID]!.count == nodeToResult[sessionUUID]!.count) {
            // remove sendResultEvent from peerpack for this session so we don't get future extraneous messages that we don't know what do to with
            eventBlocks.removeValue(forKey: Task.fetchingResult.rawValue + sessionUUID)
            
            self.MCLog(MCNode.getMe().description + " received all \(nodeToResult[sessionUUID]!.count) results for session " + sessionUUID + ".  Merging results.")
            mergeResultsTimer.start()
            self.job.mergeResults(MCNode.getMe(), nodeToResult: nodeToResult[sessionUUID]!)
            mergeResultsTimer.stop()
            
            self.MCLog("Merge results time for " + job.name() + ": " + String(format: "%.3f", mergeResultsTimer.getElapsedTimeInSeconds()) + " seconds.")
            executionTimer.stop()
            
            // remove session information from data structures
            mcPeerIDToNode.removeValue(forKey: sessionUUID)
            nodeToWork.removeValue(forKey: sessionUUID)
            nodeToResult.removeValue(forKey: sessionUUID)
            nodeToRoundTripTimer.removeValue(forKey: sessionUUID)
            self.MCLog("Total execution time for " + job.name() + ": " + String(format: "%.3f", executionTimer.getElapsedTimeInSeconds()) + " seconds.")
            status = true
        }
        return status
    }
}
