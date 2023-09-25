//
//  PhotoModel.swift
//  QRPDFScanner
//
//  Created by nge0131 on 2023/9/20.
//  Copyright © 2023 zsy. All rights reserved.
//

import UIKit
import Photos

// MARK: - 对获取的照片封装后的Model
class PhotoModel {
    var identifer:String = ""
    var asset:PHAsset = PHAsset()
    var dataSize:Int = 0
    var hashString:String?
    var selected:Bool = false
    var data: Data? // 原图数据
    init(identifer: String, asset: PHAsset, dataSize: Int, hashString: String? = nil, selected: Bool = false, data: Data? = nil) {
        self.identifer = identifer
        self.asset = asset
        self.dataSize = dataSize
        self.hashString = hashString
        self.selected = selected
        self.data = data
    }
}
