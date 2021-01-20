//
//  Move.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.box == rhs.box && lhs.coordinate == rhs.coordinate
}

struct Move: Hashable {
    let box: Box
    let coordinate: Coordinate
    
    var coordinateList: [Coordinate]?
    
    init(box: Box, toCoordinate coordinate: Coordinate) {
        self.box = box
        self.coordinate = coordinate
    }
    
    // MARK: Printable
    
    var description: String {
        return "Move: \(self.box) to \(self.coordinate)"
    }
    
    // MARK: Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.box)
    }
}
