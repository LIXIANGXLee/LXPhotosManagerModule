//
//  PhotosBrowserView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//
// 图片浏览器显示动画界面

import UIKit

public struct Const {
    static let ScreenW : CGFloat = UIScreen.main.bounds.width
    static let ScreenH : CGFloat = UIScreen.main.bounds.height
    static let TabBarH : CGFloat = (ScreenH == 812 || ScreenH == 896) ? 83 : 49
}

@objc public protocol  PhotosBrowserViewDelagete: AnyObject {
    
    //代理方法获取cell
    @objc optional func photosBrowserView(cellIndex: Int,photos: [FileInfoProtocol]) -> UIView
    
    //图片长按事件
    @objc optional func photosBrowserView(longPress photosBrowserView: PhotosBrowserView,_ model: FileInfoProtocol)
}

public class PhotosBrowserView: UIView {

    //数据源（必传）
    public var photos:[FileInfoProtocol] = [FileInfoProtocol]()
    public var imgViews:[UIImageView] = [UIImageView]()
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    
    //可选项 是否加载高清图
    public var finishAnimation: ((FileInfoProtocol,UIImageView) -> ())?
    //是否显示指示器
    public var isFinishActivityAnimation: Bool = false {
        didSet {
            scrollView.isFinishActivityAnimation = isFinishActivityAnimation
        }
    }
    
    //代理协议
    public weak var delegate: PhotosBrowserViewDelagete?
    
    fileprivate var cellType: Bool = false
    fileprivate var index: Int = 0
    fileprivate var imgViewCenterPoint: CGPoint = .zero

    fileprivate var scrollView: PhotosScrollView!
    fileprivate var panGesture: UIPanGestureRecognizer!

    //当前模型
    fileprivate var fileModel: FileInfoProtocol { get { return self.photos[self.index] } }
    //图片原始尺寸
    fileprivate var imgOriginRect: CGRect {
        get {
            guard let view  = cellType ? delegate?.photosBrowserView?(cellIndex: index, photos: photos) : imgViews[index] else {return .zero}
            return view.convert(view.bounds, to: self)
        }
    }

    //滚动的imgView尺寸 图片当前尺寸
    fileprivate var zoomImgViewRect: CGRect {
        get {
            let indexpath = IndexPath(item: index, section: 0)
            let scrollViewCell = scrollView.collectionView.cellForItem(at: indexpath) as! PhotosScrollViewCell
            return scrollViewCell.imgViewZoomRect
        }
    }
    
    //覆盖层view
    fileprivate lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.transform = CGAffineTransform.identity
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    //MARK: - system
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.alpha = 0.0
        self.frame = CGRect(x: 0, y: 0, width: Const.ScreenW, height: Const.ScreenH)
        UIApplication.shared.windows.last?.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 扩展方法
extension PhotosBrowserView {
    //MARK: -  index 点击索引  cellType是否为cell类型 True为cell类型 默认 false
    public func startAnimation(with index: Int,cellType: Bool)  {
        self.cellType = cellType
        self.index = index
       
        //添加等大的图片覆盖层
        addCoverImgView()
        
        //开始动画
        addAnimation()
    }
  
    //MARK: - 点击或者滑动 移除imgView of Animation
    fileprivate func removeAnimation()  {
        
        scrollView.isHidden = true
        imgView.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
            self.imgView.frame = self.imgOriginRect
        }) { (finished) in
            self.removeFromSuperview()
            self.imgView.removeFromSuperview()
            self.scrollView.removeFromSuperview()
        }
    }
}

extension PhotosBrowserView {
     //MARK: - 添加覆盖层
    fileprivate func addCoverImgView() {
        UIApplication.shared.windows.last?.addSubview(imgView)
        imgView.frame = imgOriginRect
        loadBlock?(fileModel,imgView)
    }
    
