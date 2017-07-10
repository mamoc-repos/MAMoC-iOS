import Foundation
import MobileCloud

open class TSJob: MCJob {
   
    var searchTerm:String?
    var textToSearch:String = ""
    
    public override init() {
        super.init()
    }
    
    open override func id() -> UInt32 {
        return 4149558881
    }
    
    open override func name() -> String {
        return "Text Search Tool"
    }
    
    open override func initTask(_ node:MCNode, nodeNumber:UInt, totalNodes:UInt) -> TSTask {
        return TSTask(peerCount: Int(totalNodes), peerNumber: Int(nodeNumber), searchTerm: searchTerm!)
    }
    
    fileprivate func getTextToSearch(_ peerCount:Int, peerNumber:Int) -> String {
        
        // function to get the contents of the file
        self.textToSearch = readFile()
        
        let peerCountD:Double = Double(peerCount)
        let peerNumberD:Double = Double(peerNumber)
        
        let newline:Character = "\n"
        let numberOfCharacters:Int = textToSearch.characters.count
        var startIndex:String.CharacterView.Index
        var endIndex:String.CharacterView.Index
        
        if(peerNumber == 0) {
            startIndex = textToSearch.startIndex
        } else {
            startIndex = textToSearch.characters.index(textToSearch.startIndex, offsetBy: Int(floor((peerNumberD/peerCountD)*Double(numberOfCharacters))))
            while(startIndex > textToSearch.startIndex && (textToSearch[startIndex] != newline)) {
                startIndex = textToSearch.index(startIndex, offsetBy: -1)
            }
        }
        
        if(peerNumber + 1 == peerCount) {
            endIndex = textToSearch.endIndex
        } else {
            endIndex = textToSearch.characters.index(textToSearch.startIndex, offsetBy: Int(floor(((peerNumberD + 1)/peerCountD)*Double(numberOfCharacters))))
            while(endIndex > textToSearch.startIndex && (textToSearch[endIndex] != newline)) {
                endIndex = textToSearch.index(endIndex, offsetBy: -1)
            }
        }
        
        debugPrint("startIndex \(startIndex), endIndex \(endIndex)")
        
        return textToSearch[startIndex..<endIndex]
    }
    
    open override func executeTask(_ node:MCNode, fromNode:MCNode, task: MCTask) -> TSResult {
        let searchWork:TSTask = task as! TSTask
        let textFoundAt:[Int] = KMP(getTextToSearch(searchWork.peerCount, peerNumber: searchWork.peerNumber), pattern: searchWork.searchTerm)
        
        return TSResult(numberOfOccurrences: textFoundAt.count)
    }
    
    open override func mergeResults(_ node:MCNode, nodeToResult: [MCNode:MCResult]) -> Void {
        var totalNumberOfOccurrences:Int = 0
        for (n, result) in nodeToResult {
            let searchResult = result as! TSResult
            NSLog("Received result from node " + n.description)
            totalNumberOfOccurrences += searchResult.numberOfOccurrences
        }
        
        searchLog("The word '\(searchTerm!)' was found in \(totalNumberOfOccurrences) times in the text.\n")
    }
    
       
    open override func onPeerConnect(_ myNode:MCNode, connectedNode:MCNode) {
    }
    
    open override func onPeerDisconnect(_ myNode:MCNode, disconnectedNode:MCNode) {
    }
    
    open func searchLog(_ format:String) {
        NSLog(format)
        self.onLog(format)
    }
    
    open override func onLog(_ format:String) {
        SwiftEventBus.post("text search log", sender: format as AnyObject)
    }
}
