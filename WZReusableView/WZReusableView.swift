//
//  WZReusableView.swift
//  WZReusableViewProject
//
//  Created by fanyinan on 2017/9/25.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

public protocol WZReusableViewDataSource: NSObjectProtocol {
  
  func numberOfCells(_ reusableView: WZReusableView) -> Int
  func reusableView(_ reusableView: WZReusableView, cellAt index: Int) -> WZReusableCell
  func reusableView(_ reusableView: WZReusableView, heightAt index: Int) -> CGFloat

}

@objc public protocol WZReusableViewDelegate: UIScrollViewDelegate {
  
  @objc optional func reusableView(_ reusableView: WZReusableView, willDisplay cell: WZReusableCell, at index: Int)
  @objc optional func reusableView(_ reusableView: WZReusableView, didEndDisplaying cell: WZReusableCell, at index: Int)

}

public enum WZReusableViewScrollPosition {
  
  case top
  
  case middle
  
  case bottom
}

class VisibleCellInfo {
  var cell: WZReusableCell
  var index: Int
  
  init(cell: WZReusableCell, index: Int) {
    self.cell = cell
    self.index = index
  }
}

open class WZReusableView: UIScrollView {

  open weak var dataSource: WZReusableViewDataSource!
  open weak var reusableViewDelegate: WZReusableViewDelegate? {
    didSet {
      delegate = reusableViewDelegate
    }
  }
  
  private var reusableCellPool: [String: [WZReusableCell]] = [:]
  private var registeredCellClass = WZReusableCell.self
  private var cellFrames: [CGRect] = []
  private var contentView = UIView()
  private var visibleCellInfoList: [VisibleCellInfo] = []
  
