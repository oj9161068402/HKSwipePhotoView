//
//  PhotoContentView.swift
//  QRPDFScanner
//
//  Created by nge0131 on 2023/9/13.
//  Copyright © 2023 zsy. All rights reserved.
//

import UIKit
import Then

// MARK: - 滑动位置
enum PanDragStatus: Int {
    case defaultValue = 0
    case topLeft = 1
    case topRight = 2
    case bottomLeft = 3
    case bottomRight = 4
}

// MARK: - dataSource
protocol PhotoContentViewDataSource: NSObjectProtocol {
    /// 照片数量
    func numberOfPhotos(view: PhotoContentView) -> Int
    
    /// 覆盖显示的照片数
    func numberOfVisiblePhotos(view: PhotoContentView) -> Int
    
    /// 返回初始展示的照片数据
    func loadStartShowData(view: PhotoContentView, photoForIndex index: Int) -> PhotoModel?
    
}

// MARK: - delegate
@objc protocol PhotoContentViewDelegate: NSObjectProtocol {
    
    /// 当拖拽时的代理 参数：传递拖拽的水平距离和水平方向(已取绝对值)
    func photoDragging(view: PhotoContentView, dragAllDistance allDistance: CGFloat, photoViewDragDistance centerDistance: CGFloat, dragDirection isRightDirection: Bool)
    
    /// 拖拽结束时检查是否支持拖拽
    func photoSupportDrag(view: PhotoContentView, dragDirection isRightDirection: Bool) -> Bool
    
    /// 拖拽移动后还原的代理方法
    func photoDragEndRestore(view: PhotoContentView, draggedDirection isRightDirection: Bool)
    
    /// 左右拖拽完成后的代理方法
    func photoDragEnd(view: PhotoContentView, indexForPhoto photoIndex: Int, dragDirection isRightDirection: Bool)
    
    /// 没有更多数据去显示在空白视图上
    @objc optional func noDataLoadInBottomPhotoView(view: PhotoContentView)
    
    /// 拖拽结束且当前的照片是最后一张照片
    func photoDragEndIsLastPhoto(view: PhotoContentView)
    
    
    func loadBottomPhotoData(view: PhotoContentView, photoView: PhotoCellView, photoForIndex index: Int)
    
    /// 点击当前照片事件的代理方法
    @objc optional func didSelectCell(view: PhotoContentView, at index: Int)
    
}


/**
 类似于UITableView、UICollectionView的代理模式和原理
 实现左右滑动可复用视图的效果（类似于探探等交友软件）
 */
// MARK: - 内存池存储一定数量的cell (对左右滑动照片的封装)
class PhotoContentView: UIView {
    
    var dataSource: PhotoContentViewDataSource?
    
    var delegate: PhotoContentViewDelegate?
    
    
    // MARK: - model
    
    /// 重叠照片数量不超过5
    private let maxVisiPhotosCount: Int = 5
    
    /// 照片折叠时的缩放比例
    private var zoomScale: CGFloat
    
    /// 最上面的照片左右边距
    private var photoLeftRightInset: CGFloat
    
    /// 照片容器视图的宽度值
    private var photoContentWidth: CGFloat
    
    /// 照片容器视图的高度值
    private let photoContentHeight: CGFloat
    
    /// 照片之间上下偏移
    private var photoViewOffset: CGFloat
    
    private var photoWidth: CGFloat
    
    private var photoHeight: CGFloat
    
    
    
    // MARK: - 常用参数      // centerPoint cellFrame
    /// 当前展示的照片在数据列表中的索引位置
    private var currentIndex: Int = 0
    
    /// 底部卡片在数据列表中的索引位置
    private var lastIndex: Int = 0
    
    /// 记录拖拽手势开始位置:左上、左下、右上、右下
    private var panPositionDirection: PanDragStatus = .defaultValue
    
    /// 旋转角度
    private let rotationAngle = Double.pi / 8
    
    private let maxVelocityValue: CGFloat = 400
    
    private let rotationMaxValue: CGFloat = 1
    
    private var xFromCenter: CGFloat = 0
    private var yFromCenter: CGFloat = 0
    
    /// 存储照片视图的中心点
    private var photoView_CenterPoint: CGPoint = .zero
    
