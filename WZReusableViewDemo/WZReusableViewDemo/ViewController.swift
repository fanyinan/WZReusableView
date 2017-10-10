//
//  ViewController.swift
//  WZReusableViewProject
//
//  Created by fanyinan on 2017/9/25.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  override func viewDidAppear(_ animated: Bool) {

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func click() {
    
    navigationController!.pushViewController(ViewController2(), animated: true)
    
  }
  
}
