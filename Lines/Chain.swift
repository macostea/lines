//
//  Chain.swift
//  Lines
//
//  Created by Mihai Costea on 24/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

struct Chain {
    private var boxes: Set<Box> = Set<Box>()
    
    var score: Int
    
    init(score: Int) {
        self.score = score
    }
    
    mutating func append(box: Box) {
        self.boxes.addElement(box)
        self.score++
    }
    
    mutating func append(boxes: [Box]) {
        for box in boxes {
            self.boxes.addElement(box)
            self.score++
        }
    }
    
    var elements: Set<Box> {
        return self.boxes
    }
}