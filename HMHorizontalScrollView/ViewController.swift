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
        result.separatorWidth = 1.0
        result.dataSource = self
        result.delegate = self
        
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
        
        var cell = horizontalScrollView.dequeueReusableCell(at: index) as? HMDefinedScrollCell
        
        if cell == nil {
            cell = HMDefinedScrollCell(frame: CGRect())
        }
        
        cell?.imageView.image = UIImage(named: "bg")
        cell?.titleLabel.text = "🐱🐱__\(index)"
        
        
        return cell!
    }
    
}

// MARK: - 🤡LCLivePtzCollectItem Delegate

extension ViewController: HMHorizontalScrollViewDelegate {
    
    
    func horizontalScrollView(in horizontalScrollView: HMHorizontalScrollView, didSelectAt index: Index) {
        
        
        print("\(index)")
        
    }
}

// MARK: - 🤡LCLivePtzCollectItemView

fileprivate let lineWidth: CGFloat = 1.5
fileprivate let cellSize = CGSize(width: 135, height: 76)

fileprivate class HMDefinedScrollCell: HMHorizontalScrollCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        
        backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        
        addSubview(imageView)
        imageView.snp.remakeConstraints { (make) in
            make.top.equalTo(self).offset(lineWidth)
            make.bottom.equalTo(self).offset(-lineWidth)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(8)
            make.height.equalTo(25)
            make.right.equalTo(self)
        }
    }
    
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textAlignment = .left
        result.textColor = .white
        result.font = UIFont.systemFont(ofSize: 12)
        result.isHidden = false
        
        return result
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImage(named: "ptz_bg_collect")
        
        let result = UIImageView()
        result.image = image
        result.size = image?.size ?? CGSize()
        result.isHidden = false
        
        return result
    }()
}
