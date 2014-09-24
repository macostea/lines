//
//  Level.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

let NumColumns = 7
let NumRows = 7

class Level {
    private var board = Array2D<Box>(columns: NumColumns, rows: NumRows)
    private var boxes = Set<Box>()
    
    init() {
        
    }
    
    func boxAt(coordinate: Coordinate) -> Box? {
        assert(coordinate.column >= 0 && coordinate.column < NumColumns)
        assert(coordinate.row >= 0 && coordinate.row < NumRows)
        
        return self.board[coordinate]
    }
    
    func createInitialBoxes() -> Set<Box> {
        return self.createBoxes(4)
    }
    
    func createBoxes(numberOfBoxes: Int) -> Set<Box> {
        var boxes = Set<Box>()
        for i in 0..<numberOfBoxes{
            var box: Box
            do {
                box = Box.random()
            } while (self.boxes.containsElement(box))
            
            self.boxes.addElement(box)
            boxes.addElement(box)
            self.board[box.coordinate] = box
        }
        
        return boxes
    }
    
    func removeBoxes(boxes: Set<Box>) {
        for box in boxes {
            self.board[box.coordinate] = nil
            self.boxes.removeElement(box)
        }
    }
    
    func performMove(move: Move) -> (chain: Chain?, move: Move?) {
        let lookup = AStarLookup(source: move.box.coordinate, destination: move.coordinate, board: self.board)
        
        if let foundMove = lookup.findMove() {
            self.board[move.box.coordinate] = nil
            move.box.coordinate = move.coordinate
            self.board[move.coordinate] = move.box
            
            if let chain = self.chainAtCoordinate(move.coordinate) {
                return (chain, foundMove)
            }
            
            return (nil, foundMove)
        }
        
        return (nil, nil)
    }
    
    private func chainAtCoordinate(coordinate: Coordinate) -> Chain? {
        if let box = self.board[coordinate] {
            var chain = Chain()
            chain.append(box)
            let boxColor = self.board[coordinate]!.boxType
            
            var possibleChain = [Box]()
            var horzLength = 1
            for var i = coordinate.column - 1; i >= 0 && self.board[(i, coordinate.row)]?.boxType == boxColor;
                --i, ++horzLength {
                    possibleChain.append(self.board[(i, coordinate.row)]!)
            }
            for var i = coordinate.column + 1; i < NumColumns && self.board[(i, coordinate.row)]?.boxType == boxColor;
                ++i, ++horzLength {
                    possibleChain.append(self.board[(i, coordinate.row)]!)
            }
            if horzLength >= 4 {
                chain.append(possibleChain)
                return chain
            }
            
            chain = Chain()
            chain.append(box)
            possibleChain = [Box]()
            var vertLength = 1
            for var i = coordinate.row - 1; i >= 0 && self.board[(coordinate.column, i)]?.boxType == boxColor;
                --i, ++vertLength {
                    possibleChain.append(self.board[(coordinate.column, i)]!)
            }
            for var i = coordinate.row + 1; i < NumRows && self.board[(coordinate.column, i)]?.boxType == boxColor;
                ++i, ++vertLength {
                    possibleChain.append(self.board[(coordinate.column, i)]!)
            }
            if vertLength >= 4 {
                chain.append(possibleChain)
                return chain
            }
            
            chain = Chain()
            chain.append(box)
            possibleChain = [Box]()
            var diagnoalLength = 1
            for var i = coordinate.row + 1, j = coordinate.column - 1; i < NumRows && j >= 0 && self.board[(j, i)]?.boxType == boxColor;
                ++i, --j, ++diagnoalLength {
                    possibleChain.append(self.board[(j, i)]!)
            }
            for var i = coordinate.row + 1, j = coordinate.column + 1; i < NumRows && j < NumColumns && self.board[(j, i)]?.boxType == boxColor;
                ++i, ++j, ++diagnoalLength {
                    possibleChain.append(self.board[(j, i)]!)
            }
            if diagnoalLength >= 4 {
                chain.append(possibleChain)
                return chain
            }
            
            return nil
        }
        
        return nil
    }
    
}