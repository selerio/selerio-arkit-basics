//
//  ViewController.swift
//  SelerioARKitExample
//
//  Created by Flora Tasse on 15/11/2018.
//  Copyright © 2018 Flora Tasse. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SelerioARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSmartSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var label = UILabel()
    var toast = UIVisualEffectView()
    
    var smartSession : ARSmartSession!
    var frameHandler : ARSessionDelegateHandler!
    
    let selerioAPIKey = "l8iE3UpIbd95tbPq" // You should use your own API Key from https://console.selerio.io
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        // UI gestures
        let handleSwipeLeftGestureRecon = UISwipeGestureRecognizer(target: self,
                                                                   action: #selector(userSwipeLeft))
        sceneView.addGestureRecognizer(handleSwipeLeftGestureRecon)
        let handleTapGestureRecon = UITapGestureRecognizer(target: self,
                                                           action: #selector(userTappedScreen))
        sceneView.addGestureRecognizer(handleTapGestureRecon)


        // *** Integrate Selerio SDK ***

        // Create a smart session
        smartSession = ARSmartSession(apiKey: selerioAPIKey, sceneView: sceneView)
        smartSession.delegate = self

        // Assign a delegate for processing frames from the arkit session
        frameHandler = ARSessionDelegateHandler(session: smartSession)
        sceneView.session.delegate = frameHandler
        
        // Run the session
        smartSession.run()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.automaticallyUpdatesLighting = true
        
        self.setupToast()
        self.showToast("1. Move around to map your space.\t\n  2. Tap on the map to drop tennis balls. \n3. Swipe right to toggle debug mode. ")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        smartSession.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let smartAnchor = anchor as? ARSmartAnchor {
            return nodeForSmartAnchor(smartAnchor)
        }
        let node = SCNNode()
        return node
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - ARSmartSessionDelegate
    
    // *** Integrate Selerio SDK ***
    
    func session(_ session: ARSmartSession, didFailWithError error: Error) {
        print("ARSmartSession error: \(error)")
    }
    
    func session(_ session: ARSmartSession, didDetectScene scene: ARPhysicalScene?) {
        if let scene = scene {
            print("Number of smart anchors detected: \(scene.anchors.count)")
        } else {
            print("No smart anchor has yet been detected.")
        }
    }
    
    // *** AR Interactions ***
    func nodeForSmartAnchor(_ anchor: ARSmartAnchor) -> SCNNode {
        let node = SCNNode()
        if anchor.label == "laptop" {
            createSCNNodeFromTextureURL(url: URL(string:"https://media.giphy.com/media/3o7aCSxsasvg9LjJDy/giphy.gif")!) { asset in
                if let asset = asset {
                    asset.position = SCNVector3(0.0,0.15,0.03)
                    asset.scale = SCNVector3(0.3,0.3,0.3)
                    node.addChildNode(asset)
                }
            }
        }
        return node
    }

    //Drop tennis balls in the scene
    @objc func userTappedScreen(_ sender: UITapGestureRecognizer) {
        // Get the 2D point of the touch in the SceneView
        let tapPoint: CGPoint = sender.location(in: self.sceneView)
        let targetPosition: SCNVector3? = hitTestLocation(sceneView: sceneView, tapPoint: tapPoint)

        if (targetPosition == nil) {
            return;
        }

        //Create ball
        let sphere = SCNSphere(radius: 0.08)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/TennisBallColorMap.jpg")
        
        let newBall = addVirtualObjectAt(geometry: sphere, position: targetPosition!)
        sceneView.scene.rootNode.addChildNode(newBall)
    }

    //Toggle view of mapping mesh
    @objc func userSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        self.smartSession.toggleDebugMode()
    }
    
}