    /// 存储照片视图的尺寸
    private var photoView_FrameRect: CGRect = .zero
    
    
    // MARK: - view
    /// 存储cell视图的内存池
    private var photoViewsPool: NSMutableArray = []
    
    
    init(dataSource: PhotoContentViewDataSource,
         delegate: PhotoContentViewDelegate?,
         zoomScale: CGFloat,
         photoLeftRightInset: CGFloat,
         photoViewOffset: CGFloat,
         photoContentHeight: CGFloat
    ) {
        
        self.dataSource = dataSource
        self.delegate = delegate
        self.zoomScale = zoomScale
        self.photoLeftRightInset = photoLeftRightInset
        self.photoViewOffset = photoViewOffset
        self.photoContentHeight = photoContentHeight
        
        self.photoContentWidth = kScreenW - photoLeftRightInset * 2
        self.photoWidth = .zero
        self.photoHeight = .zero
        
        super.init(frame: .zero)
        
        self.photoWidth = photoContentWidth
        // 本身只-1，但是最后一个和顶部对齐没有上移
        self.photoHeight = photoContentHeight - photoViewOffset * CGFloat((self.dataSource!.numberOfVisiblePhotos(view: self) > maxVisiPhotosCount ? (maxVisiPhotosCount - 1 - 1) : (self.dataSource!.numberOfVisiblePhotos(view: self) - 1 - 1)))
        
        
        configUI()
        
        
        addClickAction()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

// MARK: - UI
extension PhotoContentView {
    func configUI() {
        
        addPhotoViewsInContentView()
        
    }
    
    /// 添加照片视图
    private func addPhotoViewsInContentView() {
        if self.dataSource == nil || self.dataSource?.numberOfVisiblePhotos(view: self) == 0 {
            return
        }
        
        var visiblePhotosCount = self.dataSource!.numberOfVisiblePhotos(view: self)
        if visiblePhotosCount > self.maxVisiPhotosCount {
            visiblePhotosCount = self.maxVisiPhotosCount
        }
        
        // 索引赋值
        self.currentIndex = 0
        self.lastIndex = visiblePhotosCount - 1
        
        // 添加视图到内存池
        for i in 0..<visiblePhotosCount {
            let photoView = PhotoCellView(frame: .zero, width: photoWidth, height: photoHeight)
            
            photoView.index = i
            
            photoView.backgroundColor = .black
            
            // 添加拖拽手势
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
            photoView.addGestureRecognizer(pan)
            // 添加点击手势
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_:)))
            photoView.addGestureRecognizer(tap)
            
            self.photoViewsPool.add(photoView)
            self.addSubview(photoView)
            self.sendSubviewToBack(photoView)
            
            /**
             逻辑：n张照片按照n-1张照片计算
             y坐标:
             宽度缩小比例:
             */
            
            /// 最后一张图片的位置和尺寸和上一张一致
            var index = i
            if i == visiblePhotosCount - 1 {
                index = i - 1
            }
            
            // 去除掉底部被遮挡的那张照片的剩余个数
            let offset_visiblePhotosCount = visiblePhotosCount - 1
            
            // 4
            // 3 - 1 - 0
            // 3 - 1 - 1
            // 3 - 1 - 2
            // 3 - 1 - 2
            let reverseIndex: CGFloat = CGFloat(offset_visiblePhotosCount - 1 - index)
            
            photoView.frame.size = CGSize(width: photoWidth, height: photoHeight)
            photoView.center.x = kScreenW / 2
            photoView.frame.origin.y = photoViewOffset * reverseIndex
            photoView.transform = CGAffineTransformMakeScale(pow(zoomScale, CGFloat(index)), 1.0)
            
            photoView.isUserInteractionEnabled = false
            if i == 0 {
                photoView.isUserInteractionEnabled = true
                
                let centerPoint = self.getPhotoView_CenterPoint(photoView: photoView)
                if self.photoView_CenterPoint == .zero {
                    self.photoView_CenterPoint = centerPoint
                }
                
                if photoView_FrameRect == .zero {
                    self.photoView_FrameRect = photoView.frame
                }
                
//                print("******* centerPoint: \(centerPoint); frameRect: \(photoView_FrameRect) ****")
                
                photoView.addAnimationViews(frameWidth: photoWidth)
            }
        }
        
    }
    
    
}

