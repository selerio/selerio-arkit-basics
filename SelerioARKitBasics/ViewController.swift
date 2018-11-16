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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        // *** Integrate Selerio SDK ***
        
        // Create a smart session
        smartSession = ARSmartSession(apiKey: "", sceneView: sceneView)
        smartSession.delegate = self
        
        // Assign a delegate for processing frames from the arkit session
        frameHandler = ARSessionDelegateHandler(session: smartSession)
        sceneView.session.delegate = frameHandler
        
        // UI
        let handleSwipeLeftGestureRecon = UISwipeGestureRecognizer(target: self,
                                                                   action: #selector(userSwipeLeft))
        sceneView.addGestureRecognizer(handleSwipeLeftGestureRecon)
        let handleTapGestureRecon = UITapGestureRecognizer(target: self,
                                                           action: #selector(userTappedScreen))
        sceneView.addGestureRecognizer(handleTapGestureRecon)
        smartSession.addDebugMesh()
        
        // Enable automatic object recognition
        smartSession.run()
        smartSession.autodetect = true
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
                    
                    // Uncomment to stop autodetect (can improve battery life)
                    // smartSession.autodetect = false
                }
            }
        }
        return node
    }
    
    func addVirtualObjectAt(geometry: SCNGeometry, position: SCNVector3) {
        // Node that the geometry is applied to
        let node = SCNNode.init(geometry: geometry)
        node.position = position
        
        // Add the node to the scene. Use cubes with physics
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody = physicsBody
        physicsBody.isAffectedByGravity = true
        physicsBody.mass = 0.5
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    @objc func userTappedScreen(_ sender: UITapGestureRecognizer) {
        // Get the 2D point of the touch in the SceneView
        let tapPoint: CGPoint = sender.location(in: self.sceneView)
        
        // Conduct the hit test on the SceneView
        let hitTestResults: [ARHitTestResult] = sceneView.hitTest(tapPoint,
                                                                  types: [.existingPlaneUsingExtent, .featurePoint])
        
        if hitTestResults.isEmpty {
            return
        }
        
        // Arbitrarily pick the closest plane in the case of multiple results
        let result: ARHitTestResult = hitTestResults[0]
        
        // The position of the ARHitTestResult relative to the world coordinate system
        // The 3rd column in the matrix corresponds the the position of the point in the coordinate system
        let resultPositionMatrixColumn = result.worldTransform.columns.3
        
        // Position the node slightly above the hit test's position in order to show off gravity later
        let targetPosition: SCNVector3 = SCNVector3Make(
            resultPositionMatrixColumn.x, resultPositionMatrixColumn.y + /* insertion offset */ 0.8,
            resultPositionMatrixColumn.z)
        
        //Create ball
        let sphere = SCNSphere(radius: 0.08)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/TennisBallColorMap.jpg")
        
        addVirtualObjectAt(geometry: sphere, position: targetPosition)
    }
    
    @objc func userSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        self.smartSession.toggleDebugMode()
    }
    
    
}

// MARK: - Asset Utilities

