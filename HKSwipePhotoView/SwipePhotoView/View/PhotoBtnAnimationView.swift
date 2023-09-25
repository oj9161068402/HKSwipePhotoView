//
//  PhotoBtnAnimationView.swift
//  QRPDFScanner
//
//  Created by nge0131 on 2023/9/18.
//  Copyright © 2023 zsy. All rights reserved.
//

import UIKit
import Then

// MARK: - 照片在拖拽时随着拖拽距离显示的动画按钮视图
class PhotoBtnAnimationView: UIView {
    
    let iconImageView = UIImageView(frame: .zero)
    
    init(frame: CGRect, imageName: String) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = frame.width / 2
        
        self.addSubview(iconImageView)
        
        iconImageView.image = UIImage(named: imageName)
        iconImageView.frame.size = CGSize(width: frame.size.width / 2, height: frame.size.height / 2)
        iconImageView.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        self.alpha = 0
        self.transform = CGAffineTransformMakeScale(0.6, 0.6)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 手势距离动画显示
    func showAnimationView(allDistance: CGFloat, distance centerDistance: CGFloat) {
        let percent = (centerDistance / allDistance) > 1 ? 1.0 : centerDistance / allDistance
        self.alpha = percent
        self.transform = CGAffineTransformMakeScale(percent > 0.6 ? percent : 0.6, percent > 0.6 ? percent : 0.6)
    }
    
    // 手势距离动画隐藏(自动还原时 或者 左右拖拽)
    func hideAnimationViews() {
        self.alpha = 0
        self.transform = CGAffineTransformMakeScale(0.6, 0.6)
    }
    
}