// MARK: - 功能方法
extension PhotoContentView {
    
    /// 配置初始照片数据 (异步加载数据导致单独设置数据)
    func reloadData() {
        // 配置初始数据
        guard let photoViews = self.photoViewsPool as? [PhotoCellView] else { return }
        for photoView in photoViews {
            photoView.photoModel = self.receiveDataSourceLoadStartShowData(photoForIndex: photoView.index)
        }
    }
    
    /// 刷新照片数据以及视图 (点击分类时)
    func reloadView(withAnimation animated: Bool) {
        /**
         1. 前提：照片数据外部先刷新了
         2. 刷新视图
         3. 重置修改的属性
         */
        
        let subViewsCount = self.subviews.count
        for i in 0..<subViewsCount {
            self.subviews[i].removeFromSuperview()
        }
        
        self.photoViewsPool.removeAllObjects()
        
        self.photoView_CenterPoint = .zero
        self.photoView_FrameRect = .zero
        
        addPhotoViewsInContentView()
    }
    
    /// 获取初始时实际的可见视图个数
    private func getVisiblePhotosCount() -> Int {
        if self.dataSource == nil || self.dataSource?.numberOfVisiblePhotos(view: self) == 0 {
            return 0
        }
        
        var visiblePhotosCount = self.dataSource!.numberOfVisiblePhotos(view: self)
        if visiblePhotosCount > self.maxVisiPhotosCount {
            visiblePhotosCount = self.maxVisiPhotosCount
        }
        
        return visiblePhotosCount
    }
    
    /// 获取顶部照片的中心位置
    private func getPhotoView_CenterPoint(photoView: PhotoCellView) -> CGPoint {
        if self.photoView_CenterPoint != .zero {
            return self.photoView_CenterPoint
        }
        
        let minX = photoView.frame.minX
        let minY = photoView.frame.minY
        let width = photoView.frame.width
        let height = photoView.frame.height
//        print("***** minX: \(minX); minY: \(minY); width: \(width); height: \(height) *****")
        
        return CGPoint(x: minX + width / 2, y: minY + height / 2)
    }
    
    /// 获取顶部照片视图
    private func getTopPhotoView() -> PhotoCellView? {
        /**
         两种方式获取顶部视图：
         1.subViews
         2.存储视图数组
         */
        
        return self.photoViewsPool.firstObject as? PhotoCellView
    }
    
    /// 外部方法：按钮点击左右移动照片
    func clickPhotoViewMoveHandle(withDirection isRight: Bool) {
        if isRight {
            self.rightMoveHandle()
        } else {
            self.leftMoveHandle()
        }
        
    }
    
    /// 按钮点击左移照片操作
    private func leftMoveHandle() {
        let topView = self.getTopPhotoView()
        self.xFromCenter = -(self.photoView_FrameRect.size.width / 2)
        yFromCenter = 40
        
        // 按钮点击右移照片
        topView?.draggingHandle(distance: self.xFromCenter, dragingDirection: false)
        self.leftMoveAction(CGPoint(x: -20, y: 0))
        
    }
    
    /// 按钮点击右移照片操作
    private func rightMoveHandle() {
        let topView = self.getTopPhotoView()
        self.xFromCenter = self.photoView_FrameRect.size.width / 2
        yFromCenter = 40
        
        // 模拟数字
        topView?.draggingHandle(distance: self.xFromCenter, dragingDirection: true)
        self.rightMoveAction(CGPoint(x: 0, y: 20))
    }
    
    /// 获取当前照片的数据索引下标
    func getCurrentPhotoIndex() -> Int {
        return self.currentIndex
    }
    
    func hideDetailView(index: Int) {
        for view in self.photoViewsPool {
            guard let photoView = view as? PhotoCellView else { return }
            photoView.hideDetailView()
        }
        
    }
    
    // 添加点击事件
    private func addClickAction() {
        
        
    }
    
}

// MARK: - 手势 点击事件
extension PhotoContentView {
    @objc private func tapHandle(_ tapGesture: UITapGestureRecognizer) {
//        print("********* 序号tap")
        guard let delegate = self.delegate else { return }
        delegate.didSelectCell?(view: self, at: self.currentIndex)
    }
    
