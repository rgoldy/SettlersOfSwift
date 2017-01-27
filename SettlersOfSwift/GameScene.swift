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
    //var targetLocation: CGPoint = .zero
    
    //init scene nodes
    var cam:SKCameraNode!
    var waterBackground:SKTileMapNode!
    var landBackground:SKTileMapNode!
    var terrainTiles:SKTileSet!
    let NumRows = 9
    
    //init initial tile values
    var tileValues : Dictionary<String, Int> = [:]
    
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
        
        let verticalConstraint = SKConstraint.positionY(SKRange(lowerLimit: waterBackground.frame.minY, upperLimit: waterBackground.frame.maxY))
        let horizontalConstraint = SKConstraint.positionX(SKRange(lowerLimit: waterBackground.frame.minX, upperLimit: waterBackground.frame.maxX))
        
        verticalConstraint.enabled = true
        horizontalConstraint.enabled = true
        verticalConstraint.referenceNode = waterBackground
        horizontalConstraint.referenceNode = waterBackground
        
        cam.constraints = [horizontalConstraint, verticalConstraint]
        
        //init gesture recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanFrom(recognizer:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(recognizer:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        //physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func loadSceneNodes() {
        //load landBackground tiles
        guard let landBackground = childNode(withName: "LandBackground")
            as? SKTileMapNode else {
                fatalError("LandBackground node not loaded")
        }
        self.landBackground = landBackground
        
        //load terrainTiles tile set
        guard let terrainTiles = SKTileSet(named: "Terrain Tiles") else {
            fatalError("terrainTiles node not loaded")
        }
        self.terrainTiles = terrainTiles
        
        //load waterBackground tiles
        guard let waterBackground = childNode(withName: "WaterBackground")
            as? SKTileMapNode else {
                fatalError("WaterBackground node not loaded")
        }
        self.waterBackground = waterBackground
        
        initTiles(filename: "3player")
    }
    
    //function to read layout from json files and place correct amount of tiles
    func initTiles(filename: String) {
        
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }

        //fill tileValue dictionary
        tileValues = Dictionary<String, Int>()
        tileValues["brick"] = (dictionary["brick"] as? Int)!
        tileValues["wheat"] = (dictionary["wheat"] as? Int)!
        tileValues["wood"] = (dictionary["wood"] as? Int)!
        tileValues["sheep"] = (dictionary["sheep"] as? Int)!
        tileValues["stone"] = (dictionary["stone"] as? Int)!
        tileValues["gold"] = (dictionary["gold"] as? Int)!
        
        //get tile layout
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        
        //place tiles
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    let currTile = getValidTileGroup()
                    landBackground.setTileGroup(currTile, forColumn: column, row: tileRow)
                }
            }
        }
    }
    
    //get a valid tile to put in game
    func getValidTileGroup() -> SKTileGroup {
        var random:Int
        var name:String
        
        //keep randomizing if all tiles of one type already used up
        repeat {
            random = Int(arc4random_uniform(6)) + 1
            name = terrainTiles.tileGroups[random].name!
        } while (tileValues[name] == 0)
        
        //get tile and decrement value by 1
        let tile = terrainTiles.tileGroups[random]
        tileValues[name] = tileValues[name]!-1
        
        return tile
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
