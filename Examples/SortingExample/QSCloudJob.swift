//
//  TSCloudletJob.swift
//  iOSExamples
//
//  Created by Dawand Sulaiman on 30/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation
import MobileCloud

public class QSCloudJob: CloudletJob {
    
    open var arrayOfWords: [String]?

    public override init() {
        super.init()
    }
    
    open override func id() -> UInt32 {
        return 4149558881
    }
    
    open override func name() -> String {
        return "Cloudlet Sorting Tool"
    }
    
    open override func initTask(_ cloudlet:Cloudlet) -> QSTask {
        arrayOfWords = getTextToSort(1,peerNumber: 0)
        return QSTask(peerCount: 1, peerNumber: 1, wordList: arrayOfWords!)
    }
    
    fileprivate func getTextToSort(_ peerCount:Int, peerNumber:Int) -> [String] {
        do {
            // This solution assumes  you've got the file in your bundle
            if let path = Bundle.main.path(forResource: "bigText", ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                arrayOfWords = data.components(separatedBy: "\n")
            }
        } catch let err as NSError {
            // do something with Error
            print(err)
        }
        
        let peerCountD:Double = Double(peerCount)
        let peerNumberD:Double = Double(peerNumber)
        
        var startIndex = 0
        var endIndex = (arrayOfWords?.count)!
        
        if(peerNumber == 0) {
            startIndex = 0
        } else {
            startIndex += Int(floor((peerNumberD/peerCountD)*Double((arrayOfWords?.count)!)))
            while(startIndex > (arrayOfWords?.startIndex)! && (arrayOfWords?[startIndex] != "\n")) {
                startIndex = (arrayOfWords?.index(startIndex, offsetBy: -1))!
            }
        }
        
        if(peerNumber + 1 == peerCount) {
            endIndex = (arrayOfWords?.count)!
        } else {
            endIndex += Int(floor((peerNumberD/peerCountD)*Double((arrayOfWords?.count)!)))
            while(endIndex > (arrayOfWords?.startIndex)! && (arrayOfWords?[endIndex] != "\n")) {
                endIndex = (arrayOfWords?.index(endIndex, offsetBy: -1))!
            }
        }
        
        debugPrint("startIndex \(startIndex), endIndex \(endIndex)")
        
        return Array(arrayOfWords![startIndex..<endIndex])
    }

    // TODO: customise this so that auto offloading can use custom parameter settings
    open override func executeTask(_ cloudlet:Cloudlet, task: MCTask) {
    //    let sortTask:QSTask = task as! QSTask
    //    let words = sortTask.wordList!.flatMap({$0}).joined()
        // supply name of file, start and end indexes
        cloudlet.send(json:"{\"Sorting\":\"bigText\",\"start\":0, \"end\":0}")
        
    }
    
    open func searchLog(_ format:String) {
        NSLog(format)
        self.onLog(format)
    }
    
    open override func onLog(_ format:String) {
        SwiftEventBus.post("Sorting log", sender: format as AnyObject)
    }
}
