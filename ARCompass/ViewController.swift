//
//  ViewController.swift
//  testLazyAnimation
//
//  Created by Geng Wang on 12/28/18.
//  Copyright © 2018 Geng Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var animations = [String: CAAnimation]()
    var isOpening = false
    
    fileprivate func setupScene() {
        
        guard let dataURL = Bundle.main.url(forResource: "compass", withExtension: "dae", subdirectory: "art.scnassets/compass") else { return }
        guard let data = SCNSceneSource(url: dataURL, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay]),
            let compassNode = data.entryWithIdentifier("Dice", withClass: SCNNode.self),
        let lightNode = data.entryWithIdentifier("Light", withClass: SCNNode.self)
        else { return }
        
        sceneView.scene.rootNode.addChildNode(lightNode)
        sceneView.scene.rootNode.addChildNode(compassNode)
        
        // Load animations
        if let animationObj = data.entryWithIdentifier("open_cover", withClass: CAAnimation.self) {
            animationObj.fillMode = .forwards
            animationObj.isRemovedOnCompletion = false
            animations["open"] = animationObj
        }
        
        // Placement animation
        let delay = SCNAction.wait(duration: 1)
        let rotation = SCNAction.rotateBy(x: 0, y: 180 * .pi/180, z: 0, duration: 1)
        let moveIn = SCNAction.move(to: SCNVector3(0, -0.1, -0.2), duration: 1)
        let inAction = SCNAction.group([rotation, moveIn])
        compassNode.runAction(SCNAction.sequence([delay, inAction]))

    }
    private func setupGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(recognizer:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    // TODO: to get animation events, use SCNAnimation and maybe also SCNAnimationPlayer
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        guard let openAnimation = animations["open"] else { return }
        if (!isOpening) {
            sceneView.scene.rootNode.removeAnimation(forKey: "close")
            animations["open"]?.speed = 1
            sceneView.scene.rootNode.addAnimation(openAnimation, forKey: "open")
            isOpening = true
        } else {
            sceneView.scene.rootNode.removeAnimation(forKey: "open")
            animations["open"]?.speed = -1
            sceneView.scene.rootNode.addAnimation(openAnimation, forKey: "close")
            isOpening = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        setupScene()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
