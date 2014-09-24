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
    let tileWidth: CGFloat = 52.0
    let tileHeight: CGFloat = 52.0
    
    let gameLayer = SKNode()
    let boxesLayer = SKNode()
    let tilesLayer = SKNode()
    let scoreSprite = SKLabelNode(text: "0 points")
    
    var selectedBox: Box?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.setup()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(self.boxesLayer)
        
        let (success, coordinate) = self.convertPoint(location)
        if success {
            if let box = self.game.boxAt(coordinate) {
                self.selectBox(box)
            } else {
                if let box = self.selectedBox {
                    self.moveBox(box, toCoordinate: coordinate)
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setup() {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(self.gameLayer)
        
        let layerPosition = CGPoint(x: -(self.tileWidth-2.0) * CGFloat(NumColumns) / 2, y: -(self.tileHeight-2.0) * CGFloat(NumRows) / 2)
        
        self.tilesLayer.position = layerPosition
        self.gameLayer.addChild(self.tilesLayer)
        
        self.boxesLayer.position = layerPosition
        self.gameLayer.addChild(self.boxesLayer)
        
        self.addScoreSprite()
    }
    
    func addScoreSprite() {
        self.scoreSprite.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        self.gameLayer.addChild(self.scoreSprite)
    }
    
    func addSpritesForBoxes(boxes: Set<Box>) {
        for box in boxes {
            let sprite = SKSpriteNode(color: box.boxType.spriteColor, size: CGSize(width: tileWidth-2.0, height: tileHeight-2.0))
            sprite.position = self.pointFor(box.coordinate)
            sprite.setScale(0.0000001)
            self.boxesLayer.addChild(sprite)
            box.sprite = sprite
            let grow = SKAction.scaleTo(1.0, duration: 0.2)
            grow.timingMode = .EaseOut
            sprite.runAction(grow)
        }
    }
    
    func removeSpritesForBoxes(boxes: Set<Box>) {
        for box in boxes {
            let shrink = SKAction.scaleTo(0.000001, duration: 0.2)
            shrink.timingMode = .EaseOut
            box.sprite?.runAction(shrink) {
                box.sprite?.removeFromParent()
                return
            }
        }
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                let tileNode = SKShapeNode(rectOfSize: CGSize(width: self.tileWidth, height: self.tileHeight))
                tileNode.position = self.pointFor(column: column, row: row)
                self.tilesLayer.addChild(tileNode)
            }
        }
    }
    
    func updateScore(score: Int) {
        self.scoreSprite.text = "\(score) points"
    }
    
    func selectBox(box: Box) {
        self.deselectBox(self.selectedBox)
        if (self.selectedBox != box) {
            self.selectedBox = box
            let action = SKAction.scaleBy(0.85, duration: 0.3)
            let revAction = action.reversedAction()
            let seq = SKAction.sequence([action, revAction])
            
            let finalAction = SKAction.repeatActionForever(seq)
            box.sprite?.runAction(finalAction, withKey: "selectedCellAction")
        } else {
            self.selectedBox = nil
        }
    }
    
    func deselectBox(box: Box?) {
        box?.sprite?.removeActionForKey("selectedCellAction")
        let defaultAction = SKAction.scaleTo(1.0, duration: 0.2)
        box?.sprite?.runAction(defaultAction, withKey: "defaultAction")
    }
    
    func moveBox(box: Box, toCoordinate coordinate: Coordinate) {
        self.deselectBox(self.selectedBox)
        self.selectedBox = nil
        
        let moveResult = self.game.performMove(Move(box: box, toCoordinate: coordinate))
        if let move = moveResult.move {
        
            var actions = [SKAction]()
            
            for coord in move.coordinateList! {
                let moveAction = SKAction.moveTo(self.pointFor(coord), duration: 0.1)
                actions.append(moveAction)
            }
            
            box.sprite?.runAction(SKAction.sequence(actions)) {
                if let chain = moveResult.chain {
                    // Remove chain if exists
                    self.removeSpritesForBoxes(chain.elements)
                    self.game.removeBoxes(chain.elements)
                } else {
                    // Add more boxes if a chain was not made
                    let newBoxes = self.game.createBoxes(2)
                    self.addSpritesForBoxes(newBoxes)
                }
            }
        } else {
            self.deselectBox(self.selectedBox)
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
