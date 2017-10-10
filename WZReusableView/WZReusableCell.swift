//
//  WZReusableCell.swift
//  WZReusableViewProject
//
//  Created by fanyinan on 2017/9/25.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

open class WZReusableCell: UIView {

  open var contentViewType: UIView.Type
  
  required public init(frame: CGRect, contentViewType: UIView.Type) {
    self.contentViewType = contentViewType
    super.init(frame: frame)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
