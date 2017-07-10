import Foundation
import MobileCloud

open class QSResult: MCResult {

    let sortedWords:[String]

    init (sortedWords: [String]) {
        self.sortedWords = sortedWords
        super.init()
    }

    required public init(coder decoder: NSCoder) {
        self.sortedWords = decoder.decodeObject(forKey: "sortedWords") as! [String]
        super.init(coder: decoder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder);
        coder.encode(sortedWords, forKey: "sortedWords")
    }
}
