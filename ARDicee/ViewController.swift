//
//  ViewController.swift
//  ARDicee
//
//  Created by Martin Dn on 20/6/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let material = SCNMaterial()
//
//        material.diffuse.contents = UIImage(named: "art.scnassets/ship.scn")//UIColor.red
//
//        cube.materials = [material]
//
//        let node = SCNNode() // un punto en el espacio donde pondremos nuestro elemento
//
//        node.position = SCNVector3(0, 0.1, -0.5)
//
//        node.geometry = cube
//
//
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        


    }
    func rollAll(){
        for dice in diceArray{
            
            let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi)/2
            
            let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi)/2
            
            
            dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 1))
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDices(_ sender: UIBarButtonItem) {
        for dice in diceArray{
            dice.removeFromParentNode()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            
            //let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any) else {return}
            
            let results = sceneView.session.raycast(query)
            
            if let hitResult = results.first {
                // Create a new scene
                let Dicescene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = Dicescene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    //diceNode.position = SCNVector3(0, 0, -0.1)
                    diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                                   hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                                   hitResult.worldTransform.columns.3.z)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    diceArray.append(diceNode)
                    

                }
                
                
            }else {
                print("no surface found")
                return
            }
            
        }
    }
    
    
    
    
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
//            let material = SCNMaterial()
//            viewController.view.isOpaque = false
//            material.diffuse.contents = viewController.view
//            planeNode.materials = [material]
            
          
            
                        
            planeNode.geometry = plane
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            node.addChildNode(planeNode)
            
        }
    }

}
