//
//  PhotoCleanerVC.swift
//  QRPDFScanner
//
//  Created by nge0131 on 2023/9/12.
//  Copyright © 2023 zsy. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import Then
import Photos

// MARK: - 照片清理详情页
class PhotoCleanerVC: UIViewController {
    // MARK: - model
    
    var photoModelList: [PhotoModel] = []
    
    /// 照片左右距离view内距
    let photoLeftRightInset: CGFloat = 16
    
    /// 照片覆盖的缩小比例
    let zoomScale: CGFloat = 0.95
    
    /// 照片覆盖上下偏移距离
    let photoViewOffset: CGFloat = 6
    
    /// 照片容器视图的高度值
    let photoContentHeight: CGFloat = kScreenH - (navigationHeight + 15 + tabBarHeight + 20)
    
    // MARK: - view
    
    lazy var photoContentView: PhotoContentView = {
        let contentView = PhotoContentView(dataSource: self, delegate: self, zoomScale: zoomScale, photoLeftRightInset: photoLeftRightInset, photoViewOffset: photoViewOffset, photoContentHeight: photoContentHeight)
        
        return contentView
    }()
    
    let removeButton = UIButton().then {
        $0.setBackgroundImage(UIImage.getImageWithColor(color: UIColor(0x2A2A2A)), for: .normal)
        $0.setBackgroundImage(UIImage.drawPortraitLinearGradient(startColor: UIColor(0xFE5196), endColor: UIColor(0xF77062), size: CGSize(width: 96, height: 40)), for: .highlighted)
        $0.setImage(R.image.ic_remove(), for: .normal)
        $0.setImage(R.image.ic_remove()?.changeColor(.white), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    let shareButton = UIButton().then {
        $0.setBackgroundImage(UIImage.getImageWithColor(color: UIColor(0x2A2A2A)), for: .normal)
        $0.setBackgroundImage(UIImage.getImageWithColor(color: UIColor(0xFFD700)), for: .highlighted)
        $0.setImage(R.image.ic_share(), for: .normal)
        $0.setImage(R.image.ic_share()?.changeColor(.white), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    let saveButton = UIButton().then {
        $0.setBackgroundImage(UIImage.getImageWithColor(color: UIColor(0x2A2A2A)), for: .normal)
        $0.setBackgroundImage(UIImage.drawPortraitLinearGradient(startColor: UIColor(0x16D9E3), endColor: UIColor(0x46AEF7), size: CGSize(width: 96, height: 40)), for: .highlighted)
        $0.setImage(R.image.ic_save(), for: .normal)
        $0.setImage(R.image.ic_save()?.changeColor(.white), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    let countingLabel = UILabel().then {
        $0.text = "0/0"
        $0.textColor = .white
        $0.font = UIFont.customFont(size: 24, weight: "Demi Bold")
        $0.textAlignment = .right
    }
    
    deinit {
        saveButton.layer.removeAllAnimations()
        removeButton.layer.removeAllAnimations()
        
    }
    
    
}

// MARK: - 生命周期
extension PhotoCleanerVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        configNaviBar()
        configUI()
        
        addBlock()
        
        configData()
        
        addClickAction()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
}

// MARK: - UI
extension PhotoCleanerVC {
    func configNaviBar() {
        self.navigationItem.title = "Photo cleanup"
    }
    
    func configUI() {
        
        view.addSubview(photoContentView)
        
        view.addSubview(removeButton)
        view.addSubview(shareButton)
        view.addSubview(saveButton)
        view.addSubview(countingLabel)
        
        addSubViewsLayout()
    }
    
    private func addSubViewsLayout() {
        photoContentView.snp.makeConstraints {
            $0.top.equalTo(navigationHeight + 15)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(-(tabBarHeight + 20))
        }
        
        // 底部三个按钮的宽度
        let everyBottomBtnWidth: CGFloat = (kScreenW - (photoLeftRightInset + 20 + 8) * 2) / 3
        removeButton.snp.makeConstraints {
            $0.bottom.equalTo(photoContentView).offset(-15)
            $0.width.equalTo(everyBottomBtnWidth)
            $0.height.equalTo(everyBottomBtnWidth * 40 / 96)
            $0.right.equalTo(shareButton.snp.left).offset(-8)
        }
        shareButton.snp.makeConstraints {
            $0.width.equalTo(everyBottomBtnWidth)
            $0.height.equalTo(everyBottomBtnWidth * 40 / 96)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(removeButton)
        }
        saveButton.snp.makeConstraints {
            $0.width.equalTo(everyBottomBtnWidth)
            $0.height.equalTo(everyBottomBtnWidth * 40 / 96)
            $0.centerY.equalTo(removeButton)
            $0.left.equalTo(shareButton.snp.right).offset(8)
        }
        
        countingLabel.snp.makeConstraints {
            $0.bottom.equalTo(shareButton.snp.top).offset(-8)
            $0.right.equalTo(-(20 + photoLeftRightInset))
        }
        
    }
    
}

// MARK: - 功能方法
extension PhotoCleanerVC {
    
    /// 初始获取数据
    func configData() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized{
            self.async_getAllPhotosData()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { authStatus in
                if authStatus == .authorized {
                    self.async_getAllPhotosData()
                }
            }
        } else {
            // denied
            print("**** 拒绝访问照片权限 ****")
        }
    }
    private func async_getAllPhotosData() {
        DispatchQueue.global().async {
            PhotoCleanerManager.shared.getAllPhotos()
        }
    }
    
    
    /// 刷新数据
    func refreshData() {
        self.photoModelList = PhotoCleanerManager.shared.allPhotos
        
        self.photoContentView.reloadView(withAnimation: true)
        self.photoContentView.reloadData()
        
        var currentIndex = photoContentView.getCurrentPhotoIndex()
        if self.numberOfPhotos(view: photoContentView) != 0 {
            currentIndex += 1
        }
        self.countingLabel.text = "\(currentIndex)/\(self.numberOfPhotos(view: photoContentView))"
    }
    
    func addBlock() {
        
        /// 数据加载完成执行该闭包
        PhotoCleanerManager.shared.photosDataLoadSuccessBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 加载数据
                self.photoModelList = PhotoCleanerManager.shared.allPhotos
                self.photoContentView.reloadData()
                
                var currentIndex = self.photoContentView.getCurrentPhotoIndex()
                if self.numberOfPhotos(view: self.photoContentView) != 0 {
                    currentIndex += 1
                }
                self.countingLabel.text = "\(currentIndex)/\(self.numberOfPhotos(view: self.photoContentView))"
            }
        }
        
            
    }
    
    private func removeBtnAnimation() {
        self.removeButton.isHighlighted = true
    }
    
    private func saveBtnAniamtion() {
        self.saveButton.isHighlighted = true
        
    }
    
    private func removeBtnRestoreAnimation() {
        if self.removeButton.isHighlighted {
            self.removeButton.isHighlighted = false
        }
    }
    
    private func saveBtnRestoreAnimation() {
        if self.saveButton.isHighlighted {
            self.saveButton.isHighlighted = false
        }
    }
    
    private func updateCountingLabel() {
        let currentIndex = photoContentView.getCurrentPhotoIndex()
        
        self.countingLabel.text = "\(currentIndex + 1 + 1)/\(self.numberOfPhotos(view: photoContentView))"
    }
    
}

// MARK: - 动画
extension PhotoCleanerVC {
    
}

// MARK: - 点击事件
extension PhotoCleanerVC {
    func addClickAction() {
        
        removeButton.addClickAction { [weak self] sender in
            guard let self = self else { return }
            sender.isUserInteractionEnabled = false
            self.photoContentView.clickPhotoViewMoveHandle(withDirection: false)
            
            // 数据赋值
            let currentIndex = self.photoContentView.getCurrentPhotoIndex()
            self.photoModelList[currentIndex].selected = true
        }
        
        shareButton.addClickAction { [weak self] sender in
            guard let self = self else { return }
            // 分享操作
            let index = photoContentView.getCurrentPhotoIndex()
            
            let model = self.photoModelList[index]
            
            guard let data = model.data else { return }
            
            let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            
            self.present(activityVC, animated: true)
            
        }
        
        saveButton.addClickAction { [weak self] sender in
            guard let self = self else { return }
            sender.isUserInteractionEnabled = false
            self.photoContentView.clickPhotoViewMoveHandle(withDirection: true)
            
            // 数据赋值
            let currentIndex = self.photoContentView.getCurrentPhotoIndex()
            self.photoModelList[currentIndex].selected = false
        }
        
    }
        
}

extension PhotoCleanerVC: PhotoContentViewDataSource {
    
    func numberOfVisiblePhotos(view: PhotoContentView) -> Int {
        return 4
    }
    
    func numberOfPhotos(view: PhotoContentView) -> Int {
        return self.photoModelList.count
    }
    
    func loadStartShowData(view: PhotoContentView, photoForIndex index: Int) -> PhotoModel? {
        if index < self.photoModelList.count {
            return self.photoModelList[index]
        } else {
            return nil
        }
    }
    
}

extension PhotoCleanerVC: PhotoContentViewDelegate {
    
    func photoDragging(view: PhotoContentView, dragAllDistance allDistance: CGFloat, photoViewDragDistance centerDistance: CGFloat, dragDirection isRightDirection: Bool) {
        // 按钮背景动画
        let draggingPercent = centerDistance / allDistance
        if isRightDirection {
            // save
            self.saveButton.transform = CGAffineTransformMakeScale(1 - 0.1 * draggingPercent, 1 - 0.05 * draggingPercent)
            self.saveBtnAniamtion()
            self.removeBtnRestoreAnimation()
            
        } else {
            // remove
            self.removeButton.transform = CGAffineTransformMakeScale(1 - 0.1 * draggingPercent, 1 - 0.05 * draggingPercent)
            self.removeBtnAnimation()
            self.saveBtnRestoreAnimation()
        }
        
    }
    
    func photoSupportDrag(view: PhotoContentView, dragDirection isRightDirection: Bool) -> Bool {
        return true
    }
    
    func photoDragEndRestore(view: PhotoContentView, draggedDirection isRightDirection: Bool) {
        
        if isRightDirection {
            self.saveButton.transform = .identity
            self.saveBtnRestoreAnimation()
        } else {
            self.removeButton.transform = .identity
            self.removeBtnRestoreAnimation()
        }
        
    }
    
    func photoDragEnd(view: PhotoContentView, indexForPhoto photoIndex: Int, dragDirection isRightDirection: Bool) {
        view.hideDetailView(index: photoIndex)
        
        // 数据赋值
        if isRightDirection {
            // 保存
            if photoIndex < self.photoModelList.count {
                self.updateCountingLabel()
                self.photoModelList[photoIndex].selected = false
            }
            
            self.saveButton.isUserInteractionEnabled = true
            self.saveButton.transform = .identity
            self.saveBtnRestoreAnimation()
            
        } else {
            // 删除
            if photoIndex < self.photoModelList.count {
                self.updateCountingLabel()
                self.photoModelList[photoIndex].selected = true
            }
            
            self.removeButton.isUserInteractionEnabled = true
            self.removeButton.transform = .identity
            self.removeBtnRestoreAnimation()
        }
        
    }
    
    /// 加载数据
    func loadBottomPhotoData(view: PhotoContentView, photoView: PhotoCellView, photoForIndex index: Int) {
        if index < self.photoModelList.count {
            photoView.photoModel = self.photoModelList[index]
        }
    }
    
    /// 跳转到自定义页面,对左右滑动的结果做处理
    func photoDragEndIsLastPhoto(view: PhotoContentView) {
        // 跳转到照片列表页
        let photoListVC = UIViewController()
        photoListVC.view.backgroundColor = .green
        
//        photoListVC.backActionBlock = { [weak self] in
//            guard let self = self else { return }
//            self.refreshData()
//        }
        
        self.navigationController?.pushViewController(photoListVC, animated: true)
    }
    
    func didSelectCell(view: PhotoContentView, at index: Int) {}
    
    
}
