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

enum GamePhase {
    case Setup
    case p1Turn
    case p2Turn
    case p3Turn
}

class GameScene: SKScene {
    
    //init scene nodes
    var cam:SKCameraNode!
    var currGamePhase = GamePhase.Setup
    let dice = Dice()
    
    //init tile handler
    var handler : tileHandler!
    
    override func didMove(to view: SKView) {
        //load tiles
        loadSceneNodes()
        
        //init cam
        cam = SKCameraNode()
        cam.xScale = 0.9
        cam.yScale = 0.9
        
        self.camera = cam
        self.addChild(cam)
        
        cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        let verticalConstraint = SKConstraint.positionY(SKRange(lowerLimit: handler.waterBackground.frame.minY, upperLimit: handler.waterBackground.frame.maxY))
        let horizontalConstraint = SKConstraint.positionX(SKRange(lowerLimit: handler.waterBackground.frame.minX, upperLimit: handler.waterBackground.frame.maxX))
        
        verticalConstraint.enabled = true
        horizontalConstraint.enabled = true
        verticalConstraint.referenceNode = handler.waterBackground
        horizontalConstraint.referenceNode = handler.waterBackground
        
        cam.constraints = [horizontalConstraint, verticalConstraint]
        
        //init gesture recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanFrom(recognizer:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(recognizer:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func loadSceneNodes() {
        //load landBackground tiles
        guard let landBackground = childNode(withName: "LandBackground")
            as? SKTileMapNode else {
                fatalError("LandBackground node not loaded")
        }
        
        //load terrainTiles tile set
        guard let terrainTiles = SKTileSet(named: "Terrain Tiles") else {
            fatalError("terrainTiles node not loaded")
        }
        
        //load waterBackground tiles
        guard let waterBackground = childNode(withName: "WaterBackground")
            as? SKTileMapNode else {
                fatalError("WaterBackground node not loaded")
        }
        
        //load Numbers tiles
        guard let Numbers = childNode(withName: "Numbers")
            as? SKTileMapNode else {
                fatalError("Numbers node not loaded")
        }
        
        //load terrainTiles tile set
        guard let numberTiles = SKTileSet(named: "Number Values") else {
            fatalError("numberTiles node not loaded")
        }
        
        //load Vertices tiles
        guard let Vertices = childNode(withName: "Vertices")
            as? SKTileMapNode else {
                fatalError("Vertices node not loaded")
        }
        
        //load terrainTiles tile set
        guard let verticesTiles = SKTileSet(named: "Vertices") else {
            fatalError("Vertices tile set node not loaded")
        }
        
        //load Edges tiles
        guard let Edges = childNode(withName: "Edges")
            as? SKTileMapNode else {
                fatalError("Edges node not loaded")
        }
        
        //load terrainTiles tile set
        guard let edgesTiles = SKTileSet(named: "Edges") else {
            fatalError("Edges tile set node not loaded")
        }
        
        //init handler
        handler = tileHandler(waterBackground : waterBackground, landBackground: landBackground, Numbers : Numbers, Vertices : Vertices, terrainTiles : terrainTiles, numberTiles : numberTiles, verticesTiles : verticesTiles, Edges : Edges, edgesTiles : edgesTiles);
        
        //init tiles
        handler.initTiles(filename: "3player")
    }
    
    //function to handle pan gestures for camera movement
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .changed {
            return
        }
        
        //get translation amount
        let translation = recognizer.translation(in: recognizer.view!)
        
        //move cam
        cam.position.x -= translation.x
        cam.position.y += translation.y
        
        //reset tranlation
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    //function to handle pinch gestures for camera scaling
    func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if recognizer.state != .changed {
            return
        }
        
        //scale cam
        cam.xScale *= 1/recognizer.scale
        cam.yScale *= 1/recognizer.scale
        
        //clamp cam
        if (cam.xScale > 0.9) {cam.xScale = 0.9}
        if (cam.xScale < 0.35) {cam.xScale = 0.35}
        if (cam.yScale > 0.9) {cam.yScale = 0.9}
        if (cam.yScale < 0.35) {cam.yScale = 0.35}
        
        //reset scale
        recognizer.scale = 1
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let targetLocation = touch.location(in: self)
//        
//        let centerVertexCol = handler.Edges.tileColumnIndex(fromPosition: targetLocation)
//        let centerVertexRow = handler.Edges.tileRowIndex(fromPosition: targetLocation)
//        handler.Edges.setTileGroup(handler.edgesTiles.tileGroups[0], forColumn: centerVertexCol, row: centerVertexRow)
//
//    }
//    
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
//    override func update(_ currentTime: TimeInterval) {
//    }    
}