     //MARK: - 开始动画
    fileprivate func addAnimation() {
        let imgH = bounds.width * fileModel.height / fileModel.width
        UIView.animate(withDuration: 0.25, animations: {
            self.imgView.frame = CGRect(x: 0, y: (self.bounds.height - imgH) * 0.5, width: self.bounds.width, height: imgH)
            if imgH > self.bounds.height {
                self.imgView.frame.origin.y = 0
            }
            self.alpha = 1.0
            
        }) { (finished) in
            
            //隐藏覆盖层
            self.imgView.isHidden = true
            //添加图片浏览器
            self.addScrollView()
            //添加手势
            self.addGesture()
        }
    }
    
     //MARK: - 添加图片浏览器
    fileprivate func addScrollView() {
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        scrollView = PhotosScrollView(frame: rect,index,self.cellType)
        scrollView.loadBlock = loadBlock
        scrollView.finishAnimation = finishAnimation
        scrollView.photos = photos
        scrollView.delegate = self
        UIApplication.shared.windows.last?.addSubview(scrollView)
    }
    
    //MARK: - 添加手势
    fileprivate func addGesture() {
       panGesture = UIPanGestureRecognizer(target: self, action: #selector(pangesture(_:)))
       UIApplication.shared.windows.last?.addGestureRecognizer(panGesture)
    }
    
     //MARK: - 手势滑动处理
    @objc fileprivate func pangesture(_ gesture: UIPanGestureRecognizer) {

        let point = gesture.translation(in: gesture.view)
        if gesture.state == .changed {
            //滑动改变处理
            beganScrollChange(point)
        }else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            // 滑动结束处理
            endScrollChange(point)
        }
    }
     //MARK: - 开始滑动处理
    private func beganScrollChange(_ point: CGPoint) {
        
        //如果滑动y小于0 说明往上面滑 则只改变偏移量 不进行缩放
        if point.y <= 0 {
            imgView.center = CGPoint(x: imgViewCenterPoint.x + point.x, y: imgViewCenterPoint.y + point.y)
            return
        }
        
        if imgView.isHidden {
            imgView.isHidden = false
            scrollView.isHidden = true
            imgView.frame = zoomImgViewRect
            loadBlock?(fileModel,imgView)
            imgViewCenterPoint = imgView.center
        }else { //开始缩放
            let scale = 1 - point.y / bounds.height
            self.alpha = scale           
            imgView.transform = CGAffineTransform(scaleX: max(imgOriginRect.height / bounds.height, scale), y: max(imgOriginRect.height / bounds.height, scale))
            imgView.center = CGPoint(x: imgViewCenterPoint.x + point.x , y: imgViewCenterPoint.y + point.y)
        }
    }
    
     //MARK: - 复原位置
    private func resume() {
        self.imgView.frame = self.zoomImgViewRect
        self.alpha = 1.0
        //隐藏覆盖层
        self.imgView.isHidden = true
        self.scrollView.isHidden = false
    }
    
     //MARK: - 结束滑动处理
    private func endScrollChange(_ point: CGPoint) {       
        if point.y >= 20 {
            //移除imgView
            removeAnimation()
        }else {
            //复位imgView
           resume()
        }
    }
}

 //MARK: - PhotosScrollViewDelegate
extension PhotosBrowserView: PhotosScrollViewDelegate {
    
    //滑动大图的时候调用
    func photosScrollView(_ photosScrollView: PhotosScrollView, _ type: PhotosScrollViewType) {
        
        switch type {
        case let .began(point):
             beganScrollChange(point)
        case let .end(point):
             endScrollChange(point)
        case .resume:
             resume()
        case let .longPress(model):
            delegate?.photosBrowserView?(longPress: self, model)
        }
    }
    
     // 图片的点击事件
    func photosScrollView(_ photosScrollView: PhotosScrollView, didSelectPhotoAt index: Int) {
        //记录索引
        self.index = index
        
        //设置尺寸
        imgView.frame = zoomImgViewRect
        loadBlock?(fileModel,imgView)

        //移除动画
        removeAnimation()
    }
    
    // 滚动的索引
    func photosScrollView(_ photosScrollView: PhotosScrollView, contentOffSetAt index: Int) {
        //记录索引
        self.index = index
    }
}
