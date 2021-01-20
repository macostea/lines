//
//  File.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

func ==(lhs: Step, rhs: Step) -> Bool {
    return lhs.position == rhs.position
}

class Step: Equatable {
    var position: Coordinate
    var gScore: Int
    var hScore: Int
    var parent: Step?
    
    init(position: Coordinate) {
        self.position = position
        self.gScore = 0
        self.hScore = 0
        self.parent = nil
    }
    
    func fScore() -> Int {
        return self.gScore + self.hScore
    }
    
    // MARK: - Printable
    
    var description: String {
        return "\(self.position)"
    }
    
    // MARK: - Equatable
    
    var hashValue: Int {
        return self.position.row*10 + self.position.column
    }
}
