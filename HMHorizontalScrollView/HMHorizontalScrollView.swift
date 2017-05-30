//
//  HMHorizontalScrollView.swift
//  HMHorizontalScrollView
//
//  Created by Tony on 30/05/2017.
//  Copyright © 2017 AirActArt. All rights reserved.
//
//  横向滑动的scrollView，面向协议编程，复用cell

import UIKit
import SnapKit

protocol HMHorizontalScrollViewDataSource: NSObjectProtocol {
    // cell数量
    func numberOfCells(in horizontalScrollView: HMHorizontalScrollView) -> Int
    // 自身的宽度
    func viewWidth(in horizontalScrollView: HMHorizontalScrollView) -> CGFloat
    // cell的宽度
    func horizontalScrollView(_ horizontalScrollView: HMHorizontalScrollView, cellSizeAt index: Index) -> CGSize
    // 返回cell
    func horizontalScrollView(in horizontalScrollView: HMHorizontalScrollView, cellAt index: Index) -> HMHorizontalScrollCell
}

class HMHorizontalScrollView: UIView {
    
    weak var dataSource: HMHorizontalScrollViewDataSource?
    
    fileprivate var numberOfCells: Int {
        return dataSource?.numberOfCells(in: self) ?? 0
    }
    
    fileprivate var cellSize: CGSize {
        return dataSource?.horizontalScrollView(self, cellSizeAt: 0) ?? CGSize()
    }
    
    fileprivate var width: CGFloat {
        return dataSource?.viewWidth(in: self) ?? 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    fileprivate func setUp() {
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.centerY.equalTo(self)
            make.height.equalTo(self)
        }

    }
    
    func reloadView() {
        
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        //偏移量
        var offX: CGFloat = 0
        
        // 添加收藏点
        hm_for(cells) { cell, index in
            
            let newCell = dataSource?.horizontalScrollView(in: self, cellAt: index)
            newCell?.frame = CGRect(x: offX, y: 0, width: cellSize.width, height: cellSize.height)
            
            if let newCell = newCell {
                scrollView.addSubview(newCell)
            }
            
            offX += cellSize.width
        }
        
        let contentWidth = (cellSize.width) * CGFloat(numberOfCells) < hm_screenWidth ? hm_screenWidth + 1 : (cellSize.width) * CGFloat(numberOfCells)
        scrollView.contentSize = CGSize(width: contentWidth, height: 0)
    }
    
    func dequeueReusableCell(at index: Index) -> HMHorizontalScrollCell? {
        
        for cell in cells {
            
            let cellX = CGFloat(index) * cellSize.width
            
            if cellX >= cell.frame.origin.x && cellX < (cell.frame.origin.x + cellSize.width) {
                return cell
            }
        }
        
        return nil
    }
    
// MARK: - 🤡初始化
    
    fileprivate lazy var scrollView: UIScrollView = {
        let result = UIScrollView()
        result.showsHorizontalScrollIndicator = false
        result.showsVerticalScrollIndicator = false
        result.isPagingEnabled = false
        result.backgroundColor = .red
        result.delegate = self
        result.contentOffset = CGPoint()
        
        return result
    }()
    
    fileprivate lazy var cells: [HMHorizontalScrollCell] = {
        
        var result = [HMHorizontalScrollCell]()
        
        // 添加收藏点
        for i in 0 ..< self.numberOfCacheView  {
            let cell = HMHorizontalScrollCell(frame: CGRect())
            cell.frame = CGRect(x: CGFloat(i) * self.cellSize.width, y: 0, width: self.cellSize.width, height: self.cellSize.height)
            
            result.append(cell)
        }
        
        return result
    }()
    
    fileprivate var numberOfCacheView: Int {
        return self.numberOfCells < maxNumberOfCacheView ? self.numberOfCells : maxNumberOfCacheView
    }
    
    fileprivate var maxNumberOfCacheView: Int {
        return Int(width / cellSize.width) + 3
    }

}

// MARK: - 🤡UIScrollView Delegate

extension HMHorizontalScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 第一次次进来会向下滑动64
        scrollView.contentOffset.y = 0
        
        if numberOfCacheView < maxNumberOfCacheView {
            return
        }
        
        if scrollView.contentOffset.x < 0 {
            // 滑到第一个
            resetItemViewOfStart()
            
        } else if scrollView.contentOffset.x + scrollView.w > scrollView.contentSize.width {
            // 滑到最后一个
            resetItemViewOfEnd()
            
        } else if cells[1].frame.origin.x + cells[0].w < scrollView.contentOffset.x  {
            // 左滑
            resetItemViewOfLeftPan()
            // 更新最后一个显示
            let lastCellIndex = Int((cells.last?.frame.origin.x ?? 0) / cellSize.width)
            _ = dataSource?.horizontalScrollView(in: self, cellAt: lastCellIndex)
            
        } else if cells[numberOfCacheView - 2].frame.origin.x > scrollView.contentOffset.x + scrollView.frame.width {
            // 右滑
            resetItemViewOfRightPan()
            // 更新第一个显示
            let firstCellIndex = Int((cells.first?.frame.origin.x ?? 0) / cellSize.width)
            _ = dataSource?.horizontalScrollView(in: self, cellAt: firstCellIndex)
        }
        
    }
    
    // 滑到第一个
    func resetItemViewOfStart() {
        
        hm_for(cells) { cell, index in
            cell.frame.origin.x = cell.frame.width * CGFloat(index)
            
            _ = dataSource?.horizontalScrollView(in: self, cellAt: Int(cell.frame.origin.x / cellSize.width))
        }
    }
    
     // 滑到最后一个
    func resetItemViewOfEnd() {
        
        hm_for(cells) { cell, index in
            cell.frame.origin.x = scrollView.contentSize.width - cell.frame.width * CGFloat(numberOfCacheView - index)
            
            _ = dataSource?.horizontalScrollView(in: self, cellAt: Int(cell.frame.origin.x / cellSize.width))
        }
    }
    
     // 左滑
    func resetItemViewOfLeftPan() {
        
        let temp = cells.first!
        temp.frame.origin.x = cells.last!.frame.origin.x + temp.w
        
        hm_for(cells) { (cell, index) in
            if index < cells.count - 1 {
                cells[index] = cells[index + 1]
            } else {
                cells[index] = temp
            }
        }
    }
    
    // 右滑
    func resetItemViewOfRightPan() {
        
        let temp = cells.last!
        temp.frame.origin.x = cells.first!.frame.origin.x - temp.w
        
        hm_for(cells) { (cell, index) in
            if index < cells.count - 1 {
                cells[cells.count - index - 1] = cells[cells.count - index - 2]
            } else {
                cells[cells.count - index - 1] = temp
            }
        }
    }
}

// MARK: - 🤡显示界面

class HMHorizontalScrollCell: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        
        backgroundColor = .green
        
        addSubview(imageView)
        imageView.snp.remakeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.remakeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
    }
    
    
    lazy var imageView: UIImageView = {
        
        let result = UIImageView()
        result.isHidden = false
        result.image = UIImage(named: "bg")
        
        return result
    }()
    
    
    lazy var titleLabel: UILabel = {
        
        let result = UILabel()
        result.isHidden = false
        result.font = UIFont.systemFont(ofSize: 13)
        result.textAlignment = .center
        result.textColor = .blue
        result.text = "123"
        
        return result
    }()
}
