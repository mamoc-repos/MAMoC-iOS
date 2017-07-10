# MobileEdgeCloud
A Swift framework for running jobs on nearby devices, cloudlets, and remote clouds. This framework enables discovering other devices over standard LAN and ad-hoc peer-to-peer WiFi or Bluetooth networks. It also allows devices to connect to nearby fixed (cloudlets) or remote cloud servers and communicate over a web socket.

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

### Multipeer Connectivity 
This uses Apple's [MutipeerConnectivity](https://developer.apple.com/reference/multipeerconnectivity) framework. The Multipeer Connectivity framework supports the discovery of services provided by nearby devices and supports communicating with those services through message-based data, streaming data, and resources (such as files). In iOS, the framework uses infrastructure Wi-Fi networks, peer-to-peer Wi-Fi, and Bluetooth personal area networks for the underlying transport. In macOS and tvOS, it uses infrastructure Wi-Fi, peer-to-peer Wi-Fi, and Ethernet. Each `MCSession` supports up to 8 peers, including the local peer.

## Installation

### Cocoapods
TBD

### Manual
TBD