func createSCNNodeFromTextureURL(url: URL, handler: @escaping (SCNNode?) -> Void) {
    let plane = SCNPlane(width: 1.0, height: 1.0)
    plane.widthSegmentCount = 100
    plane.heightSegmentCount = 100
    let node = SCNNode(geometry: plane)
    node.name = url.lastPathComponent
    node.geometry?.firstMaterial?.isDoubleSided = true
    
    let ext = url.pathExtension
    if ext == "gif" {
        let aspectRatio = 1.0
        let overlay = SKScene(size: CGSize(width: 1000, height: 1000*aspectRatio))
        overlay.backgroundColor = UIColor.clear
        overlay.scaleMode = .aspectFill
        let sknode = SKSpriteNode(color: UIColor.clear, size: overlay.frame.size)
        sknode.position = CGPoint(x: overlay.frame.width/2, y: overlay.frame.height/2)
        overlay.addChild(sknode)
        
        plane.firstMaterial?.diffuse.contents = overlay
        plane.height = plane.height*(CGFloat(aspectRatio))
        handler(node)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            let animation = createGIFAnimationFromData(data: data)
            let textures = animation?.values?.compactMap({ (cgimage) -> SKTexture? in
                return SKTexture(cgImage: cgimage as! CGImage)
            })
            sknode.yScale *= -1*((textures?.first?.size().height)!/(textures?.first?.size().width)!)
            let action = SKAction.animate(with: textures!, timePerFrame: (animation?.duration)!/TimeInterval((animation?.values?.count)!))
            sknode.run(SKAction.repeatForever(action))
        }
        task.resume()
        
        
        
    } else if (["jpg", "jpeg", "png", "tga", "tiff", "gif"].contains(ext)) {
        plane.firstMaterial?.diffuse.contents = url
        handler(node)
    } else if (AVURLAsset.isPlayableExtendedMIMEType("video/"+ext) || AVURLAsset.isPlayableExtendedMIMEType("audio/"+ext)) {
        let player = AVPlayer(url: url)
        player.play()
        plane.firstMaterial?.diffuse.contents = player
        handler(node)
    }
}

func createGIFAnimationFromData(data: Data?) -> CAKeyframeAnimation? {
    guard let source = CGImageSourceCreateWithData(data! as CFData, nil) else {
        print("Source for the GIF image does not exist")
        return nil
    }
    let count = CGImageSourceGetCount(source)
    var images = [CGImage]()
    var delays = [Float]()
    var time = Float(0.0)
    for i in 0..<count {
        if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
            images.append(image)
        }
        // Frame duration
        var frameDuration = Float(0.0)
        let frameProperties = CGImageSourceCopyPropertiesAtIndex (source,i,nil) as? [NSString: Any]
        let gifProperties = frameProperties?[kCGImagePropertyGIFDictionary] as? [NSString: Any]
        if let delayTimeUnclampedProp = gifProperties![kCGImagePropertyGIFUnclampedDelayTime] as! NSNumber? {
            frameDuration = delayTimeUnclampedProp.floatValue
        } else {
            if let delayTimeProp = gifProperties![kCGImagePropertyGIFDelayTime] as! NSNumber? {
                frameDuration = delayTimeProp.floatValue
            }
        }
        if (frameDuration < 0.011) { frameDuration = 0.100 }
        delays.append(Float(frameDuration)) // seconds
        time = time + frameDuration
    }
    var relativeTimes = [NSNumber]()
    var base = Float(0)
    for duration in delays {
        base = base + (duration/time);
        relativeTimes.append(NSNumber(value: base))
    }
    let animation = CAKeyframeAnimation(keyPath: "contents")
    animation.duration = CFTimeInterval(time)
    animation.repeatCount = Float.infinity
    animation.isRemovedOnCompletion = false
    animation.fillMode = kCAFillModeForwards
    animation.values = images
    animation.keyTimes = relativeTimes
    animation.timingFunction = CAMediaTimingFunction(name: "linear")
    animation.calculationMode = kCAAnimationDiscrete
    // let layer = CALayer()
    // layer.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000*aspectRatio)
    // layer.backgroundColor = UIColor.green.cgColor
    // layer.add(animation!, forKey: "contents")
    return animation
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
    
    func setupToast() {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.clear
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(overlayView)
        
        toast.effect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        toast.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(toast)
        toast.layer.cornerRadius = 5
        toast.clipsToBounds = true
        
        let contentView = toast.contentView
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            overlayView.centerXAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerYAnchor),
            overlayView.widthAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.widthAnchor),
            overlayView.heightAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.heightAnchor),
            toast.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 5.0),
            toast.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            toast.widthAnchor.constraint(equalToConstant: 240.0),
            toast.heightAnchor.constraint(equalToConstant: 60.0),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
    }
}
