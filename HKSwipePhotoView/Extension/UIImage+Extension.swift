//
//  UIImage+Extension.swift
//  QRPDFScanner
//
//  Created by zsy on 2023/5/15.
//  Copyright © 2023 zsy. All rights reserved.
//

import UIKit
import Foundation


extension  UIImage  {
    
    /// 原图
    func Original() -> UIImage {
        return self.withRenderingMode(.alwaysOriginal)
    }
    
    func scaleToSize(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    //二分压缩法
    func compressImageMid(maxLength: Int) -> Data? {
        var compression: CGFloat = 1
        
        guard var data = self.pngData() else { return nil }
        if data.count < maxLength {
            return data
        }
        print("压缩前kb", data.count / 1024, "KB")
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        
        
//        var resultImage: UIImage = UIImage(data: data)!
        if data.count < maxLength {
            return data
        }
        return data
    }
    
    func compressImageOnlength(maxLength: Int) -> Data? {
        guard let vData = self.pngData() else { return nil }
        if vData.count <= maxLength {
            return vData
        }
        var compress:CGFloat = 0.9
        guard var data = self.jpegData(compressionQuality: compress) else { return nil }
        while data.count > maxLength && compress > 0.01 {
            compress -= 0.02
            data = self.jpegData(compressionQuality: compress)!
        }
        return data
    }
    
    
    
    // 给定指定宽度，返回结果图像
        func scaleImageToWidth(_ width: CGFloat) -> UIImage {

            // 1. 计算等比例缩放的高度
            let height = width * size.height / size.width

            // 2. 图像的上下文
            let s = CGSize(width: width, height: height)

            // 3.提示：一旦开启上下文，所有的绘图都在当前上下文中
            UIGraphicsBeginImageContext(s)

            // 4.在制定区域中缩放绘制完整图像
            draw(in: CGRect(origin: CGPoint.zero, size: s))

            // 5. 获取绘制结果
            let result = UIGraphicsGetImageFromCurrentImageContext()

            // 6. 关闭上下文
            UIGraphicsEndImageContext()

            // 7. 返回结果
            return result!
        }
    
    /// 改变图片颜色
    /// - Parameter color: 改变后的颜色
    @objc func changeColor(_ color:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)//kCGBlendModeNormal
        context?.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!);
        color.setFill()
        context?.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /// 根据颜色生成图片
    static func getImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /// 绘纵向渐变
    /// - Parameter startColor: 开始颜色
    /// - Parameter endColor: 结束颜色
    /// - Parameter size: 尺寸
    class func drawPortraitLinearGradient(startColor: UIColor, endColor: UIColor, size: CGSize) -> UIImage {
        
        //创建CGContextRef
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 0))
        path.addLine(to: CGPoint.init(x: 0, y: size.height))
        path.addLine(to: CGPoint.init(x: size.width, y: size.height))
        path.addLine(to: CGPoint.init(x: size.width, y: 0))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = [CGFloat(0.0), CGFloat(1.0)]
        let colors = [startColor.cgColor, endColor.cgColor]
        let gradient = CGGradient.init(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        
        let pathRect: CGRect = path.cgPath.boundingBox
        
        //具体方向可根据需求修改
        let startPoint = CGPoint.init(x: pathRect.minX, y: pathRect.minY)
        let endPoint = CGPoint.init(x: pathRect.minX, y: pathRect.maxY)
        
        context?.saveGState()
        context?.addPath(path.cgPath)
        context?.clip()
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context?.restoreGState()
        //获取绘制的图片
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
}

