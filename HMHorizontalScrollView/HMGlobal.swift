//
//  HMGlobal.swift
//  HMHorizontalScrollView
//
//  Created by Tony on 30/05/2017.
//  Copyright © 2017 AirActArt. All rights reserved.
//

//  常量和全局函数

import UIKit

typealias hm_Closure = () -> Void

typealias Index = Int

// 屏幕宽度
var hm_screenWidth: CGFloat {
    return min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
}

// 屏幕高度
var hm_screenHeight: CGFloat {
    return max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
}

// 自定义带索引的for_in
func hm_for<T>(_ items: [T]?, closure: (T, Int) -> Void) {
    
    if items == nil {
        return
    }
    
    var index = 0
    
    for item in items! {
        closure(item, index)
        index += 1
    }  
}

