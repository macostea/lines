//
//  Box.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation
import SpriteKit

enum BoxType: Int, Printable {
    case Unknown = 0,
    Red,
    Blue,
    Green,
    Yellow
    
    var spriteName: String {
        let spriteNames = [
            "RedBox",
            "BlueBox",
            "GreenBox",
            "YellowBox"
            ]
            
        return spriteNames[self.toRaw() - 1]
    }
    
    var spriteColor: UIColor {
        let spriteColors = [
            UIColor.linesRedColor(),
            UIColor.linesBlueColor(),
            UIColor.linesGreenColor(),
            UIColor.linesYellowColor()
            ]
            
        return spriteColors[self.toRaw() - 1]
    }
    
    static func random() -> BoxType {
        return BoxType.fromRaw(Int(arc4random_uniform(4)) + 1)!
    }
    
    // MARK: - Printable
    
    var description: String {
        return self.spriteName
    }
}

func ==(lhs: Box, rhs: Box) -> Bool {
    return lhs.coordinate == rhs.coordinate
}

class Box: Printable, Equatable, Hashable {
    var coordinate: Coordinate
    var boxType: BoxType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, boxType: BoxType) {
        self.coordinate.column = column
        self.coordinate.row = row
        self.boxType = boxType
    }
    
    class func random() -> Box {
        var column = Int(arc4random_uniform(UInt32(NumColumns)))
        var row = Int(arc4random_uniform(UInt32(NumRows)))
        
        return Box(column: column, row: row, boxType: BoxType.random())
    }
    
    // MARK: - Printable
    
    var description: String {
        return "type: \(self.boxType) square: (\(self.coordinate))"
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        return self.coordinate.row*10 + self.coordinate.column
    }
}