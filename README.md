# MobileEdgeCloud
A Swift framework for running jobs on nearby devices, cloudlets, and remote clouds. This framework enables discovering other devices over standard LAN and ad-hoc peer-to-peer WiFi or Bluetooth networks. It also allows devices to connect to nearby fixed (cloudlets) or remote cloud servers and communicate over a web socket.

## What is it for?

## Text Search Example
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

## Installation

### Cocoapods
TBD

### Manual
TBD
