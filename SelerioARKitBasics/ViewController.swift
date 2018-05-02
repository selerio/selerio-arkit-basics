//
//  ViewController.swift
//  SelerioARKitBasics
//
//  Created by Flora Tasse on 01/05/2018.
//  Copyright © 2018 Flora Tasse. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

import SelerioARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSmartSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var smartSession: ARSmartSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ViewController.handleTap(tapRecognizer:))))
        
        smartSession = ARSmartSession(apiKey: "APIKEY", sceneView: sceneView)
        smartSession.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        smartSession.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        smartSession.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let smartAnchor = anchor as? ARSmartAnchor {
            smartAnchor.loadGeometry { (geometry, error) in
                if (error != nil) {
                    print("Error: \(String(describing: error))")
                } else {
                    node.addChildNode(SCNNode(geometry: geometry))
                }
            }
            let textNode = SCNNode(geometry: SCNText(string: smartAnchor.label, extrusionDepth: 0.01))
            let textBoundingBox = textNode.boundingBox
            textNode.pivot = SCNMatrix4MakeTranslation((textBoundingBox.max.x - textBoundingBox.min.x) / 2, 0, 0)
            textNode.position = SCNVector3(0.0, 0.45, 0.0)
            textNode.scale = SCNVector3(0.008/node.scale.x, 0.008/node.scale.y, 0.008/node.scale.z)
            textNode.geometry?.firstMaterial?.lightingModel = .constant
            node.addChildNode(textNode)
        }
    }
    
    // MARK: - ARSmartSessionDelegate
    func session(_ session: ARSmartSession, didFailWithError error: Error) {
        print("Smart Session Error: \(error)")
    }
    
    func session(_ session: ARSmartSession, didDetectScene scene: ARPhysicalScene?) {
        if let scene = scene {
            print("Number of physical objects: ", scene.anchors.count)
        } else {
            print("Scene not detected")
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Gestures
    
    @objc func handleTap(tapRecognizer: UITapGestureRecognizer) {
        smartSession.detect()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            sceneView.scene = SCNScene(named: "art.scnassets/ship.scn")!
            smartSession = ARSmartSession(apiKey: "APIKEY", sceneView: sceneView)
            smartSession.run()
        }
    }
}
