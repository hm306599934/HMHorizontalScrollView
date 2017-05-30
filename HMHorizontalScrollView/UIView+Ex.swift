//
//  UIView+Extension.swift
//  Lechange3.1
//
//  Created by Jimmy Mu on 3/6/17.
//  Copyright © 2017 Jimmy Mu. All rights reserved.
//

import UIKit

extension UIView {
    
    var x: CGFloat {
        
        get {
            return self.frame.origin.x
        }
        
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        
        get {
            return self.frame.origin.y
        }
        
        set {
            self.frame.origin.y = newValue
        }
    }
    
    var w: CGFloat {
        
        get {
            return self.frame.size.width
        }
        
        set {
            self.frame.size.width = newValue
        }
    }
    
    var h: CGFloat {
        
        get {
            return self.frame.size.height
        }
        
        set {
            self.frame.size.height = newValue
        }
    }
    
    var size: CGSize {
        
        get {
            return self.frame.size
        }
        
        set {
            self.frame.size = newValue
        }
    }
    
    var centerX: CGFloat {
        
        get {
            return self.center.x
        }
        
        set {
            self.center.x = newValue
        }
    }
    
    var centerY: CGFloat {
        
        get {
            return self.center.y
        }
        
        set {
            self.center.y = newValue
        }
    }
    
}
