
# selerio-arkit-basics



Welcome to our demo app for ARKit!



To get started:


- Get your API Key* [here] (https://console.selerio.io).  

- Clone this [repo](https://github.com/selerio/selerio-arkit-basics.git)

- Open the project in xcode by clicking on `SelerioARKitBasics.xcodeproject`

- Modify `selerioAPIKey` inside `ViewController.swift` with your own API Key if you have one*.

- Build the project and run it on an ARKit compatible iOS device

Minimum requirements: Xcode >=10.0, iOS >=12.0

* Have not yet been granted access to the console? You will still be able to get started with the default api key inside the app. We may deactivate this key in the future though, so ping us here or on [Slack](https://selerio-dev.slack.com) to get access today!

Modifying the AR filter

Edit the function `func nodeForSmartAnchor(_ anchor: ARSmartAnchor) -> SCNNode` in the ViewController to attach AR filters to the objects of you choice. Objects we currently support are: `laptop, bottle, cup, bowl, chair, couch, etc`.



![Demo](./demo.gif)
