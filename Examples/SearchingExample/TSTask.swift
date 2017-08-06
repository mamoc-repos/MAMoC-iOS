import Foundation
import MobileCloud

open class TSTask: MCTask {

    let peerCount: Int
    let peerNumber: Int
    let searchTerm: String
//    let searchText: String
    
    init (peerCount: Int, peerNumber: Int, searchTerm: String, searchText:String = "") {
        self.peerCount = peerCount
        self.peerNumber = peerNumber
        self.searchTerm = searchTerm
 //       self.searchText = searchText
        super.init()
    }

    required public init(coder decoder: NSCoder) {
        self.peerCount = decoder.decodeInteger(forKey: "peerCount")
        self.peerNumber = decoder.decodeInteger(forKey: "peerNumber")
        self.searchTerm = decoder.decodeObject(forKey: "searchTerm") as! String
 //       self.searchText = decoder.decodeObject(forKey: "searchText") as! String

        super.init(coder: decoder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder);
        coder.encode(peerCount, forKey: "peerCount")
        coder.encode(peerNumber, forKey: "peerNumber")
        coder.encode(searchTerm, forKey: "searchTerm")
//        coder.encode(searchText, forKey: "searchText")
    }
}