    @objc private func panHandle(_ panGesture: UIPanGestureRecognizer) {
        // 手指拖动移动的距离
        let pointMove = panGesture.translation(in: self)
        xFromCenter = pointMove.x
        yFromCenter = pointMove.y
        let pointTap = panGesture.location(in: self)
        guard let photoView = panGesture.view as? PhotoCellView else { return }
        
//        print("***** xFromCenter: \(xFromCenter); yFromCenter: \(yFromCenter) *****")
        
        // 是否向右
        let isRightDirection = xFromCenter > 0 // 用于代理时传递该参数
        switch panGesture.state {
        case .began:
            break
        case .changed:
            self.panGestureMoveing(withPoint: pointTap, photoView: photoView)
            let centerDistance = abs(xFromCenter)
            
            photoView.draggingHandle(distance: centerDistance, dragingDirection: isRightDirection)
            self.draggingChangePhotosScaleAndPosition(withDistance: centerDistance)
            self.sendDelegatePhotoViewDragging(with: centerDistance, direction: isRightDirection)
            
            break
        case .ended:
            // 重置方向
            self.panPositionDirection = .defaultValue
            
            // 检测照片是否支持拖拽
            var isCanDrag = true
            isCanDrag = self.sendDelegatePhotoViewSupportDrag(direction: isRightDirection)
            if !isCanDrag {
                xFromCenter = 0.1
            }
            
            self.panGestureStateEnd(withDistance: xFromCenter, andVelocity: panGesture.velocity(in: panGesture.view?.superview))
            
            break
        default:
            break
        }
        
    }
    
    /// 拖拽手势移动中
    private func panGestureMoveing(withPoint tapPoint: CGPoint, photoView: PhotoCellView) {
        // 获取拖拽手势开始的点击位置方向
        let startTapPositionDirection = getPanGestureBeginPoint(with: tapPoint, photoView: photoView)
        var rotationStrength: CGFloat = 0
        var rotationAngel: CGFloat = 0
        switch startTapPositionDirection {
        case .topLeft, .topRight:
            rotationStrength = min(xFromCenter / kScreenW, rotationMaxValue)
            rotationAngel = self.rotationAngle * rotationStrength
            
            break
        case .bottomLeft, .bottomRight:
            rotationStrength = min(xFromCenter / kScreenW, rotationMaxValue)
            rotationAngel = -(self.rotationAngle * rotationStrength)
            break
        default:
            break
        }
        
        // 设置卡片中心位置和角度
        let oldCenterPoint = self.photoView_CenterPoint == .zero ? self.getPhotoView_CenterPoint(photoView: photoView) : self.photoView_CenterPoint
        photoView.center = CGPoint(x: oldCenterPoint.x + xFromCenter, y: oldCenterPoint.y + yFromCenter)
        photoView.transform = CGAffineTransformMakeRotation(rotationAngel)
        
    }
    
    /// 获取拖拽手势开始的点击位置方向
    private func getPanGestureBeginPoint(with point: CGPoint, photoView: PhotoCellView) -> PanDragStatus {
        if self.panPositionDirection != .defaultValue {
            return self.panPositionDirection
        }
        
        var panDirection: PanDragStatus = .defaultValue
        
        let halfWidth = photoView.frame.size.width * 0.5
        let halfHeight = photoView.frame.size.height * 0.5
        let isLeftTop = CGRectContainsPoint(CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight), point)
        let isLeftBootom = CGRectContainsPoint(CGRect(x: 0, y: halfHeight, width: halfWidth, height: halfHeight), point)
        let isRightTop = CGRectContainsPoint(CGRect(x: halfWidth, y: 0, width: halfWidth, height: halfHeight), point)
        let isRightBootom = CGRectContainsPoint(CGRect(x: halfWidth, y: halfHeight, width: halfWidth, height: halfHeight), point)
        if isLeftTop {
            panDirection = .topLeft
        }
        
        if isLeftBootom {
            panDirection = .bottomLeft
        }
        
        if isRightTop {
            panDirection = .topRight
        }
        
        if isRightBootom {
            panDirection = .bottomRight
        }
        
