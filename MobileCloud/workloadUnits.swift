// Copyright (c) 2014 Primate Labs Inc.
// Use of this source code is governed by the 2-clause BSD license that
// can be found in the LICENSE file.

import Foundation

enum WorkloadUnits {
  case bytesSecond, pixelsSecond, flops, nodesSecond

  func string() -> String {
    switch self {
    case .bytesSecond:
      return "Bytes/Second"
    case .pixelsSecond:
      return "Pixels/Second"
    case .flops:
      return "Flops"
    case .nodesSecond:
      return "Nodes/Second"
    }
  }

  func stringFromRate(_ rate : Double) -> String {
    var outRate = rate
    var divisor : Double = 1000.0

    if self == .bytesSecond {
      divisor = 1024.0
    }

    let prefixes = ["", "K", "M", "G", "T"]
    var prefix = prefixes[0]

    for var i in 0 ..< prefixes.count {
      prefix = prefixes[i]

      if outRate < divisor {
        break
      }

      outRate /= divisor
        i += 1
    }

    let outRateString = NSString(format: "%.2f", outRate)
    let units = self.string()
    return "\(outRateString) \(prefix)\(units)"
  }
}
