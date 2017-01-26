//
//  GameScene.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 1/25/17.
//  Written by Mario Youssef, 
//  Copyright © 2017 Comp361. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // touch location
    var targetLocation: CGPoint = .zero
    
    // Scene Nodes
    var cam:SKCameraNode!
    var waterBackground:SKTileMapNode!
    var landBackground:SKTileMapNode!
    
    override func didMove(to view: SKView) {
        loadSceneNodes()
        
        cam = SKCameraNode()
        cam.xScale = 0.5
        cam.yScale = 0.5
        
        self.camera = cam
        self.addChild(cam)
        
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        let verticalConstraint = SKConstraint.positionY(SKRange(lowerLimit: waterBackground.frame.minY, upperLimit: waterBackground.frame.maxY))
        let horizontalConstraint = SKConstraint.positionX(SKRange(lowerLimit: waterBackground.frame.minX, upperLimit: waterBackground.frame.maxX))
        
        verticalConstraint.enabled = true
        horizontalConstraint.enabled = true
        verticalConstraint.referenceNode = waterBackground
        horizontalConstraint.referenceNode = waterBackground
        
        cam.constraints = [horizontalConstraint, verticalConstraint]
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanFrom(recognizer:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func loadSceneNodes() {
        guard let landBackground = childNode(withName: "LandBackground")
            as? SKTileMapNode else {
                fatalError("LandBackground node not loaded")
        }
        self.landBackground = landBackground
        
        guard let waterBackground = childNode(withName: "WaterBackground")
            as? SKTileMapNode else {
                fatalError("WaterBackground node not loaded")
        }
        self.waterBackground = waterBackground
    }
    
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .changed {
            return
        }
        
        // Get touch delta
        let translation = recognizer.translation(in: recognizer.view!)
        
        // Move camera
        cam.position.x -= translation.x
        cam.position.y += translation.y
        
        // Reset
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        targetLocation = touch.location(in: self)
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        targetLocation = touch.location(in: self)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        targetLocation = touch.location(in: self)
//    }
//    
    override func update(_ currentTime: TimeInterval) {
    }
    
}
