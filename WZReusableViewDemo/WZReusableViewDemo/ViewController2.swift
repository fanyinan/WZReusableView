//
//  ViewController.swift
//  WZReusableViewProject
//
//  Created by fanyinan on 2017/9/25.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
  
  var myReusableView: WZReusableView!
  var dataSource: [Int] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    myReusableView = WZReusableView(frame: CGRect(x: 0, y: 50, width: view.bounds.width, height: view.bounds.height - 100))
    myReusableView.clipsToBounds = false
    myReusableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    myReusableView.dataSource = self
    myReusableView.reusableViewDelegate = self
    myReusableView.register(cellClass: MessageReusableCell.self)
    myReusableView.backgroundColor = .gray
    view.addSubview(myReusableView)
    
    navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "test", style: .plain, target: self, action: #selector(ViewController2.test)),UIBarButtonItem(title: "test2", style: .plain, target: self, action: #selector(ViewController2.test2)),UIBarButtonItem(title: "test3", style: .plain, target: self, action: #selector(ViewController2.test3))]
    
    dataSource = [Int](0..<30)
    
  }
  
  @objc private func test() {
//    myReusableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
//    myReusableView.scroll(to: 0, at: .bottom, animated: false)
    
//    dataSource.remove(at: 16)
//    dataSource.remove(at: 14)
    dataSource.remove(at: 29)

//    myReusableView.delete(at: 29, with: .fade) {
      print("finish")
//    }
//    myReusableView.delete(at: [12,14,16], with: .fade)
    
  }
  
  @objc private func test2() {
    dataSource.insert(101, at: 2)
    dataSource.insert(102, at: 4)
//    myReusableView.insert(at: [2,4], with: .fade)
//    myReusableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -40, right: 0)
  }
  
  @objc private func test3() {
    
    dataSource.insert(102, at: 2)
    dataSource.insert(105, at: 5)
    dataSource.remove(at: 12)
    dataSource.remove(at: 13)
    dataSource.remove(at: 14)

//    myReusableView.performBatchUpdates({
//      
//      self.myReusableView.insert(at: [2,5], with: .fade)
//      self.myReusableView.delete(at: [12,13,14], with: .fade)
//
//    }, completion: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    myReusableView.reloadData()
//    myReusableView.scroll(to: 29, at: .bottom, animated: false)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension ViewController2: WZReusableViewDataSource {
  
  func numberOfCells(_ reusableView: WZReusableView) -> Int {
    return dataSource.count
  }
  
  func reusableView(_ reusableView: WZReusableView, cellAt index: Int) -> WZReusableCell {
    
    let type = index % 2 == 0 ? ReusableContentView1.self : ReusableContentView2.self
    let cell = myReusableView.dequeueReusableCell(contentViewType: type, for: index) as! MessageReusableCell
    
    cell.backgroundColor = index % 2 == 0 ? .yellow : .orange
    cell.label.text = "\(dataSource[index])"
    
    return cell
  }
  
  func reusableView(_ reusableView: WZReusableView, heightAt index: Int) -> CGFloat {
    
    return 40
  }
}

extension ViewController2: WZReusableViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
  }
}
