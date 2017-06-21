//
//  OffloadingSettings.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 05/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public var disconnectedPeersDictionary = NSMutableDictionary()
public var connectingPeersDictionary = NSMutableDictionary()
public var connectedPeersDictionary = NSMutableDictionary()

// used to time stuff
public let processTaskTimer:MCTimer = MCTimer()
public let executionTimer:MCTimer = MCTimer()
public let mergeResultsTimer:MCTimer = MCTimer()

// the shortest time in seconds that FogMachine should wait before re-processing other nodes work.  The initiator will wait after completing it's work to start resechduling work.
public var minWaitTimeToStartReprocessingWorkInSeconds:Double = 8.0

// the longest time in seconds that Fog Machine should wait before re-processing other nodes work.  The initiator will wait after completing it's work to start resechduling work.
public var maxWaitTimeToStartReprocessingWorkInSeconds:Double = 60.0*5.0

/**
 The shortest time in seconds that FogMachine should wait before re-processing other nodes work.  (The default is set to 8 seconds)  The initiator will wait after completing it's work to start resechduling work.  Unless strict is set to true, Fog Machine will wait a bit longer to start reprocessing work based on the performance of the nodes in the network.
 
 - parameter time:   the shortest time in seconds that FogMachine should wait before re-processing other nodes work.
 - parameter strict: if true, the time provided as the first argument will be the exact time that re-processing the other nodes work begins.
 */
public func setWaitTimeUntilStartReprocessingWork(_ time:Double, strict:Bool = false) {
    minWaitTimeToStartReprocessingWorkInSeconds = max(time,0)
    if(strict) {
        maxWaitTimeToStartReprocessingWorkInSeconds = max(time,0)
    }
}

// all the data structures below are session dependant!
// used to control concurrency.  It synchronizes many of the data structures below
public let lock = DispatchQueue(label: "mil.nga.giat.fogmachine", attributes: [])

// keep a map of the session to the MCPeerIDs to the nodes for this session
public var mcPeerIDToNode:[String:[MCPeerID:MCNode]] = [String:[MCPeerID:MCNode]]()

// keep a map of the session to the Nodes to the works for this session, as nodes may come and go otherwise
public var nodeToWork:[String:[MCNode:MCTask]] = [String:[MCNode:MCTask]]()

// keep a map of the session to the Nodes to the results for this session, as nodes may come and go otherwise
public var nodeToResult:[String:[MCNode:MCResult]] = [String:[MCNode:MCResult]]()

// keep a map of the session to the Nodes to the roundTrip time.  The roundtrip time is the time it takes for a node to go out and come back
public var nodeToRoundTripTimer:[String:[MCNode:MCTimer]] = [String:[MCNode:MCTimer]]()

