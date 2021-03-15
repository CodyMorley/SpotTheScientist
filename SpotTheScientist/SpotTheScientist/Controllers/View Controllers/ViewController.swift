//
//  ViewController.swift
//  SpotTheScientist
//
//  Created by Cody Morley on 3/15/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    // MARK: - Properties -
    /// IB Outlets
    @IBOutlet var sceneView: ARSCNView!
    /// properties
    var scientists = [String: Scientist]()
    
    
    //MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "scientists", bundle: nil) else {
            fatalError("Couldn't load tracking images.")
        }
        configuration.trackingImages = trackingImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - Methods -
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard
            let imageAnchor = anchor as? ARImageAnchor,
            let name = imageAnchor.referenceImage.name,
            let scientist = scientists[name] else {
            return nil
        }
        
        NSLog("Found \(scientist.name).")
        print(scientist.name)
        print(scientist.bio)
        
        // Create plane
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Set plane inside a node
        let planeNode = SCNNode(geometry: plane)
        
        // Set plane node inside a second node to get correct rotation in 3D space
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        return node
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "scientists", withExtension: "json") else {
            fatalError("Unable to find JSON resource in Bundle.main")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON resources.")
        }
        guard let loadedScientists = try? JSONDecoder().decode([String: Scientist].self, from: data) else {
            fatalError("Unable to parse JSON resources.")
        }
        
        scientists = loadedScientists
        NSLog("Scientist data loaded successfully from JSON.")
    }
}
