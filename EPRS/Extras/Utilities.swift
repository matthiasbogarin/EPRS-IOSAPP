//
//  Utilities.swift
//  EPRS
//
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 177/255, green: 149/255, blue: 58/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.layer.borderWidth = 3
        button.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        button.layer.borderColor = CGColor.init(srgbRed: 177/255, green: 149/255, blue: 58/255, alpha: 0)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.init(red: 177/255, green: 149/255, blue: 58/255, alpha: 1)
    
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Gold Buttons
        button.backgroundColor = UIColor.init(red: 177/255, green: 149/255, blue: 58/255, alpha: 1)
        button.layer.borderWidth = 3
        button.layer.borderColor = CGColor.init(srgbRed: 177/255, green: 149/255, blue: 58/255, alpha: 0)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
}
