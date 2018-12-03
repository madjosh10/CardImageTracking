//
//  ViewController.swift
//  CardImageTracking
//
//  Created by Joshua Madrigal on 11/29/18.
//  Copyright © 2018 joshuamadrigal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var heartNode: SCNNode?
    var diamondNode: SCNNode?
    var cloverNode: SCNNode?
    var spadeNode: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let heartScene = SCNScene(named: "art.scnassets/heart.scn")
        let spadeScene = SCNScene(named: "art.scnassets/spade.scn")
        let cloverScene = SCNScene(named: "art.scnassets/clover.scn")
        let diamondScene = SCNScene(named: "art.scnassets/diamond.scn")
        
        heartNode = heartScene?.rootNode
        spadeNode = spadeScene?.rootNode
        cloverNode = cloverScene?.rootNode
        diamondNode = diamondScene?.rootNode
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "PlayingCards", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 4
        }
        
        
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            
            node.addChildNode(planeNode)
            
            if let shapeNode = heartNode {
                node.addChildNode(shapeNode)
            }
            
            
            
        }
        
        return node
        
    }

 
} // end ViewController
