//
//  Array2D.swift
//  aGame
//
//  Created by Mihai Costea on 20/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

struct Array2D<T> {
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
    subscript(coordinate: Coordinate) -> T? {
        get {
            return array[coordinate.row * self.columns + coordinate.column]
        }
        
        set {
            array[coordinate.row * self.columns + coordinate.column] = newValue
        }
    }
}