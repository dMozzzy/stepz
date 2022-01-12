//
//  Array.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 14.10.21.
//

import Foundation

extension Array {
    
    func tryGet(_ index: Int) -> Element? {
        if index < count {
            return self[index]
        } else {
            return nil
        }
    }
    
}
