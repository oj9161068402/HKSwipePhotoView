//
//  Configs.swift
//  CleanBlocker
//
//  Created by zsy on 2023/3/31.
//

import Foundation
import UIKit


let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height

public let kScreen = UIScreen.main.bounds
public let kScale = Int(UIScreen.main.scale)

public let myAppDelegate = UIApplication.shared.delegate

/// 适配系数-宽 以6为标准
public let scaleWidth : CGFloat = kScreenW / 375.0

/// 适配系数-高 以6为标准
public let scaleHeight : CGFloat = kScreenH / 667.0

public let kWindow = UIApplication.shared.keyWindow!

public let statusBarHeight = UIApplication.shared.statusBarFrame.height;

//导航栏高度
public let navigationHeight = CGFloat(statusBarHeight + 44)

//tabbar高度
public let tabBarHeight = CGFloat( 50) + (kISIPhoneX ? 60 : 21)


//顶部的安全距离
public let topSafeAreaHeight = CGFloat(statusBarHeight - 20)

//底部的安全距离
public let bottomSafeAreaHeight = CGFloat(tabBarHeight - 49)

// MARK: 闭包
public typealias ClickBlockVoid = ()->()


/// iPhoneX 系列机型
let kISIPhoneX = kScreenW >= 375 && kScreenH >= 812 && (UIDevice.current.systemVersion as NSString).floatValue >= Float(11.0) && !(UIDevice.current.model as NSString).isEqual(to: "iPad")

//适配iPhoneX
//获取状态栏的高度，全面屏手机的状态栏高度为44pt，非全面屏手机的状态栏高度为20pt
//状态栏高度
let iPhoneX = statusBarHeight == 44 ? true : false


@objc class ScreenInfo: NSObject {
    @objc func getNavigationHeight() -> CGFloat{
        return navigationHeight
    }
}

func fileSize1024ToString(fileSize:Int64) -> String {
    
    let fileSize1 = CGFloat(fileSize)
    
    let KB:CGFloat = 1024
    let MB:CGFloat = KB*KB
    let GB:CGFloat = MB*KB
    
    if fileSize < 10 {
        return "0 B"
        
    } else if fileSize1 < KB {
        return "< 1 KB"
    } else if fileSize1 < MB {
        return String(format: "%.1f KB", CGFloat(fileSize1)/KB)
    } else if fileSize1 < GB {
        return String(format: "%.1f MB", CGFloat(fileSize1)/MB)
    } else {
        return String(format: "%.1f GB", CGFloat(fileSize1)/GB)
    }
}
