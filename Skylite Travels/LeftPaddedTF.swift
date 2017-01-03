//
//  File.swift
//  Skylite Travels
//
//  Created by Venkateswara on 22/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import Foundation
import UIKit

class LeftPaddedTF: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 15, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 15, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
}
