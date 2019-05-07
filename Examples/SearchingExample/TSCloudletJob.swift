//
//  TSCloudletJob.swift
//  iOSExamples
//
//  Created by Dawand Sulaiman on 30/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
import MobileCloud
import Swamp

public class TSCloudletJob: CloudletJob {
    
    var searchTerm:String?
    var textToSearch:String = ""
    
//    public override init() {
//        super.init()
//    }
    
    open override func id() -> UInt32 {
        return 4149558881
    }
    
    open override func name() -> String {
        return "Cloudlet Text Search Tool"
    }
    
    open override func initTask(_ cloudlet:Cloudlet) -> TSTask {
        return TSTask(peerCount: 1, peerNumber: 1, searchTerm: searchTerm!)
    }
    
    // TODO: customise this so that auto offloading can use custom parameter settings
    open override func executeTask(_ cloudlet:Cloudlet, task: MCTask) {
        let searchTask:TSTask = task as! TSTask
        cloudlet.send(json:"{\"TextSearch\":\"\(searchTask.searchTerm)\", \"start\":0, \"end\":0}")
        debugPrint("{\"TextSearch\":\"\(searchTask.searchTerm)\", \"start\":0, \"end\":0}")
    }
    
    open func searchLog(_ format:String) {
        NSLog(format)
        self.onLog(format)
    }
    
    open override func onLog(_ format:String) {
        SwiftEventBus.post("text search log", sender: format as AnyObject)
    }
}
