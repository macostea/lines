//
//  Coordinate.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

typealias Coordinate = (column: Int, row: Int)

func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}