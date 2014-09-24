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
    
    mutating func append(box: Box) {
        self.boxes.addElement(box)
    }
    
    mutating func append(boxes: [Box]) {
        for box in boxes {
            self.boxes.addElement(box)
        }
    }
    
    var elements: Set<Box> {
        return self.boxes
    }
}