//
//  HMHorizontalScrollView.swift
//  HMHorizontalScrollView
//
//  Created by Tony on 30/05/2017.
//  Copyright © 2017 AirActArt. All rights reserved.
//
//  横向滑动的scrollView，面向协议编程，复用cell

import SnapKit
import UIKit

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

protocol HMHorizontalScrollViewDelegate: NSObjectProtocol {
    // 点击
    func horizontalScrollView(in horizontalScrollView: HMHorizontalScrollView, didSelectAt index: Index)
}

class HMHorizontalScrollView: UIView {
    // 数据源
    weak var dataSource: HMHorizontalScrollViewDataSource?
    // 委托
    weak var delegate: HMHorizontalScrollViewDelegate?
    // 委托
    var separatorWidth: CGFloat = 0
    // cell的数量
    fileprivate var numberOfCells: Int {
        return dataSource?.numberOfCells(in: self) ?? 0
    }
    // cell尺寸
    fileprivate var cellSize: CGSize {
        return dataSource?.horizontalScrollView(self, cellSizeAt: 0) ?? CGSize()
    }
    // 界面宽度
    fileprivate var viewWidth: CGFloat {
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
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    /// 重新加载界面
    func reloadView() {
        cells.removeAll()
        
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        // 偏移量
        var offX: CGFloat = separatorWidth
        
        // 初始化cells
        for i in 0 ..< self.numberOfCacheView  {
            let cell = dataSource?.horizontalScrollView(in: self, cellAt: i)
            cell?.frame = CGRect(x: offX, y: 0, width: cellSize.width, height: cellSize.height)
            cell?.setNeedsDisplay()
            
            if let cell = cell {
                scrollView.addSubview(cell)
                cells.append(cell)
            }
            
            offX += cellSize.width + separatorWidth
        }
        
        // 当不足一屏时，添加一个像素用于触发弹簧效果
        let tempWidth = cellSize.width * CGFloat(numberOfCells) + separatorWidth * (CGFloat(numberOfCells) + 1)
        let contentWidth = tempWidth <= hm_screenWidth ? hm_screenWidth + 1 : tempWidth
        scrollView.contentSize = CGSize(width: contentWidth, height: 0)
    }
    
    /// 获取复用的cell
    ///
    /// - Parameter index: 索引
    /// - Returns: 对应的cell
    func dequeueReusableCell(at index: Index) -> HMHorizontalScrollCell? {
        
        for cell in cells {
            
            let cellX = CGFloat(index) * cellSize.width + separatorWidth * CGFloat(index + 1)
            
            if cellX >= cell.frame.origin.x &&
                cellX < (cell.frame.origin.x + cellSize.width) {
                return cell
            }
        }
        
        return nil
    }
    
    /// 获取cell
    ///
    /// - Parameter index: 索引
    /// - Returns: 对应的cell
    func getCell(at index: Index) -> HMHorizontalScrollCell? {
        
        return dequeueReusableCell(at: index)
    }
    
    // MARK: - 🤡手势
    
    func didTap(recognizer: UITapGestureRecognizer) {
        
        let tapPoint = recognizer.location(in: self)
        
        let cellIndex = Int((tapPoint.x  + scrollView.contentOffset.x) / (cellSize.width + separatorWidth))
        delegate?.horizontalScrollView(in: self, didSelectAt: cellIndex)
    }
    
    // MARK: - 🤡初始化
    
    fileprivate lazy var scrollView: UIScrollView = {
        let result = UIScrollView()
        result.showsHorizontalScrollIndicator = false
        result.showsVerticalScrollIndicator = false
        result.isPagingEnabled = false
        result.delegate = self
        result.contentOffset = CGPoint()
        
        return result
    }()
    
    /// 缓存的cell,最多只保留maxNumberOfCacheView个，可能小于maxNumberOfCacheView
    fileprivate lazy var cells: [HMHorizontalScrollCell] = {
        
        var result = [HMHorizontalScrollCell]()
        
        return result
    }()
    
    /// 缓存cell个数
    fileprivate var numberOfCacheView: Int {
        return self.numberOfCells < maxNumberOfCacheView ? self.numberOfCells : maxNumberOfCacheView
    }
    
    /// 最大缓存个数，当数据源较小时，不需要进行缓存
    fileprivate var maxNumberOfCacheView: Int {
        return Int(viewWidth / (cellSize.width + separatorWidth)) + 3
    }
    
}

// MARK: - 🤡UIScrollView Delegate

extension HMHorizontalScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 第一次次进来会可能向下滑动64
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
            
        } else if cells[1].frame.origin.x + cells[0].w + separatorWidth < scrollView.contentOffset.x  {
            // 左滑
            resetItemViewOfLeftPan()
            // 更新最后一个显示
            let lastCellIndex = Int((cells.last?.frame.origin.x ?? 0) / (cellSize.width + separatorWidth))
            if lastCellIndex > 0 && lastCellIndex < numberOfCells {
                _ = dataSource?.horizontalScrollView(in: self, cellAt: lastCellIndex)
            }
            
        } else if cells[numberOfCacheView - 2].frame.origin.x > scrollView.contentOffset.x + scrollView.frame.width {
            // 右滑
            resetItemViewOfRightPan()
            // 更新第一个显示
            let firstCellIndex = Int((cells.first?.frame.origin.x ?? 0) / (cellSize.width + separatorWidth))
            if firstCellIndex > 0 && firstCellIndex < numberOfCells {
                _ = dataSource?.horizontalScrollView(in: self, cellAt: firstCellIndex)
            }
        }
        
    }
    
    // 滑到第一个
    func resetItemViewOfStart() {
        
        hm_for(cells) { cell, index in
            
            cell.x = separatorWidth + (cellSize.width + separatorWidth) * CGFloat(index)
            
            if let index = indexOf(x: cell.x) {
                _ = dataSource?.horizontalScrollView(in: self, cellAt: index)
            }
        }
    }
    
    // 滑到最后一个
    func resetItemViewOfEnd() {
        
        hm_for(cells) { cell, index in
            cell.x = scrollView.contentSize.width - (cellSize.width + separatorWidth) * CGFloat(numberOfCacheView - index)
            
            if let index = indexOf(x: cell.x) {
                _ = dataSource?.horizontalScrollView(in: self, cellAt: index)
            }
        }
    }
    
    // 左滑
    func resetItemViewOfLeftPan() {
        
        let temp = cells.first!
        temp.x = cells.last!.x + (cellSize.width + separatorWidth)
        
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
        temp.x = cells.first!.x - (cellSize.width + separatorWidth)
        
        hm_for(cells) { (cell, index) in
            if index < cells.count - 1 {
                cells[cells.count - index - 1] = cells[cells.count - index - 2]
            } else {
                cells[cells.count - index - 1] = temp
            }
        }
    }
    
    func indexOf(x: CGFloat) -> Index? {
        
        if cellSize.width + separatorWidth != 0 {
            return Int(x / (cellSize.width + separatorWidth))
        }
        
        return nil
    }
}

// MARK: - 🤡显示界面

class HMHorizontalScrollCell: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}

