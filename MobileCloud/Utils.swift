//
//  Utils.swift
//  MobileCloud
//
//  Created by Dawand Sulaiman on 17/06/2017.
//  Copyright © 2017 StAndrews. All rights reserved.
//

import Foundation

/* This class uses both Luminous and System Services open source libraries to get specific features from the connected nearby devices
 */
class Utils {

    static let system = SystemServices.init()

    // HARDWARE
    
    class func getNumberofCPUs() -> Int {
        return Luminous.System.Hardware.processorsNumber
    }
    
    class func getProcessorSpeed() -> Int {
        return system.processorSpeed
    }
    
    
    // NETWORK
    
    // return Wifi or Cellular - none if not connected
    class func getNetworkType() -> String {
        if Luminous.System.Network.isInternetAvailable {
            if Luminous.System.Network.isConnectedViaWiFi {
                return "WiFi"
            } else if Luminous.System.Network.isConnectedViaCellular {
                return "Cellular"
            } else {
                return "Some other network types!"
            }
        } else {
            return "none"
        }
    }
    
    class func getCurrentIPAddress() -> String {
        if let ip = system.currentIPAddress {
            return ip
        } else {
            return "NO IP Address returned"
        }
    }
    
    
    // BATTERY
    
    class func getBatteryDetails() -> [String:Float] {
        
        let batteryLevel = Luminous.System.Battery.level!
        
        switch Luminous.System.Battery.state {
        case .charging:
            return ["charging":batteryLevel]
        case .unplugged:
            return ["unplugged":batteryLevel]
        case .full:
            return ["full":batteryLevel]
        case .unknown:
            return ["unknown":0.0]
        }
    }
}
