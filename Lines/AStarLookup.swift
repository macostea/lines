//
//  AStarLookup.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

class AStarLookup {
    let source: Coordinate
    let destination: Coordinate
    let board: Array2D<Box>
    
    private var openSteps = [Step]()
    private var closedSteps = [Step]()
    
    init(source: Coordinate, destination: Coordinate, board: Array2D<Box>) {
        self.source = source
        self.destination = destination
        self.board = board
    }
    
    func findMove() -> Move? {
        var pathFound = false
        self.insertInOpenSteps(step: Step(position: self.source))
        repeat {
            let currentStep = self.openSteps.first
            self.closedSteps.append(currentStep!)
            self.openSteps.remove(at: 0)
            if currentStep!.position == self.destination {
                pathFound = true
                var move = Move(box: self.board[self.source]!, toCoordinate: self.destination)
                move.coordinateList = [Coordinate]()
                var tmpStep = currentStep
                repeat {
                    move.coordinateList?.append(tmpStep!.position)
                    tmpStep = tmpStep!.parent
                } while tmpStep != nil
                
                move.coordinateList?.reverse()
                return move
            }
            
            let adjSteps = self.walkableAdjacentBoxesForCoordinate(coordinate: currentStep!.position)
            for pos in adjSteps {
                var step = Step(position: pos)
                
                if (self.closedSteps.firstIndex(of: step) != nil) {
                    continue;
                }
                
                let moveCost = self.costToMoveFromStep(step: currentStep!, toStep: step)
                let index = self.openSteps.firstIndex(of: step)
                if index == nil {
                    step.parent = currentStep
                    step.gScore = currentStep!.gScore + moveCost
                    step.hScore = self.computeHScoreFromCoordinate(coordinate: step.position, toCoordinate: self.destination)
                    self.insertInOpenSteps(step: step)
                } else {
                    step = self.openSteps[index!]
                    if (currentStep!.gScore + moveCost) < step.gScore {
                        step.gScore = currentStep!.gScore + moveCost
                        self.openSteps.remove(at: index!)
                        self.insertInOpenSteps(step: step)
                    }
                }
            }
        
        } while self.openSteps.count > 0
        
        return nil
    }
    
    private func insertInOpenSteps(step: Step) {
        let stepFScore = step.fScore()
        let count = self.openSteps.count
        
        var index = 0
        
        for i in 0..<count {
            if stepFScore <= (self.openSteps[i] as Step).fScore() {
                index = i
                break;
            }
        }
        
        self.openSteps.insert(step, at: index)
    }
    
    private func computeHScoreFromCoordinate(coordinate: Coordinate, toCoordinate: Coordinate) -> Int {
        return abs(toCoordinate.column - coordinate.column) + abs(toCoordinate.row - coordinate.row)
    }
    
    private func costToMoveFromStep(step: Step, toStep: Step) -> Int {
        return 1
    }
    
    private func walkableAdjacentBoxesForCoordinate(coordinate: Coordinate) -> [Coordinate] {
        var tmp = [Coordinate]()
        
        var coord = (coordinate.column, coordinate.row - 1)
        if self.isValidCoordinate(coordinate: coord) {
            tmp.append(coord)
        }
        coord = (coordinate.column, coordinate.row + 1)
        if self.isValidCoordinate(coordinate: coord) {
            tmp.append(coord)
        }
        coord = (coordinate.column - 1, coordinate.row)
        if self.isValidCoordinate(coordinate: coord) {
            tmp.append(coord)
        }
        coord = (coordinate.column + 1, coordinate.row)
        if self.isValidCoordinate(coordinate: coord) {
            tmp.append(coord)
        }
        
        return tmp
    }
    
    private func isValidCoordinate(coordinate: Coordinate) -> Bool {
        if coordinate.row >= NumRows || coordinate.row < 0 {
            return false
        }
        if coordinate.column >= NumColumns || coordinate.column < 0 {
            return false
        }
        
        if self.board[coordinate] != nil {
            return false
        }
        
        return true
    }
}
