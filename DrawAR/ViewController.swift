//
//  ViewController.swift
//  DrawAR
//
//  Created by Jason Yu on 7/22/19.
//  Copyright © 2019 Jason Yu. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var doodle: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let config = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(config)
        self.sceneView.showsStatistics = true
        sceneView.delegate = self
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)   //m31 = in the matrix in the 3rd column of row 1
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera = orientation + location
        
        //We need this to happen on the main thread
        DispatchQueue.main.async {
            if self.doodle.isHighlighted{
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = frontOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
            }else{
                //to let the user know where they are drawing
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = frontOfCamera
                
                //delete pointers before the drawing, enum loops through the nodes
                self.sceneView.scene.rootNode.enumerateChildNodes({(node, _) in
                    if node.name == "pointer"{
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
            }
        }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
