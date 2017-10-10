//
//  MessageReusableCell.swift
//  WZReusableViewProject
//
//  Created by fanyinan on 2017/9/25.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class MessageReusableCell: WZReusableCell {

  var param: Int!
  var label: UILabel!
  var v: UIView!
  
  required init(frame: CGRect, contentViewType: UIView.Type) {
    super.init(frame: frame, contentViewType: contentViewType)
    
    label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    addSubview(label)
    
    v = contentViewType.init()
    v.frame = CGRect(x: frame.width / 3 * 2, y: 0, width: frame.width / 3, height: frame.height)
    v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(v)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