  public private(set) var numberOfCells = 0
  public var visibleCells: [WZReusableCell] { return visibleCellInfoList.map({$0.cell}) }
  public var indicesForVisibleCells: [Int] { return visibleCellInfoList.map({$0.index}) }
  private var isLoadedData = false
  private let animationDuration: TimeInterval = 0.3
  private var insertIndices: [Int] = [], deleteIndices: [Int] = []
  private var isMultipleAnimation = false
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    alwaysBounceVertical = true
    addSubview(contentView)
    addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
  }
  
  deinit {
    removeObserver(self, forKeyPath: "contentOffset")
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()

  }
  
  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    guard isLoadedData else { return }
    
    guard let new = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue else { return }
    guard let old = (change?[NSKeyValueChangeKey.oldKey] as? NSValue)?.cgPointValue else { return }
    
    let changedContentOffset = new.y - old.y
    
    guard changedContentOffset != 0 else { return }
    
    removeCell(changedContentOffset: changedContentOffset)
    appendCell(changedContentOffset: changedContentOffset)
    
  }
  
  open func register(cellClass: WZReusableCell.Type) {
    registeredCellClass = cellClass
  }

  open func dequeueReusableCell(contentViewType: UIView.Type, for index: Int) -> WZReusableCell {
    
    if let cell = getCellFromReusableCellPool(contentViewType: contentViewType) {
      cell.frame = cellFrames[index]
      return cell
    }

    return registeredCellClass.init(frame: cellFrames[index], contentViewType: contentViewType)
  }
  
  open func reloadData() {
    
    isLoadedData = false

    reloadCellsFrame()
    reloadVisibleCells()
    
    isLoadedData = true

  }
  
  open func reload(indices: [Int]) {
  
    isLoadedData = false

    let oldFrames = cellFrames
    let oldContentSizeHeight = contentSize.height
    
    for i in indices {
      
      guard let visibleCellInfo = visibleCellInfoList.filter({$0.index == i}).first else { continue }
      
      visibleCellInfo.cell.removeFromSuperview()
      let cell = addCell(at: i)
      visibleCellInfo.cell = cell
    }
    
    reloadCellsFrame()
    
    if contentSize.height < oldContentSizeHeight {
      
      reloadVisibleCells()
      visibleCellInfoList.forEach({$0.cell.frame = oldFrames[$0.index]})
      UIView.animate(withDuration: animationDuration) {
        self.visibleCellInfoList.forEach({$0.cell.frame = self.cellFrames[$0.index]})
      }
      
    } else if contentSize.height > oldContentSizeHeight {
      
      UIView.animate(withDuration: animationDuration, animations: {
        self.visibleCellInfoList.forEach({$0.cell.frame = self.cellFrames[$0.index]})
      }, completion: {_ in
        self.reloadVisibleCells()
      })
    }

    isLoadedData = true

  }

  open func cell(at index: Int) -> WZReusableCell? {
    
    guard !visibleCellInfoList.isEmpty else { return nil }
    
    guard index >= visibleCellInfoList.first!.index && index <= visibleCellInfoList.last!.index else { return nil }
    return visibleCellInfoList[index - visibleCellInfoList.first!.index].cell
  }
  
  open func scroll(to index: Int, at position: WZReusableViewScrollPosition, animated: Bool) {
  
    guard index >= 0 && index < cellFrames.count else { return }
    let cellFrame = cellFrames[index]
    
    var contentOffsetY: CGFloat = 0
    
    switch position {
    case .bottom:
      contentOffsetY = cellFrame.maxY - (frame.height - contentInset.bottom)
    case .middle:
      contentOffsetY = cellFrame.midY - frame.height / 2
    case .top:
      contentOffsetY = cellFrame.minY
    }
    
    setContentOffset(CGPoint(x: 0, y: min(max(-contentInset.top, contentOffsetY), contentSize.height)), animated: animated)
    
  }
  
  open func index(at point: CGPoint) -> Int? {
    
    guard frame.contains(point) else { return nil }
    
    for visibleCellInfo in visibleCellInfoList {
      
      if visibleCellInfo.cell.frame.contains(point) {
        return visibleCellInfo.index
      }
    }
    
    return nil
  }
  
  open func rect(at index: Int) -> CGRect {
    
    guard index >= 0 && index < cellFrames.count else { return .zero }
    return cellFrames[index]
    
  }

  private func reloadCellsFrame() {
    
    numberOfCells = dataSource.numberOfCells(self)
    
    var totalHeight: CGFloat = 0
    
    cellFrames.removeAll()

    for i in 0..<numberOfCells {
      
      let cellHeight = dataSource.reusableView(self, heightAt: i)
      cellFrames.append(CGRect(x: 0, y: totalHeight, width: frame.width, height: cellHeight))
      totalHeight += cellHeight
      
    }
    
    contentSize = CGSize(width: frame.width, height: totalHeight)
    contentView.frame = CGRect(origin: .zero, size: contentSize)
  }

  private func reloadVisibleCells() {
  
    visibleCellInfoList.forEach({$0.cell.removeFromSuperview()})
    visibleCellInfoList.forEach({addCellIntoReusableCellPool(cell: $0.cell)})
    visibleCellInfoList.removeAll()
    
    for (index, cellFrame) in cellFrames.enumerated() {
      
      if isVisible(rect: cellFrame) {
        
        let cell = addCell(at: index)
        visibleCellInfoList.append(VisibleCellInfo(cell: cell, index: index))
        
      }
    }
  }
  
  private func removeCell(changedContentOffset: CGFloat) {
    
    if changedContentOffset > 0 {
      
      removeFromTop()
      
    } else {
      
      removeFromBottom()
    }
  }
  
  private func removeFromTop() {
    
    var removeCount = 0
    for cellInfo in visibleCellInfoList {
      
      let cell = cellInfo.cell
      
      guard !isVisible(rect: cell.frame) else { break }
      removeCount += 1
      
      addCellIntoReusableCellPool(cell: cell)
      
      cell.removeFromSuperview()
    }
    
    visibleCellInfoList.removeSubrange(0..<removeCount)
    
  }
  
  private func removeFromBottom() {
    
    var removeCount = 0
    for cellInfo in visibleCellInfoList.reversed() {
      
      let cell = cellInfo.cell
      
      guard !isVisible(rect: cell.frame) else { break }
      removeCount += 1
      
      addCellIntoReusableCellPool(cell: cell)
      
      reusableViewDelegate?.reusableView?(self, didEndDisplaying: cell, at: cellInfo.index)
      cellInfo.cell.removeFromSuperview()
    }
    
    visibleCellInfoList.removeSubrange((visibleCellInfoList.count - removeCount)..<visibleCellInfoList.count)
    
  }
  
  private func appendCell(changedContentOffset: CGFloat) {
    
    if changedContentOffset > 0 {
      
      appendAtBottom()
      
    } else {

      appendAtTop()
      
    }
  }
  
  @discardableResult
  private func appendAtBottom() -> [VisibleCellInfo] {
    
    var firstCellIndexToLoad = 0
    
    if let lastVisibleCellIinfo = visibleCellInfoList.last {
      firstCellIndexToLoad = lastVisibleCellIinfo.index + 1
    } else {
      firstCellIndexToLoad = cellIndex(point: CGPoint(x: 0, y: contentOffset.y)) ?? 0
    }
    
    guard firstCellIndexToLoad >= 0 && firstCellIndexToLoad < numberOfCells else { return [] }
    
    var appendCellInfos: [VisibleCellInfo] = []

    for i in firstCellIndexToLoad..<numberOfCells {
      
      guard isVisible(rect: cellFrames[i]) else { break }
      
      let cell = addCell(at: i)
      
      let visibleCellInfo = VisibleCellInfo(cell: cell, index: i)
      visibleCellInfoList.append(visibleCellInfo)
      appendCellInfos.append(visibleCellInfo)
    }
    
    return appendCellInfos
  }
  
  @discardableResult
  private func appendAtTop() -> [VisibleCellInfo] {
    
    var lastCellIndexToLoad = 0
    
    if let firstVisibleCellIinfo = visibleCellInfoList.first {
      lastCellIndexToLoad = firstVisibleCellIinfo.index - 1
    } else {
      lastCellIndexToLoad = cellIndex(point: CGPoint(x: 0, y: contentOffset.y + frame.height)) ?? 0
    }
    
    guard lastCellIndexToLoad >= 0 && lastCellIndexToLoad < numberOfCells else { return [] }
    
    var appendCellInfos: [VisibleCellInfo] = []
    
    for i in (0...lastCellIndexToLoad).reversed() {
      
      guard isVisible(rect: cellFrames[i]) else { break }
      
      let cell = addCell(at: i)
      appendCellInfos.append(VisibleCellInfo(cell: cell, index: i))
      
    }
    
    visibleCellInfoList.insert(contentsOf: appendCellInfos.reversed(), at: 0)
    
    return appendCellInfos
  }
  
  private func isVisible(rect: CGRect) -> Bool {
    
    func isVisible(y: CGFloat) -> Bool {
      return y >= max(contentOffset.y, 0) && y <= min(contentOffset.y + frame.height, contentSize.height == 0 ? CGFloat.greatestFiniteMagnitude : contentSize.height)
    }
    
    return isVisible(y: rect.minY) || isVisible(y: rect.maxY)
  }
  
  private func addCellIntoReusableCellPool(cell: WZReusableCell) {
    
    let identifier = "\(cell.contentViewType)"

    var cells = reusableCellPool[identifier] ?? []
    cells.append(cell)
    reusableCellPool[identifier] = cells
  }
  
  private func getCellFromReusableCellPool(contentViewType: UIView.Type) -> WZReusableCell? {
    
    let identifier = "\(contentViewType)"
    
    if var cellsForIdentifier = reusableCellPool[identifier], !cellsForIdentifier.isEmpty {
      let cell = cellsForIdentifier.removeLast()
      reusableCellPool[identifier] = cellsForIdentifier
      return cell
    }
    
    return nil
  }
  
  private func addCell(at index: Int) -> WZReusableCell {
    
    let cell = dataSource.reusableView(self, cellAt: index)
    contentView.addSubview(cell)
    reusableViewDelegate?.reusableView?(self, willDisplay: cell, at: index)
    return cell
  }
  
  private func cellIndex(point: CGPoint) -> Int? {
    
    var begin = 0, end = cellFrames.count - 1
    
    while begin <= end {
      
      let mid = (begin + end) / 2
      let frame = cellFrames[mid]
      
      if frame.contains(point) {
        return mid
      } else if point.y < frame.minY {
        end = mid - 1
      } else if point.y >= frame.maxY {
        begin = mid + 1
      }
    }
    
    return nil
  }
}
