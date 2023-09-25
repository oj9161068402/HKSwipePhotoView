//
//  PhotoCleanerManager.swift
//  QRPDFScanner
//
//  Created by nge0131 on 2023/9/20.
//  Copyright © 2023 zsy. All rights reserved.
//

import Foundation
import Photos

// MARK: - 照片清理方法的管理类
class PhotoCleanerManager: NSObject {
    
    static let shared = PhotoCleanerManager()
    
    var allPhotos: [PhotoModel] = [PhotoModel]()
    
    var photosDataLoadSuccessBlock: ClickBlockVoid?
    
    typealias PhotoDeleteBlock = (Bool) -> Void
    
    /// 获取所有照片
    func getAllPhotos() {
        self.allPhotos.removeAll()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: options)
        for i in 0..<result.count {
            autoreleasepool {
                let asset = result[i]
                if asset.mediaType == .image  {
                    
                    let imageOptions = PHImageRequestOptions.init()
                    imageOptions.version = PHImageRequestOptionsVersion.current
                    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                    imageOptions.isSynchronous = true
                    PHImageManager.default().requestImageDataAndOrientation(for: asset, options: imageOptions) { data, str, ori, info in
                        if let uwrapdata = data { //有data才有资格进入array
                            
                            let photoModel = PhotoModel(identifer: asset.localIdentifier, asset: asset,dataSize: uwrapdata.count, data: data)
                            
                            self.allPhotos.append(photoModel)
                            
//                            print("*******uwrapdata: \(uwrapdata); uwrapdata.count: \(uwrapdata.count)")
                        }
                    }
                    
                }
            }
        }
        
        self.photosDataLoadSuccessBlock?()
    }
    
    
    /// 删除选中的照片
    func deletePhotos(assets: [PHAsset], successBlock: PhotoDeleteBlock?) {
        ApplicationContext.shared.JumpThisTime = true
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    for j in 0..<assets.count{
                        PhotoCleanerManager.shared.allPhotos.removeAll { photoImage in
                            return photoImage.asset.localIdentifier == assets[j].localIdentifier
                        }
                    }
                    successBlock?(true)
                    
                }
                else{
                    successBlock?(false)
                }
            }
        })
        
        
        
    }
    
    
    
}
