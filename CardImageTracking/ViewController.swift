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
    var imageNodes = [SCNNode]()
    var isJumping = false
    
    
    
    
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
            
            var shapeNode : SCNNode?
            switch imageAnchor.referenceImage.name {
                case CardType.KingOfClover.rawValue :
                    shapeNode = cloverNode
                case CardType.KingOfHears.rawValue :
                    shapeNode = heartNode
                case CardType.KingOfSpades.rawValue :
                    shapeNode = spadeNode
                case CardType.KingOfDiamonds.rawValue :
                    shapeNode = diamondNode
                default:
                    break
            }
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            
            guard let shape = shapeNode else { return nil }
            node.addChildNode(shape)
            imageNodes.append(node)
            
            return node
 
            
        }
        
        return nil
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2 {
            let positionOne = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNodes[1].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            if distance < 0.10 {
                spinJump(node: imageNodes[0])
                spinJump(node: imageNodes[1])
                isJumping = true
                
            } else {
                isJumping = false
            }
            
        }
    }
    
    func spinJump(node: SCNNode) {
        if isJumping { return }
        
        let shapeNode = node.childNodes[1]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        
        let down = up.reversed()
        let upDown = SCNAction.sequence([up, down])
        
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
        
    }
    

    enum CardType: String {
        case KingOfDiamonds = "KingOfDiamonds"
        case KingOfSpades = "KingOfSpades"
        case KingOfClover = "KingOfClover"
        case KingOfHears = "KingOfHearts"
    }
 
} // end ViewController
