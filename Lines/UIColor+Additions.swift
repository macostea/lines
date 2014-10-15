//
//  UIColor+Additions.swift
//  Lines
//
//  Created by Mihai Costea on 26/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    private convenience init(hex: UInt32) {
        let r: CGFloat = CGFloat(CGFloat((hex >> 16) & 0xFF) / CGFloat(255))
        let g: CGFloat = CGFloat(CGFloat((hex >> 8) & 0xFF) / CGFloat(255))
        let b: CGFloat = CGFloat(CGFloat((hex) & 0xFF) / CGFloat(255))
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    class func linesWhiteColor() -> UIColor {
        return UIColor(hex: 0xF7F7F7)
    }
    
    class func linesRedColor() -> UIColor {
        return UIColor(hex: 0xFF1300)
    }
    
    class func linesGreenColor() -> UIColor {
        return UIColor(hex: 0x0BD318)
    }
    
    class func linesBlueColor() -> UIColor {
        return UIColor(hex: 0x007AFF)
    }
    
    class func linesYellowColor() -> UIColor {
        return UIColor(hex: 0xFFCC00)
    }
    
    class func linesOrangeColor() -> UIColor {
        return UIColor(hex: 0xFF5E3A)
    }
    
    class func linesGrayColor() -> UIColor {
        return UIColor(hex: 0xC7C7CC)
    }
}