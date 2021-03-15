//
//  SCNNode+Aritmetic.swift
//  SpotTheScientist
//
//  Created by Cody Morley on 3/15/21.
//

import Foundation
import SceneKit

extension SCNNode {
    var width: Float {
        (boundingBox.max.x - boundingBox.min.x) * scale.x
    }
    
    var height: Float {
        (boundingBox.max.y - boundingBox.min.y) * scale.y
    }
    
    func pivotOnTopLeft() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x,
                                          (max.y - min.y) + min.y,
                                          0)
    }
    
    func pivotOnTopCenter() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2,
                                          (max.y - min.y) + min.y,
                                          0)
    }
}
