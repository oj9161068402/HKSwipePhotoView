//
//  PhotoCellView.swift
//  QRPDFScanner
//
//  Created by nge0131 on 2023/9/13.
//  Copyright © 2023 zsy. All rights reserved.
//

import UIKit
import Then
import Photos

// MARK: - 照片子视图
class PhotoCellView: UIView {
    
    // MARK: - model
    
    /// 当前照片的数据集索引
    var index: Int = 0 {
        didSet {
//            print("第\(index)张")
        }
    }
    
    var photoModel: PhotoModel? {
        didSet {
            if let photoModel = photoModel, let data = photoModel.data {
                
                self.photoImageView.image = UIImage(data: data)
                
                // 更新详情信息
                let sizeString = fileSize1024ToString(fileSize: Int64(photoModel.dataSize))
                let createDate = photoModel.asset.creationDate ?? Date()
                let locationString = photoModel.asset.location == nil ? "" : "at\n  \(photoModel.asset.location!)"
                
                detailLabel.text = "  Photo Details: this image is\n  \(sizeString)\n  and was created on\n  \(createDate)\n  \(locationString)"
                
            } else {
                self.photoImageView.image = R.image.pic_empty()
            }
        }
    }
    
    
    let animationViewWidth: CGFloat = 60
    
    // MARK: - view
    var removeAnimationView: PhotoBtnAnimationView?
    
    var saveAnimationView: PhotoBtnAnimationView?
    
    let photoImageView = UIImageView().then {
        $0.image = R.image.pic_empty()
        $0.contentMode = .scaleAspectFill
    }
    
    let detailButton = UIButton().then {
        $0.setImage(R.image.ic_xiangqing(), for: .normal)
        $0.setImage(R.image.ic_xiangqing()?.changeColor(UIColor(0x2A2A2A)), for: .highlighted)
    }
    
    let detailLabel = UILabel().then {
        $0.text = ""
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 18, weight: "Medium")
        $0.textColor = .white
        $0.backgroundColor = UIColor(0x2A2A2A).withAlphaComponent(0.5)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.numberOfLines = 0
        $0.isHidden = true
        $0.adjustsFontSizeToFitWidth = true
    }
    
    init(frame: CGRect, width: CGFloat, height: CGFloat) {
        super.init(frame: frame)
        
        photoImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        detailButton.frame = CGRect(x: width - 22 - 28, y: 22, width: 28, height: 28)
        detailLabel.frame = CGRect(x: 0, y: height * 0.6, width: width, height: height * 0.4)
        
        
        let image = UIImage.drawPortraitLinearGradient(startColor: .clear, endColor: .black, size: CGSizeMake(width, height * 0.2))
        let gradientImageView = UIImageView(frame: CGRect(x: 0, y: height * (1 - 0.2), width: width, height: height * 0.2))
        gradientImageView.image = image
        gradientImageView.contentMode = .scaleAspectFill
        
        self.layer.cornerRadius = 24
        self.layer.masksToBounds = true
        detailButton.addClickEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        self.addSubview(photoImageView)
        self.addSubview(gradientImageView)
        self.addSubview(detailButton)
        self.addSubview(detailLabel)
        
        detailButton.addClickAction { [weak self] sender in
            guard let self = self else { return }
            
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                // 显示详情视图并隐藏按钮
                
                self.showDetailView()
            } else {
                // 移除视图
                
                self.hideDetailView()
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showDetailView() {
        detailLabel.isHidden = false
    }
    
    func hideDetailView() {
        detailLabel.isHidden = true
    }
    
    func addAnimationViews(frameWidth: CGFloat) {
        if self.removeAnimationView == nil || self.saveAnimationView == nil {
            let removeAnimationView = PhotoBtnAnimationView(frame: CGRect(x: frameWidth - 25 - animationViewWidth, y: 25, width: animationViewWidth, height: animationViewWidth), imageName: "ic_remove")
            let saveAnimationView = PhotoBtnAnimationView(frame: CGRect(x: 25, y: 25, width: animationViewWidth, height: animationViewWidth), imageName: "ic_save")
            
            self.removeAnimationView = removeAnimationView
            self.saveAnimationView = saveAnimationView
        }
        
        
        self.addSubview(self.removeAnimationView!)
        self.addSubview(self.saveAnimationView!)
    }
    
    /// 左右拖拽结束后移除子视图
    func removeAnimationViews() {
        self.removeAnimationView?.removeFromSuperview()
        self.saveAnimationView?.removeFromSuperview()
        
        self.removeAnimationView?.hideAnimationViews()
        self.saveAnimationView?.hideAnimationViews()
    }
    
}


// MARK: - 功能方法
extension PhotoCellView {
    
    /// 拖拽中处理 centerDistance已取绝对值
    func draggingHandle(distance centerDistance: CGFloat, dragingDirection isRightDirection: Bool) {
        
        if isRightDirection {
            //save
            self.saveAnimationView?.showAnimationView(allDistance: frame.size.width / 2, distance: centerDistance)
            
        } else {
            //remove
            self.removeAnimationView?.showAnimationView(allDistance: frame.size.width / 2, distance: abs(centerDistance))
            
        }
        
    }
    
    /// 拖拽结束还原后处理
    func dragEndRestoreHandle(draggedDirection isRightDirection: Bool) {
        if isRightDirection {
            saveAnimationView?.hideAnimationViews()
        } else {
            removeAnimationView?.hideAnimationViews()
        }
        
    }
    
    /// 左右拖拽完成
    func dragEndHandle() {
        self.removeAnimationViews()
    }
    
    
}
