import Foundation
import MobileCloud

open class QSTask: MCTask {

    let peerCount: Int
    let peerNumber: Int
    let wordList: [String]?
    
    init (peerCount: Int, peerNumber: Int, wordList:[String]) {
        self.peerCount = peerCount
        self.peerNumber = peerNumber
        self.wordList = wordList
        super.init()
    }

    required public init(coder decoder: NSCoder) {
        self.peerCount = decoder.decodeInteger(forKey: "peerCount")
        self.peerNumber = decoder.decodeInteger(forKey: "peerNumber")
        self.wordList = decoder.decodeObject(forKey: "wordList") as! [String]?
        super.init(coder: decoder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder);
        coder.encode(peerCount, forKey: "peerCount")
        coder.encode(peerNumber, forKey: "peerNumber")
        coder.encode(wordList, forKey: "wordList")
    }
}
