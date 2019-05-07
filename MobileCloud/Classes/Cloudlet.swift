//
//  Cloudlet.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 20/05/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
//import Starscream
import Swamp

// used for cloudlet connections
//public let CloudletDefaultURL = "192.168.x.x:8080"

public var isCloudletConnected = false

public class Cloudlet: NSObject {
    var displayName: String
    var swampSession: SwampSession!
    
    init(name: String, cloudletURL: String) {
        self.displayName = name
        
        let swampTransport = WebSocketSwampTransport(wsEndpoint: URL(string: "ws://18.130.29.6:8080/ws")!)
        swampSession = SwampSession(realm: "mamoc_realm", transport: swampTransport)
        // Set delegate for callbacks
        // swampSession.delegate = <SwampSessionDelegate implementation>
        swampSession.connect()
        
    }
    
    public func send(json: String) {
        
        if swampSession.isConnected() {
            debugPrint("Swamp connected!")
            
            swampSession.call("uk.ac.standrews.cs.mamoc.search", args: ["large", "hey"],
                              onSuccess: { details, results, kwResults in
                                // Usually result is in results[0], but do a manual check in your infrastructure
                                
                                let result:NSArray = results! as NSArray
                                debugPrint("found: \(result[0])")
                                debugPrint("duration: \(result[1])")
            },
                              onError: { details, error, args, kwargs in
                                // Handle your error here (You can ignore args kwargs in most cases)
                                print("proc call failed!")
                                
                                self.swampSession.subscribe("uk.ac.standrews.cs.mamoc.offloadingresult", onSuccess: { subscription in
                                    // subscription can be stored for subscription.cancel()
                                     print("successfully subcribed to \(subscription)")
                                }, onError: { details, error in
                                    print("subscribe failed")
                                }, onEvent: { details, results, kwResults in
                                    // Event data is usually in results, but manually check blabla yadayada
                                    print("results: \(results[0])")
                                })
                                
                                self.swampSession.publish("uk.ac.standrews.cs.mamoc.offloading", options: ["disclose_me": true],  args: ["iOS", "uk.ac.standrews.cs.mamoc.SearchText.KMP", "swift code"],
                                                onSuccess: {
                                                    // Publication has been published!
                                                    print("successfully published")
                                }, onError: { details, error in
                                    // Handle error (What can it be except wamp.error.not_authorized?)
                                    print("publish failed")
                                })
            })
            
        } else {
            debugPrint("Swamp not connected")
        }
    }
    
    func isConnected() -> Bool{
        return swampSession.isConnected()
    }
}
