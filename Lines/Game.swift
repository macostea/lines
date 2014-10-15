//
//  Game.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

let NumColumns = 7
let NumRows = 7

protocol GameDelegate: NSObjectProtocol {
    func game(game: Game, didUpdateScore score: Int)
    func game(game: Game, didUpdateMultiplier multiplier: Int)
    func game(game: Game, didUpdateLevel level: Int)
    func gameDidFinish(game: Game)
}

class Game {
    weak var delegate: GameDelegate?
    
    private var board = Array2D<Box>(columns: NumColumns, rows: NumRows)
    private var boxes = Set<Box>()
    
    var score: Int = 0 {
        didSet {
            if let delegate = self.delegate {
                delegate.game(self, didUpdateScore: score)
            }
        }
    }
    
    var multiplier: Int = 1 {
        didSet {
            if let delegate = self.delegate {
                delegate.game(self, didUpdateMultiplier: multiplier)
            }
        }
    }
    
    var currentLevel: Int = 2 {
        didSet {
            if let delegate = self.delegate {
                delegate.game(self, didUpdateLevel: currentLevel)
            }
        }
    }
    
    init() {
        
    }
    
    func boxAt(coordinate: Coordinate) -> Box? {
        assert(coordinate.column >= 0 && coordinate.column < NumColumns)
        assert(coordinate.row >= 0 && coordinate.row < NumRows)
        
        return self.board[coordinate]
    }
    
    func createInitialBoxes() -> Set<Box> {
        return self.createBoxes(4)!
    }
    
    func createTutorialBoxes() -> Set<Box> {
        var boxes = Set<Box>()
        var l = Box(column: 0, row: 4, boxType: .Red)
        self.boxes.addElement(l)
        boxes.addElement(l)
        self.board[l.coordinate] = l
        
        l = Box(column: 0, row: 3, boxType: .Red)
        self.boxes.addElement(l)
        boxes.addElement(l)
        self.board[l.coordinate] = l
        
        l = Box(column: 0, row: 2, boxType: .Red)
        self.boxes.addElement(l)
        boxes.addElement(l)
        self.board[l.coordinate] = l
        
        l = Box(column: 1, row: 2, boxType: .Red)
        self.boxes.addElement(l)
        boxes.addElement(l)
        self.board[l.coordinate] = l
        
        var i = Box(column: 2, row: 4, boxType: .Blue)
        self.boxes.addElement(i)
        boxes.addElement(i)
        self.board[i.coordinate] = i
        
        i = Box(column: 2, row: 3, boxType: .Blue)
        self.boxes.addElement(i)
        boxes.addElement(i)
        self.board[i.coordinate] = i
        
        i = Box(column: 2, row: 2, boxType: .Blue)
        self.boxes.addElement(i)
        boxes.addElement(i)
        self.board[i.coordinate] = i
        
        var n = Box(column: 3, row: 4, boxType: .Green)
        self.boxes.addElement(n)
        boxes.addElement(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 3, row: 3, boxType: .Green)
        self.boxes.addElement(n)
        boxes.addElement(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 3, row: 2, boxType: .Green)
        self.boxes.addElement(n)
        boxes.addElement(n)
        self.board[n.coordinate] = n

        n = Box(column: 4, row: 4, boxType: .Green)
        self.boxes.addElement(n)
        boxes.addElement(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 4, row: 3, boxType: .Green)
        self.boxes.addElement(n)
        boxes.addElement(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 4, row: 2, boxType: .Green)
        self.boxes.addElement(n)
        boxes.addElement(n)
        self.board[n.coordinate] = n
        
        var e = Box(column: 6, row: 4, boxType: .Yellow)
        self.boxes.addElement(e)
        boxes.addElement(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 5, row: 4, boxType: .Yellow)
        self.boxes.addElement(e)
        boxes.addElement(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 5, row: 3, boxType: .Yellow)
        self.boxes.addElement(e)
        boxes.addElement(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 5, row: 2, boxType: .Yellow)
        self.boxes.addElement(e)
        boxes.addElement(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 6, row: 2, boxType: .Yellow)
        self.boxes.addElement(e)
        boxes.addElement(e)
        self.board[e.coordinate] = e
        
        return boxes
    }
    
    func createBoxes(numberOfBoxes: Int) -> Set<Box>? {
        if self.numberOfEmptyTiles() < numberOfBoxes {
            return nil
        }
        
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
            self.boxes.removeElement(move.box)
            move.box.coordinate = move.coordinate
            self.board[move.coordinate] = move.box
            self.boxes.addElement(move.box)
            
            if let chain = self.chainAtCoordinate(move.coordinate) {
                self.score += self.multiplier * chain.score
                if self.score >= 80 && self.currentLevel == 2 {
                    self.currentLevel++
                }
                if self.score >= 180 && self.currentLevel == 3 {
                    self.currentLevel++
                }
                self.multiplier++
                return (chain, foundMove)
            } else {
                self.multiplier = 1
            }
            
            return (nil, foundMove)
        }
        
        return (nil, nil)
    }
    
    func chainAtCoordinate(coordinate: Coordinate) -> Chain? {
        if let box = self.board[coordinate] {
            var chain = Chain(score: 0)
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
            
            chain = Chain(score: 0)
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
            
            // 1st diagonal
            chain = Chain(score: 0)
            chain.append(box)
            possibleChain = [Box]()
            var diagnoalLength = 1
            for var i = coordinate.row + 1, j = coordinate.column - 1; i < NumRows && j >= 0 && self.board[(j, i)]?.boxType == boxColor;
                ++i, --j, ++diagnoalLength {
                    possibleChain.append(self.board[(j, i)]!)
            }
            for var i = coordinate.row - 1, j = coordinate.column + 1; i >= 0 && j < NumColumns && self.board[(j, i)]?.boxType == boxColor;
                --i, ++j, ++diagnoalLength {
                    possibleChain.append(self.board[(j, i)]!)
            }
            if diagnoalLength >= 4 {
                chain.append(possibleChain)
                return chain
            }
            
            // 2nd diagonal
            chain = Chain(score: 0)
            chain.append(box)
            possibleChain = [Box]()
            diagnoalLength = 1
            for var i = coordinate.row - 1, j = coordinate.column - 1; i >= 0 && j >= 0 && self.board[(j, i)]?.boxType == boxColor;
                --i, --j, ++diagnoalLength {
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
    
    private func numberOfEmptyTiles() -> Int {
        return NumRows * NumColumns - self.boxes.count
    }
    
}