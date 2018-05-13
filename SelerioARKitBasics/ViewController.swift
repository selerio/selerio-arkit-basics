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
    var label = UILabel()
    var toast = UIVisualEffectView()
    
    var smartSession: ARSmartSession!
    var apiKey = "API-KEY"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
        
        smartSession = ARSmartSession(apiKey: apiKey, sceneView: sceneView)
        smartSession.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        if #available(iOS 11.3, *) {
            configuration.planeDetection = [.horizontal, .vertical]
        } else {
            // Fallback on earlier versions
            configuration.planeDetection = [.horizontal]
        }

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
        DispatchQueue.main.async {
            self.showToast("error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: ARSmartSession, didDetectScene scene: ARPhysicalScene?) {
        if let scene = scene {
            print("Successfully retrieved \(scene.anchors.count) objects")
            DispatchQueue.main.async {
                self.hideToast()
            }
        } else {
            print("Scene not detected")
            DispatchQueue.main.async {
                self.showToast("No objects detected")
            }
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
    
    @objc func handleTap(sender: Any) {
        smartSession.detect()
        showToast("Finding smart anchors")
    }
    
    @objc func handleDebugSwitch(sender: Any) {
        smartSession.togglePointCloudVisualization()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            smartSession.reinitialize()
        }
    }
}

extension ViewController {
    func showToast(_ text: String) {
        label.text = text
        
        guard toast.alpha == 0 else {
            return
        }
        
        toast.layer.masksToBounds = true
        toast.layer.cornerRadius = 7.5
        
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 1
            self.toast.frame = self.toast.frame.insetBy(dx: -5, dy: -5)
        })
        
    }
    
    func hideToast() {
        UIView.animate(withDuration: 0.25, animations: {
            self.toast.alpha = 0
            self.toast.frame = self.toast.frame.insetBy(dx: 5, dy: 5)
        })
    }
    
    func setupSubviews() {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.clear
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(overlayView)
        
        toast.effect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        toast.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(toast)
        toast.layer.cornerRadius = 5
        toast.clipsToBounds = true
        
        let contentView = toast.contentView
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        contentView.addSubview(label)
        
        let toolsView = UIVisualEffectView()
        toolsView.translatesAutoresizingMaskIntoConstraints = false
        toolsView.layer.cornerRadius = 10
        overlayView.addSubview(toolsView)
        let toggleDebugSwitch = UISwitch()
        let toggleDebugLabel = UILabel()
        let detectButton = UIButton.init(type: .roundedRect)
        toggleDebugLabel.text = "AR points"
        toggleDebugLabel.textColor = .white
        toggleDebugLabel.font = toggleDebugLabel.font.withSize(16)
        toggleDebugSwitch.isOn = true
        detectButton.setTitle("Detect", for: .normal)
        detectButton.layer.cornerRadius = 10
        detectButton.backgroundColor = .white
        toggleDebugLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleDebugSwitch.translatesAutoresizingMaskIntoConstraints = false
        detectButton.translatesAutoresizingMaskIntoConstraints = false
        toolsView.contentView.addSubview(toggleDebugLabel)
        toolsView.contentView.addSubview(toggleDebugSwitch)
        toolsView.contentView.addSubview(detectButton)
                
        NSLayoutConstraint.activate([
            overlayView.centerXAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerYAnchor),
            overlayView.widthAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.widthAnchor),
            overlayView.heightAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.heightAnchor),
            
            toolsView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -25.0),
            toolsView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            toolsView.widthAnchor.constraint(equalTo: overlayView.widthAnchor),
            toolsView.heightAnchor.constraint(equalToConstant: 40.0),
            
            detectButton.centerXAnchor.constraint(equalTo: toolsView.contentView.centerXAnchor),
            detectButton.centerYAnchor.constraint(equalTo: toolsView.contentView.centerYAnchor),
            detectButton.heightAnchor.constraint(equalTo: toolsView.contentView.heightAnchor, multiplier: 0.75),
            detectButton.widthAnchor.constraint(equalTo: toolsView.contentView.widthAnchor, multiplier: 0.16),
            toggleDebugSwitch.trailingAnchor.constraint(equalTo: detectButton.leadingAnchor),
            toggleDebugSwitch.centerYAnchor.constraint(equalTo: detectButton.centerYAnchor),
            toggleDebugSwitch.heightAnchor.constraint(equalTo: detectButton.heightAnchor),
            toggleDebugSwitch.widthAnchor.constraint(equalTo: detectButton.widthAnchor, multiplier: 1.2),
            toggleDebugLabel.leftAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(toolsView.contentView.leftAnchor, multiplier: 1.2),
            toggleDebugLabel.centerYAnchor.constraint(equalTo: detectButton.centerYAnchor),
            toggleDebugLabel.heightAnchor.constraint(equalTo: detectButton.heightAnchor),
            toggleDebugLabel.widthAnchor.constraint(equalTo: detectButton.widthAnchor, multiplier: 1.2),
            
            toast.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 5.0),
            toast.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            toast.widthAnchor.constraint(equalToConstant: 200.0),
            toast.heightAnchor.constraint(equalToConstant: 30.0),
            
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        detectButton.addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
        toggleDebugSwitch.addTarget(self, action: #selector(handleDebugSwitch(sender:)), for: .touchUpInside)
        
        showToast("Tip: Shake to restart a session")
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            self.hideToast()
        }
    }
}
