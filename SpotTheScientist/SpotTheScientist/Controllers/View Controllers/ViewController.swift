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
        
        // Create plane
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        // Set plane inside a node
        let planeNode = SCNNode(geometry: plane)
        // Set plane node inside a second node to get correct rotation in 3D space
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        let spacing: Float = 0.005
        
        let titleNode = textNode(scientist.name,
                                 font: UIFont.boldSystemFont(ofSize: 10))
        titleNode.pivotOnTopLeft()
        titleNode.position.x += Float(plane.width / 2) + spacing
        titleNode.position.y += Float(plane.height / 2)
        planeNode.addChildNode(titleNode)
        
        let bioNode = textNode(scientist.bio,
                               font: UIFont.systemFont(ofSize: 4),
                               maxWidth: 100)
        bioNode.pivotOnTopLeft()
        bioNode.position.x += Float(plane.width / 2) + spacing
        bioNode.position.y = titleNode.position.y - titleNode.height - spacing
        planeNode.addChildNode(bioNode)
        
        let flag = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                            height: imageAnchor.referenceImage.physicalSize.width / 8 * 5)
        flag.firstMaterial?.diffuse.contents = UIImage(named: scientist.country)
        
        let flagNode = SCNNode(geometry: flag)
        flagNode.pivotOnTopCenter()
        flagNode.position.y -= Float(plane.height / 2) + spacing
        planeNode.addChildNode(flagNode)
        
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
    
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0.0)
        text.flatness = 0.01
        text.font = font
        
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero,
                                         size: CGSize(width: maxWidth,
                                                      height: 500))
            text.isWrapped = true
        }
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.02, 0.02, 0.02)
        
        return textNode
    }
}
