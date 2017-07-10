import Foundation
import MobileCloud

open class QSTask: MCTask {

    let peerCount: Int
    let peerNumber: Int

    init (peerCount: Int, peerNumber: Int) {
        self.peerCount = peerCount
        self.peerNumber = peerNumber
        super.init()
    }

    required public init(coder decoder: NSCoder) {
        self.peerCount = decoder.decodeInteger(forKey: "peerCount")
        self.peerNumber = decoder.decodeInteger(forKey: "peerNumber")

        super.init(coder: decoder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder);
        coder.encode(peerCount, forKey: "peerCount")
        coder.encode(peerNumber, forKey: "peerNumber")
    }
}
