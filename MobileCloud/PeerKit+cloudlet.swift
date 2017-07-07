//
//  PeerKit+cloudlet.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 24/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public typealias PeerCloudletBlock = ((_ myPeerID: MCPeerID, _ cloudletID: Cloudlet) -> Void)

public var onCloudletConnect: PeerCloudletBlock?
