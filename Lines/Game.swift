//
//  Game.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation
import GameplayKit

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
    private var graph = GKGridGraph(fromGridStartingAt: vector_int2(0,0), width: Int32(NumColumns), height: Int32(NumRows), diagonalsAllowed: false)
    
    var score: Int = 0 {
        didSet {
            if let delegate = self.delegate {
                delegate.game(game: self, didUpdateScore: score)
            }
        }
    }
    
    var multiplier: Int = 1 {
        didSet {
            if let delegate = self.delegate {
                delegate.game(game: self, didUpdateMultiplier: multiplier)
            }
        }
    }
    
    var currentLevel: Int = 2 {
        didSet {
            if let delegate = self.delegate {
                delegate.game(game: self, didUpdateLevel: currentLevel)
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
        return self.createBoxes(numberOfBoxes: 4)!
    }
    
    func createTutorialBoxes() -> Set<Box> {
        var boxes = Set<Box>()
        var l = Box(column: 0, row: 4, boxType: .Red)
        self.boxes.insert(l)
        boxes.insert(l)
        self.board[l.coordinate] = l
        
        l = Box(column: 0, row: 3, boxType: .Red)
        self.boxes.insert(l)
        boxes.insert(l)
        self.board[l.coordinate] = l
        
        l = Box(column: 0, row: 2, boxType: .Red)
        self.boxes.insert(l)
        boxes.insert(l)
        self.board[l.coordinate] = l
        
        l = Box(column: 1, row: 2, boxType: .Red)
        self.boxes.insert(l)
        boxes.insert(l)
        self.board[l.coordinate] = l
        
        var i = Box(column: 2, row: 4, boxType: .Blue)
        self.boxes.insert(i)
        boxes.insert(i)
        self.board[i.coordinate] = i
        
        i = Box(column: 2, row: 3, boxType: .Blue)
        self.boxes.insert(i)
        boxes.insert(i)
        self.board[i.coordinate] = i
        
        i = Box(column: 2, row: 2, boxType: .Blue)
        self.boxes.insert(i)
        boxes.insert(i)
        self.board[i.coordinate] = i
        
        var n = Box(column: 3, row: 4, boxType: .Green)
        self.boxes.insert(n)
        boxes.insert(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 3, row: 3, boxType: .Green)
        self.boxes.insert(n)
        boxes.insert(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 3, row: 2, boxType: .Green)
        self.boxes.insert(n)
        boxes.insert(n)
        self.board[n.coordinate] = n

        n = Box(column: 4, row: 4, boxType: .Green)
        self.boxes.insert(n)
        boxes.insert(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 4, row: 3, boxType: .Green)
        self.boxes.insert(n)
        boxes.insert(n)
        self.board[n.coordinate] = n
        
        n = Box(column: 4, row: 2, boxType: .Green)
        self.boxes.insert(n)
        boxes.insert(n)
        self.board[n.coordinate] = n
        
        var e = Box(column: 6, row: 4, boxType: .Yellow)
        self.boxes.insert(e)
        boxes.insert(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 5, row: 4, boxType: .Yellow)
        self.boxes.insert(e)
        boxes.insert(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 5, row: 3, boxType: .Yellow)
        self.boxes.insert(e)
        boxes.insert(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 5, row: 2, boxType: .Yellow)
        self.boxes.insert(e)
        boxes.insert(e)
        self.board[e.coordinate] = e
        
        e = Box(column: 6, row: 2, boxType: .Yellow)
        self.boxes.insert(e)
        boxes.insert(e)
        self.board[e.coordinate] = e
        
        return boxes
    }
    
    func createBoxes(numberOfBoxes: Int) -> Set<Box>? {
        if self.numberOfEmptyTiles() < numberOfBoxes {
            return nil
        }
        
        var boxes = Set<Box>()
        for _ in 0..<numberOfBoxes{
            var box: Box
            repeat {
                box = Box.random()
            } while (self.boxes.contains(box))
            
            self.boxes.insert(box)
            boxes.insert(box)
            self.board[box.coordinate] = box
            self.graph.remove([self.graph.node(atGridPosition: vector_int2(Int32(box.coordinate.column), Int32(box.coordinate.row)))!])
        }
        
        return boxes
    }
    
    func removeBoxes(boxes: Set<Box>) {
        for box in boxes {
            self.board[box.coordinate] = nil
            self.boxes.remove(box)
            self.graph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(box.coordinate.column), Int32(box.coordinate.row))))
        }
    }
    
    func performMove(move: Move) -> (chain: Chain?, move: Move?) {        
        self.graph.connectToAdjacentNodes(node: GKGridGraphNode(gridPosition: vector_int2(Int32(move.box.coordinate.column), Int32(move.box.coordinate.row))))
        let path = self.graph.findPath(from: self.graph.node(atGridPosition: vector_int2(Int32(move.box.coordinate.column), Int32(move.box.coordinate.row)))!,
                                       to: self.graph.node(atGridPosition: vector_int2(Int32(move.coordinate.column), Int32(move.coordinate.row)))!)
        
        if !path.isEmpty {
            var foundMove = Move(box: move.box, toCoordinate: move.coordinate)
            foundMove.coordinateList = path.map({ (node: GKGraphNode) in
                let n = node as! GKGridGraphNode
                return Coordinate(column: Int(n.gridPosition.x), row: Int(n.gridPosition.y))
            })
            self.board[move.box.coordinate] = nil
            self.boxes.remove(move.box)
            move.box.coordinate = move.coordinate
            self.board[move.coordinate] = move.box
            self.boxes.insert(move.box)
            
            self.graph.remove([self.graph.node(atGridPosition: vector_int2(Int32(move.coordinate.column), Int32(move.coordinate.row)))!])
            
            if let chain = self.chainAtCoordinate(coordinate: move.coordinate) {
                self.score += self.multiplier * chain.score
                if self.score >= 80 && self.currentLevel == 2 {
                    self.currentLevel += 1
                }
                if self.score >= 180 && self.currentLevel == 3 {
                    self.currentLevel += 1
                }
                self.multiplier += 1
                return (chain, foundMove)
            } else {
                self.multiplier = 1
            }
            
            return (nil, foundMove)
        }
        
        self.graph.remove([self.graph.node(atGridPosition: vector_int2(Int32(move.box.coordinate.column), Int32(move.box.coordinate.row)))!])
        return (nil, nil)
    }
    
    func chainAtCoordinate(coordinate: Coordinate) -> Chain? {
        if let box = self.board[coordinate] {
            var chain = Chain(score: 0)
            chain.append(box: box)
            let boxColor = self.board[coordinate]!.boxType
            
            var possibleChain = [Box]()
            var horzLength = 0
            var i = coordinate.column
            
            repeat {
                if !possibleChain.contains(self.board[(i, coordinate.row)]!) {
                    possibleChain.append(self.board[(i, coordinate.row)]!)
                    horzLength += 1
                }
                i -= 1
            } while i >= 0 && self.board[(i, coordinate.row)]?.boxType == boxColor
            
            i = coordinate.column
            
            repeat {
                if !possibleChain.contains(self.board[(i, coordinate.row)]!) {
                    possibleChain.append(self.board[(i, coordinate.row)]!)
                    horzLength += 1
                }
                i += 1
            } while i < NumColumns && self.board[(i, coordinate.row)]?.boxType == boxColor
            
            if horzLength >= 4 {
                chain.append(boxes: possibleChain)
                return chain
            }
            
            chain = Chain(score: 0)
            chain.append(box: box)
            possibleChain = [Box]()
            var vertLength = 0
            
            i = coordinate.row
            repeat {
                if !possibleChain.contains(self.board[(coordinate.column, i)]!) {
                    possibleChain.append(self.board[(coordinate.column, i)]!)
                    vertLength += 1
                }
                i -= 1
            } while i >= 0 && self.board[(coordinate.column, i)]?.boxType == boxColor
            
            i = coordinate.row
            repeat {
                if !possibleChain.contains(self.board[(coordinate.column, i)]!) {
                    possibleChain.append(self.board[(coordinate.column, i)]!)
                    vertLength += 1
                }
                i += 1
            } while i < NumRows && self.board[(coordinate.column, i)]?.boxType == boxColor
            
            if vertLength >= 4 {
                chain.append(boxes: possibleChain)
                return chain
            }
            
            // 1st diagonal
            chain = Chain(score: 0)
            chain.append(box: box)
            possibleChain = [Box]()
            var diagonalLength = 0
            
            i = coordinate.row
            var j = coordinate.column
            
            repeat {
                if !possibleChain.contains(self.board[(j, i)]!) {
                    possibleChain.append(self.board[(j, i)]!)
                    diagonalLength += 1
                }
                i += 1
                j -= 1
            } while i < NumRows && j >= 0 && self.board[(j, i)]?.boxType == boxColor
            
            i = coordinate.row
            j = coordinate.column
            
            repeat {
                if !possibleChain.contains(self.board[(j, i)]!) {
                    possibleChain.append(self.board[(j, i)]!)
                    diagonalLength += 1
                }
                
                i -= 1
                j += 1
            } while i >= 0 && j < NumColumns && self.board[(j, i)]?.boxType == boxColor

            if diagonalLength >= 4 {
                chain.append(boxes: possibleChain)
                return chain
            }
            
            // 2nd diagonal
            chain = Chain(score: 0)
            chain.append(box: box)
            possibleChain = [Box]()
            diagonalLength = 0
            
            i = coordinate.row
            j = coordinate.column
            
            repeat {
                if !possibleChain.contains(self.board[(j, i)]!) {
                    possibleChain.append(self.board[(j, i)]!)
                    diagonalLength += 1
                }
                i -= 1
                j -= 1
            } while i >= 0 && j >= 0 && self.board[(j, i)]?.boxType == boxColor

            i = coordinate.row
            j = coordinate.column
            
            repeat {
                if !possibleChain.contains(self.board[(j, i)]!) {
                    possibleChain.append(self.board[(j, i)]!)
                    diagonalLength += 1
                }
                i += 1
                j += 1
            } while i < NumRows && j < NumColumns && self.board[(j, i)]?.boxType == boxColor

            if diagonalLength >= 4 {
                chain.append(boxes: possibleChain)
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