        self.panPositionDirection = panDirection
        return panDirection
    }
    
    /// 拖拽手势结束后处理
    private func panGestureStateEnd(withDistance distance: CGFloat, andVelocity velocity: CGPoint) {
        // 判断最终移动方向
        // 已知 photoView_FrameRect != .zero
        if xFromCenter > 0 && (distance > self.photoView_FrameRect.size.width / 2 || velocity.x > maxVelocityValue) {
            // 向右移动
            self.rightMoveAction(velocity)
            

        } else if xFromCenter < 0 && (distance < -(self.photoView_FrameRect.size.width / 2) || velocity.x < -maxVelocityValue) {
            // 向左移动
            self.leftMoveAction(velocity)

        } else {
            // 没有移出去，拖拽的照片复原
            let isRightDirection = xFromCenter > 0
            
            let photoView  = self.getTopPhotoView()
            // 回到原点
            UIView.animate(withDuration: 0.25) {
                photoView?.center = self.photoView_CenterPoint
                photoView?.transform = CGAffineTransformMakeRotation(0)
                
                photoView?.dragEndRestoreHandle(draggedDirection: isRightDirection)
                // 其他照片也恢复到原始状态
                self.dragEndRestoreChangePhotosScaleAndPosition()
                self.sendDelegatePhotoViewDragEndRestore(draggedDirection: isRightDirection)
            }
        }
        
    }
    
    /// 拖拽结束后的事件处理操作
    private func panGestureMoveEndActionHandle(withTargetDistanceX targetDistanceX: CGFloat, velocity: CGPoint, isRightDirection: Bool) {
        // 横向移动距离
        let distanceX = targetDistanceX
        // 纵向移动距离
        let distanceY = distanceX * yFromCenter / xFromCenter
        
        // 目标centerPoint点
        let finishCenterPoint = CGPoint(x: self.photoView_CenterPoint.x + distanceX, y: self.photoView_CenterPoint.y + distanceY)
        
        let angle = isRightDirection ? rotationAngle : -rotationAngle
        
        let photoView = self.getTopPhotoView()
        
        UIView.animate(withDuration: 0.3) {
            photoView?.center = finishCenterPoint
            photoView?.transform = CGAffineTransformMakeRotation(angle)
            // 改变其他照片大小和位置
            self.dragEndChangePhotosScaleAndPosition()
            
        } completion: { finished in
            guard let photoView = photoView else { return }
            
            // 注意：动画还原包括 缩放 旋转
            photoView.transform = CGAffineTransform.identity
            self.dragFinishHandle(photoView, draggingDirection: isRightDirection)
        }
        
    }
    
    /// 照片拖拽完成处理
    private func dragFinishHandle(_ photoView: PhotoCellView, draggingDirection isRightDirection: Bool) {
        /**
         0. 改变移除照片的大小和位置
         1. 交换照片层
         2. 左右滑动完成 发送代理
         3. 加载底层照片视图的数据
         4. 交互：设置顶部照片可拖拽，其他不允许拖拽
         5. 移除底部照片动画图片，给顶部添加动画视图
         6. 更新数据索引下标
         */
        
        // 0. 改变移除照片的大小和位置
        photoView.center.x = kScreenW / 2
        photoView.frame.origin.y = 0
        photoView.transform = CGAffineTransformMakeScale(pow(zoomScale, CGFloat(photoViewsPool.count - 1 - 1)), 1.0)
        
        // 4. 设置最新底部视图不可交互
        photoView.isUserInteractionEnabled = false
        
        // 5. 移除底部照片动画图片，给顶部添加动画视图
        photoView.dragEndHandle()
        
        // 6.更新底部照片的下标
        photoView.index = self.lastIndex + 1
        
        // 3. 加载数据
        // 检查是否还有数据需要加载
        let isNoData = self.checkDataIsEmpty(withPhotoIndex: self.lastIndex)
        if isNoData {
            // 没有更多数据 移除照片
            photoView.removeFromSuperview()
            
            self.photoViewsPool.remove(photoView)
        } else {
            // 1. 交换照片层
            self.sendSubviewToBack(photoView)
            
            self.photoViewsPool.remove(photoView)
            self.photoViewsPool.add(photoView)
        }
        
        // 设置新顶部视图可交互
        let newTopView = photoViewsPool.firstObject as? PhotoCellView
        newTopView?.isUserInteractionEnabled = true
        // 给新的顶部视图添加动画视图
        newTopView?.addAnimationViews(frameWidth: photoWidth)
        
        // 2. 左右滑动完成 发送代理
        self.sendDelegatePhotoViewDragEnd(withPhotoIndex: self.currentIndex, direction: isRightDirection)
        
        if isNoData {
            // 没有数据时
            print("*** 没有数据可供底部视图加载 ***")
            self.sendDelegateNoDataLoadHandle() // 用于跳转页面
        } else {
            
            self.sendDelegateLoadBottomPhotoData(photoView: photoView, photoForIndex: photoView.index)
        }
        
        // 6. 更新当前的索引标记
        self.updateCurrentIndex()
        self.updateLastIndex()
    }
    
    /// 往右滑动的事件
    private func rightMoveAction(_ velocity: CGPoint) {
        // 移动到达的终点距离
        let distanceX = self.photoView_FrameRect.size.width + self.photoView_CenterPoint.x
        
        self.panGestureMoveEndActionHandle(withTargetDistanceX: distanceX, velocity: velocity, isRightDirection: true)
    }
    
    /// 往左滑动的事件
    private func leftMoveAction(_ velocity: CGPoint) {
        // 移动到达的终点距离
        let distanceX = -(self.photoView_FrameRect.size.width + self.photoView_CenterPoint.x)
        
        self.panGestureMoveEndActionHandle(withTargetDistanceX: distanceX, velocity: velocity, isRightDirection: false)
        
    }
    
    /// 拖拽手势移动中 改变其他照片的尺寸和位置 distance已取绝对值
    private func draggingChangePhotosScaleAndPosition(withDistance distance: CGFloat) {
        let allDistance = self.photoView_FrameRect.size.width / 2
        let offsetPercent = (distance / allDistance) > 1.0 ? 1.0 : (distance / allDistance)
        
//        print("***** \(offsetPercent) ******")
        
        let poolCount = self.photoViewsPool.count
        guard let photoViews = self.photoViewsPool as? [PhotoCellView] else { return }
        
        if poolCount < self.getVisiblePhotosCount() {
            // 判断是否是最后的一张照片(照片已被移出)
            for (i, photoView) in photoViews.enumerated() {
                if i == 0 {
                    continue
                }
                
                let index = i
                
                // poolCount 3
                // 4 - 1 - 2 1
                // 4 - 2 - 2 0
                // poolCount 2
                // 4 - 1 - 2 1
                let finalReverseIndex = CGFloat(self.getVisiblePhotosCount() - index - 1 - 1)
                
                // 改变位置
                photoView.frame.origin.y = photoViewOffset * finalReverseIndex + photoViewOffset * offsetPercent
                // 改变大小
                photoView.transform = CGAffineTransformMakeScale(pow(zoomScale, CGFloat(index - 1) + (1 - offsetPercent)), 1.0)
            }
            
        } else {
            for (i, photoView) in photoViews.enumerated() {
                if i == 0 {
                    continue
                }
                
                /// 最后一张图片的位置和尺寸和上一张一致
                var index = i
                if i == poolCount - 1 {
                    index = i - 1
                }
                
                // 去除掉底部被遮挡的那张照片的剩余个数
                let offset_visiblePhotosCount = poolCount - 1
                
                let reverseIndex: CGFloat = CGFloat(offset_visiblePhotosCount - 1 - index)
                
                // 最底部照片不做动态改变
                if i != poolCount - 1 {
                    // 改变位置
                    photoView.frame.origin.y = photoViewOffset * reverseIndex + photoViewOffset * offsetPercent
                    // 改变大小
                    photoView.transform = CGAffineTransformMakeScale(pow(zoomScale, CGFloat(index - 1) + (1 - offsetPercent)), 1.0)
                }
            }
            
        }
    }
    
    /// 拖拽结束时复原 还原其他照片的大小和尺寸
    private func dragEndRestoreChangePhotosScaleAndPosition() {
        // 移动距离 0
        self.draggingChangePhotosScaleAndPosition(withDistance: 0)
    }
    
    /// 拖拽结束时改变其他照片大小和位置
    private func dragEndChangePhotosScaleAndPosition() {
        // 移动距离半个屏幕 比例 1.0
        self.draggingChangePhotosScaleAndPosition(withDistance: self.photoView_FrameRect.size.width / 2)
    }
    
    
    /// 检查是否还有数据需要加载
    private func checkDataIsEmpty(withPhotoIndex lastIndex: Int) -> Bool {
        if lastIndex < 0 { return true }
        let totalDataNumber = self.receiveDataSourceNumberOfPhotos()
        if totalDataNumber <= (lastIndex + 1) {
            return true
        } else {
            return false
        }
    }
    
    /// 更新最新底部视图的数据索引index
    private func updateCurrentIndex() {
        let totalDataNumber = self.receiveDataSourceNumberOfPhotos()
        if self.currentIndex < (totalDataNumber - 1) {
            self.currentIndex += 1
            
        }
        
        print("**** currentIndex: \(currentIndex)")
    }
    
    /// 更新底部视图的数据索引index
    private func updateLastIndex() {
        let totalDataNumber = self.receiveDataSourceNumberOfPhotos()
        if self.lastIndex < (totalDataNumber - 1) {
            self.lastIndex += 1
        }
    }
    
}

