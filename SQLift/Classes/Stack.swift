//
//  Stack.swift
//  Gym Buddy
//
//  Created by Dimitre Bogdanov on 2017-12-19.
//  Copyright © 2017 Dimitre Bogdanov. All rights reserved.
//

import Foundation
class Stack<T> {
    var data = [T]()
    
    func push(item: T) {
        data.append(item)
    }
    
    func pop() -> T {
        return data.removeLast()
    }
    
    func peek() -> T {
        return data.last!
    }
    
    func size() -> Int {
        return data.count
    }
}
