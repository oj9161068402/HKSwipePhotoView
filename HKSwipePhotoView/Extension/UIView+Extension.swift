//
//  UIView+Extension.swift
//  CleanBlocker
//
//  Created by zsy on 2023/3/29.
//

import Foundation
import UIKit

// MARK: - 设置View frame
extension UIView {
    var Kwidth: CGFloat {
        get{
            return self.frame.width
        }
        set{
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var Kheight: CGFloat {
        get{
            return self.frame.height
        }
        set{
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var Kx: CGFloat {
        get{
            return self.frame.origin.x
        }
        set{
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var Ky: CGFloat {
        get{
            return self.frame.origin.y
        }
        set{
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var KcenterX: CGFloat {
        get{
            return self.center.x
        }
        set{
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    var KcenterY: CGFloat {
        get{
            return self.center.y
        }
        set{
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
    var Ksize: CGSize {
        
        get{
            return self.frame.size
        }
        set{
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
}

// MARK: - 获取 View 所在控制器
extension UIView {
    //所在的控制器
    var KparentVC: UIViewController?{
        get{
            var responder = self.next
            while (responder != nil) {
                if(responder?.isKind(of: UIViewController.self))!{
                    
                    return responder as? UIViewController
                }else{
                    responder = responder?.next
                }
            }
            return nil;
            
        }
        set{
            
        }
    }
}

// MARK: - 设置View圆角,边框,边框颜色
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get{
            return self.layer.cornerRadius
        }
        set{
            self.layer.cornerRadius  = newValue;
            self.layer.masksToBounds = true;
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get{
            return UIColor.init(cgColor: layer.borderColor ?? UIColor.white.cgColor)
        }
        set{
            self.layer.borderColor  = newValue.cgColor;
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get{
            return self.layer.borderWidth
        }
        set{
            self.layer.borderWidth  = newValue;
        }
    }
}

// MARK: - 将View内容截图返回
extension UIView {
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

// MARK: - 部分圆角
extension UIView {
    /// 部分圆角
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}


let cmButtonAssociatedkey = UnsafeRawPointer.init(bitPattern: "cmButtonAssociatedkey".hashValue)
extension UIButton {
    func addAction(for controlEvents: UIControl.Event,action:@escaping (UIButton)->()) {
        objc_setAssociatedObject(self, cmButtonAssociatedkey!, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(cmButtonClick), for: controlEvents)
    }

    func addAction(_ action:@escaping (UIButton)->()) {
        objc_setAssociatedObject(self, cmButtonAssociatedkey!, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(cmButtonClick), for: .touchUpInside)
    }

    @objc func cmButtonClick() {
        if let action = objc_getAssociatedObject(self, cmButtonAssociatedkey!) as? (UIButton)->() {
            action(self)
        }
    }
}