// MARK: - 发送代理相关方法
extension PhotoContentView {
    
    /// 照片拖拽中 发送代理
    private func sendDelegatePhotoViewDragging(with centerDistance: CGFloat, direction isRightDirection: Bool) {
        if self.delegate != nil {
            delegate!.photoDragging(view: self, dragAllDistance: self.photoView_FrameRect.size.width / 2, photoViewDragDistance: centerDistance, dragDirection: isRightDirection)
        }
    }
    
    /// 照片拖拽结束是否支持拖拽 发送代理
    private func sendDelegatePhotoViewSupportDrag(direction isRightDirection: Bool) -> Bool {
        if self.delegate != nil {
            return delegate!.photoSupportDrag(view: self, dragDirection: isRightDirection)
        }
        
        return false
    }
    
    /// 照片拖拽结束复位 发送代理
    private func sendDelegatePhotoViewDragEndRestore(draggedDirection isRightDirection: Bool) {
        if delegate != nil {
            delegate!.photoDragEndRestore(view: self, draggedDirection: isRightDirection)
        }
    }
    
    /// 照片拖拽结束 发送代理
    private func sendDelegatePhotoViewDragEnd(withPhotoIndex index: Int, direction isRightDirection: Bool) {
        if self.delegate != nil {
            delegate!.photoDragEnd(view: self, indexForPhoto: index, dragDirection: isRightDirection)
        }
    }
    
