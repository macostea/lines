//
//  GameScene.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var game: Game!
    let tileWidth: CGFloat = 45.0
    let tileHeight: CGFloat = 45.0
    
    let gameLayer = SKNode()
    let boxesLayer = SKNode()
    let tilesLayer = SKNode()
    let scoreSprite = SKLabelNode(text: "0 points")
    
    var currentScore = 0
    
    var selectedBox: Box?
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        self.setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        let touch = touches.first!
        let location = touch.location(in: self.boxesLayer)
        
        let (success, coordinate) = self.convertPoint(point: location)
        if success {
            if let box = self.game.boxAt(coordinate: coordinate) {
                self.selectBox(box: box)
            } else {
                if let box = self.selectedBox {
                    self.moveBox(box: box, toCoordinate: coordinate)
                }
            }
        }
    }
   
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setup() {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(self.gameLayer)
        
        let layerPosition = CGPoint(x: -(self.tileWidth) * CGFloat(NumColumns) / 2, y: -(self.tileHeight) * CGFloat(NumRows) / 2)
        
        self.tilesLayer.position = layerPosition
        self.gameLayer.addChild(self.tilesLayer)
        
        self.boxesLayer.position = layerPosition
        self.gameLayer.addChild(self.boxesLayer)
        
        self.addScoreSprite()
    }
    
    func addScoreSprite() {
        self.scoreSprite.position = CGPoint(x: self.frame.midX - 80.0, y: self.tileHeight * CGFloat(NumRows) / 2 + 20.0)
        self.scoreSprite.fontColor = UIColor.linesOrangeColor()
        
        self.gameLayer.addChild(self.scoreSprite)
    }
    
    func addSpritesForBoxes(boxes: Set<Box>) {
        for box in boxes {
            let sprite = SKSpriteNode(color: box.boxType.spriteColor, size: CGSize(width: tileWidth-2.0, height: tileHeight-2.0))
            sprite.position = self.pointFor(coordinate: box.coordinate)
            sprite.setScale(0.0000001)
            self.boxesLayer.addChild(sprite)
            box.sprite = sprite
            let grow = SKAction.scale(to: 1.0, duration: 0.2)
            grow.timingMode = .easeOut
            sprite.run(grow)
        }
    }
    
    func removeSpritesForBoxes(boxes: Set<Box>) {
        for box in boxes {
            let shrink = SKAction.scale(to: 0.000001, duration: 0.2)
            shrink.timingMode = .easeOut
            box.sprite?.run(shrink) {
                box.sprite?.removeFromParent()
                return
            }
        }
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                let tileNode = SKShapeNode(rectOf: CGSize(width: self.tileWidth, height: self.tileHeight))
                tileNode.strokeColor = UIColor.linesGrayColor()
                tileNode.position = self.pointFor(coordinate: Coordinate(column: column, row: row))
                self.tilesLayer.addChild(tileNode)
            }
        }
    }
    
    func updateScore(score: Int) {
        self.currentScore = score
    }
    
    func selectBox(box: Box) {
        self.deselectBox(box: self.selectedBox)
        if (self.selectedBox != box) {
            self.selectedBox = box
            let action = SKAction.scale(by: 0.85, duration: 0.3)
            let revAction = action.reversed()
            let seq = SKAction.sequence([action, revAction])
            
            let finalAction = SKAction.repeatForever(seq)
            box.sprite?.run(finalAction, withKey: "selectedCellAction")
        } else {
            self.selectedBox = nil
        }
    }
    
    func deselectBox(box: Box?) {
        box?.sprite?.removeAction(forKey: "selectedCellAction")
        let defaultAction = SKAction.scale(to: 1.0, duration: 0.2)
        box?.sprite?.run(defaultAction, withKey: "defaultAction")
    }
    
    func moveBox(box: Box, toCoordinate coordinate: Coordinate) {
        self.deselectBox(box: self.selectedBox)
        self.selectedBox = nil
        
        let moveResult = self.game.performMove(move: Move(box: box, toCoordinate: coordinate))
        if let move = moveResult.move {
        
            var actions = [SKAction]()
            
            for coord in move.coordinateList! {
                let moveAction = SKAction.move(to: self.pointFor(coordinate: coord), duration: 0.1)
                actions.append(moveAction)
            }
            
            box.sprite?.run(SKAction.sequence(actions)) {
                if let chain = moveResult.chain {
                    // Remove chain if exists
                    self.removeSpritesForBoxes(boxes: chain.elements)
                    self.game.removeBoxes(boxes: chain.elements)
                    
                    self.scoreSprite.text = "\(self.currentScore) points"
                } else {
                    // Add more boxes if a chain was not made
                    if let newBoxes = self.game.createBoxes(numberOfBoxes: self.game.currentLevel) {
                        self.addSpritesForBoxes(boxes: newBoxes)
                        
                        for newBox in newBoxes {
                            if let chain = self.game.chainAtCoordinate(coordinate: newBox.coordinate) {
                                self.removeSpritesForBoxes(boxes: chain.elements)
                                self.game.removeBoxes(boxes: chain.elements)
                            }
                        }
                    } else {
                        self.game.delegate?.gameDidFinish(game: self.game)
                    }
                }
            }
        } else {
            self.deselectBox(box: self.selectedBox)
            self.selectedBox = nil
        }
    }
    
    func pointFor(coordinate: Coordinate) -> CGPoint {
        return CGPoint(x: CGFloat(coordinate.column) * self.tileWidth + self.tileWidth/2, y: CGFloat(coordinate.row) * self.tileHeight + self.tileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, coordinate: Coordinate) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*self.tileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*self.tileHeight {
                return (true, (Int(point.x / self.tileWidth), Int(point.y / self.tileHeight)))
        } else {
            return (false, (0, 0))  // invalid location
        }
    }
    
}
