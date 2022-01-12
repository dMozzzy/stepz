//
//  Fonts.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 6.04.21.
//

import UIKit

extension UIFont {
    var rounded: UIFont {
        return getRounded(size: self.pointSize)
    }
    
    func getRounded(size: CGFloat) -> UIFont {
        let roundedFont: UIFont
        if let descriptor = fontDescriptor.withDesign(.rounded) {
            roundedFont = UIFont(descriptor: descriptor, size: size)
        } else {
            roundedFont = self
        }
        return roundedFont
    }
}