    /// 拖拽结束没有数据可供加载时调用
    private func sendDelegateNoDataLoadHandle() {
        let totalDataNumber = self.receiveDataSourceNumberOfPhotos()
        if self.delegate != nil {
            delegate!.noDataLoadInBottomPhotoView?(view: self)
            
            if self.currentIndex == (totalDataNumber - 1) || self.photoViewsPool.count == 0 {
                // 判断当前拖拽的是最后一个照片 (有可能没有数据的情况下)
                delegate!.photoDragEndIsLastPhoto(view: self)
            }
        }
    }
    
    /// 加载底部视图的数据
    private func sendDelegateLoadBottomPhotoData(photoView: PhotoCellView, photoForIndex index: Int) {
        // 在底部视图上加载数据
        if index > (self.receiveDataSourceNumberOfPhotos() - 1) {
            print("**** 加载底部照片已越界 ****")
            return
        }
        if self.delegate != nil {
            delegate!.loadBottomPhotoData(view: self, photoView: photoView, photoForIndex: index)
        }
    }
    
    /// 获取照片数据数组个数
    private func receiveDataSourceNumberOfPhotos() -> Int {
        if self.dataSource != nil {
            return self.dataSource!.numberOfPhotos(view: self)
        }
        return 0
    }
    
    /// 加载初始展示的照片数据
    private func receiveDataSourceLoadStartShowData(photoForIndex index: Int) -> PhotoModel? {
        if self.dataSource != nil {
            return self.dataSource!.loadStartShowData(view: self, photoForIndex: index)
        }
        
        return nil
    }
    
}

