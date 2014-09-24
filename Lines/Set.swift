//
//  Set.swift
//  aGame
//
//  Created by Mihai Costea on 20/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation

struct Set<T: Hashable>: SequenceType, Printable {
    private var dictionary = Dictionary<T, Bool>()
    
    mutating func addElement(newElement: T) {
        self.dictionary[newElement] = true
    }
    
    mutating func removeElement(element: T) {
        self.dictionary[element] = nil
    }
    
    func containsElement(element: T) -> Bool {
        return dictionary[element] != nil
    }
    
    func allElements() -> [T] {
        return Array(dictionary.keys)
    }
    
    var count: Int {
        return dictionary.count
    }
    
    func unionSet(otherSet: Set<T>) -> Set<T> {
        var combined = Set<T>()
        
        for obj in dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        for obj in otherSet.dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        return combined
    }
    
    // MARK: - SequenceType
    
    func generate() -> IndexingGenerator<Array<T>> {
        return allElements().generate()
    }
    
    // MARK: - Printable
    
    var description: String {
        return dictionary.description
    }
}