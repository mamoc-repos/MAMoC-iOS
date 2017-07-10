# MobileEdgeCloud
A Swift framework for running compute-intensive tasks on nearby devices, cloudlets, and remote clouds. This framework enables discovering other devices over standard LAN and ad-hoc peer-to-peer WiFi or Bluetooth networks. It also allows devices to connect to nearby fixed (cloudlets) or remote cloud servers and communicate over a web socket.

## What is it for?

### Text Search Example
```Swift
// start the framework
let mc = MobileCloud.MCInstance
mc.start()
// set the job
mc.setJob(job: TSJob())
// set the parameters
(mc.getJob() as! TSJob).searchTerm = textSearchField.text!
// execute the job
mc.execute(type: OffloadingType.auto)
```

There are two working examples provided as app targets when you open the XCode project. 

For setting up the container on both cloudlet and remote clouds check the [documentation](https://github.com/dawand/MobileEdgeCloud/wiki/Documentation).

## Installation

### Cocoapods
TBD

### Manual
TBD

## Enabling Technologies

### Multipeer Connectivity 
This uses Apple's [MutipeerConnectivity](https://developer.apple.com/reference/multipeerconnectivity) framework. The Multipeer Connectivity framework supports the discovery of services provided by nearby devices and supports communicating with those services through message-based data, streaming data, and resources (such as files). In iOS, the framework uses infrastructure Wi-Fi networks, peer-to-peer Wi-Fi, and Bluetooth personal area networks for the underlying transport. In macOS and tvOS, it uses infrastructure Wi-Fi, peer-to-peer Wi-Fi, and Ethernet. Each `MCSession` supports up to 8 peers, including the local peer.

## Open source third party libraries
- [PeerKit](https://github.com/jpsim/PeerKit) (An open-source Swift framework for building event-driven, zero-config Multipeer Connectivity apps)
- [Starscream](https://github.com/daltoniam/Starscream) (Websockets in swift for iOS and OSX)
- [SwiftEventBus](https://github.com/cesarferreira/SwiftEventBus) (A publish/subscribe EventBus optimized for iOS)
- [Luminous](https://github.com/andrealufino/Luminous) (iOS system information )
- [iOS-System-Services](https://github.com/Shmoopi/iOS-System-Services) (iOS System Services is a class to gather all available information about a device.)
- [Vapor](https://github.com/vapor/vapor) (A server-side Swift web framework)

## TODO

- [x] Cloudlet setup on local and remote servers
- [ ] Cloudlet container migration for user mobility
- [ ] Document the API
