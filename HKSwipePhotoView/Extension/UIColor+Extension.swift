//
//  UIColor+Extension.swift
//  CleanBlocker
//
//  Created by zsy on 2023/3/29.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(_ hex:UInt32, _ alpha:CGFloat = 1){
        self.init(red: CGFloat(((hex & 0xFF0000) >> 16))/255.0, green: CGFloat(((hex & 0xFF00) >> 8))/255.0, blue: CGFloat(((hex & 0xFF)))/255.0, alpha: alpha)
    }
    
    // rgb 为 0-255 的浮点数
    convenience init(r: CGFloat,g : CGFloat ,b : CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    convenience init(r :CGFloat, g :CGFloat, b :CGFloat, a :CGFloat = 1){
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    convenience init(r: Int,g : Int ,b : Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1){
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    class func randomColor() -> UIColor {
        let random = CGFloat(arc4random_uniform(256))
        return UIColor(r: random, g: random, b: random)
    }
    
    class var mainBgColor:UIColor {
        return .white
    }
    
    class var popupSelectColor: UIColor {
        return UIColor(0x2CDF65)
    }
    
    /// 内容
    class var contentColor: UIColor {
        return UIColor(0x646464)
    }
    class var contentSelectColor: UIColor {
        return UIColor(0x242933)
    }
    
    /// 分割线
    class var lineColor: UIColor {
        return UIColor(0xE9E9E9)
    }
    /// 文本颜色
    class var textColor: UIColor {
        return UIColor(0x767676)
    }
    /// 背景颜色 灰
    class var backgroundColor: UIColor {
        return UIColor(0xF4F7FA)
    }
    class var mainColor: UIColor {
        return UIColor(0x2C7AFF)
    }
    
}

