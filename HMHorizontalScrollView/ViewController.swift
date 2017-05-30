//
//  ViewController.swift
//  HMHorizontalScrollView
//
//  Created by Tony on 30/05/2017.
//  Copyright © 2017 AirActArt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(300)
            make.height.equalTo(80)
        }
        
        scrollView.reloadView()
        
    }
    
    fileprivate lazy var scrollView: HMHorizontalScrollView = {
        let result = HMHorizontalScrollView()
        result.dataSource = self
        
        return result
    }()


}

extension ViewController: HMHorizontalScrollViewDataSource {
    
    func numberOfCells(in horizontalScrollView: HMHorizontalScrollView) -> Int {
        return 1000
    }
    
    func viewWidth(in horizontalScrollView: HMHorizontalScrollView) -> CGFloat {
        return hm_screenWidth
    }
    
    func horizontalScrollView(_ horizontalScrollView: HMHorizontalScrollView, cellSizeAt index: Index) -> CGSize {
        
        return CGSize(width: 130, height: 80)
    }
    
    func horizontalScrollView(in horizontalScrollView: HMHorizontalScrollView, cellAt index: Index) -> HMHorizontalScrollCell {
        
        let cell = horizontalScrollView.dequeueReusableCell(at: index)
        cell?.titleLabel.text = "index:__\(index)"
        
        return cell ?? HMHorizontalScrollCell()
    }
    
}
