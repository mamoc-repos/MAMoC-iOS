import Foundation
import MobileCloud

open class QSJob: MCJob {

    open var arrayOfWords = [String]()

    public override init() {
        super.init()
    }

    open override func id() -> UInt32 {
        return 4149558881
    }

    open override func name() -> String {
        return "Quicksort Tool"
    }

    open override func initTask(_ node:MCNode, nodeNumber:UInt, totalNodes:UInt) -> QSTask {
        return QSTask(peerCount: Int(totalNodes), peerNumber: Int(nodeNumber), wordList:arrayOfWords)
    }
    
    fileprivate func getTextToSort(_ peerCount:Int, peerNumber:Int) -> [String] {
        do {
            // This solution assumes  you've got the file in your bundle
            if let path = Bundle.main.path(forResource: "bigText", ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                arrayOfWords = data.components(separatedBy: " ")
                //    print(arrayOfStrings)
            }
        } catch let err as NSError {
            // do something with Error
            print(err)
        }
        
        let peerCountD:Double = Double(peerCount)
        let peerNumberD:Double = Double(peerNumber)
        
        var startIndex = 0
        var endIndex = arrayOfWords.count
        
        if(peerNumber == 0) {
            startIndex = 0
        } else {
            startIndex += Int(floor((peerNumberD/peerCountD)*Double(arrayOfWords.count)))
            while(startIndex > arrayOfWords.startIndex && (arrayOfWords[startIndex] != "\n")) {
                startIndex = arrayOfWords.index(startIndex, offsetBy: -1)
            }
        }
        
        if(peerNumber + 1 == peerCount) {
            endIndex = arrayOfWords.count
        } else {
            endIndex += Int(floor((peerNumberD/peerCountD)*Double(arrayOfWords.count)))
            while(endIndex > arrayOfWords.startIndex && arrayOfWords[endIndex] != "\n") {
                endIndex = arrayOfWords.index(endIndex, offsetBy: -1)
            }
        }
        
        debugPrint("startIndex \(startIndex), endIndex \(endIndex)")
        
        return Array(arrayOfWords[startIndex..<endIndex])
    }
    
    open override func executeTask(_ node:MCNode, fromNode:MCNode, task: MCTask) -> QSResult {
        let sortWork:QSTask = task as! QSTask
        let sorted:[String] = quicksort(getTextToSort(sortWork.peerCount, peerNumber: sortWork.peerNumber))
        
        return QSResult(sortedWords: sorted)
    }
    
    open override func mergeResults(_ node:MCNode, nodeToResult: [MCNode:MCResult]) -> Void {
        var finalSortedList = [String]()
        for (n, result) in nodeToResult {
            let sortResult = result as! QSResult
            NSLog("Received result from node " + n.description)
            for word in sortResult.sortedWords {
                finalSortedList.append(word)
            }
        }
   //     debugPrint(finalSortedList)
        finalSortedList = quicksort(finalSortedList)
   //     debugPrint(finalSortedList)
//      sortLog("The final sorted list is \(finalSortedList) \n")
    }

    open override func onPeerConnect(_ myNode:MCNode, connectedNode:MCNode) {
    }

    open override func onPeerDisconnect(_ myNode:MCNode, disconnectedNode:MCNode) {
    }

    open func sortLog(_ format:String) {
        NSLog(format)
        self.onLog(format)
    }

    open override func onLog(_ format:String) {
        SwiftEventBus.post("quick sort log", sender: format as AnyObject)
    }
}
