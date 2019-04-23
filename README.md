
# Welcome to Selerio demo app for iOS!

All of Selerio features are fully integrated with ARKit. You can use the new features Selerio provide as well as all the ARKit functionalities you know and love!


![Demo](./demo.gif)


**Getting started**

- Clone this repo

- call `pod install` from the root directory. Cocoapods needs to be installed.

- Open the project in xcode by clicking on `SelerioARKitBasics.xcworkspace`

- Get your SDK API Key from our [Console](https://console.selerio.io)  

- Modify `selerioAPIKey` inside `ViewController.swift` with your own API Key.

- Build the project and run it on an ARKit compatible iOS device (iPhone7 and above)

- Join us and others on <a href="https://selerio-dev.slack.com/" target="_blank">Slack</a>, for quick support!

Minimum requirements: Xcode >=10.0, iOS >=12.0

**Occlusion & Physics**

Occlusion and Physics are automatically enabled for free, for mapped areas. No need for extra setup.

**Modifying the AR filter**

Edit the function `func nodeForSmartAnchor(_ anchor: ARSmartAnchor) -> SCNNode` in the ViewController to attach AR filters to the objects of you choice. Objects we currently support are: `laptop, bottle, cup, bowl, chair, couch, etc`.

**Additional Documentation**

[Documentation](https://github.com/selerio/selerio-arkit-basics/tree/master/docs)

