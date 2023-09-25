//
//  ApplicationContext.swift
//  QRPDFScanner
//
//  Created by zsy on 2023/7/4.
//  Copyright © 2023 zsy. All rights reserved.
//

import Foundation
@objcMembers
class ApplicationContext : NSObject{
    static public let shared = ApplicationContext()

    var JumpThisTime = false
}
