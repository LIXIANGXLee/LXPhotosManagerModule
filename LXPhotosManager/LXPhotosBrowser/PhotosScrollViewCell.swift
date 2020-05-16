//
//  PhotosScrollViewCell.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXFitManager

 enum PhotosScrollViewType{
    case began(CGPoint) //开始
    case end(CGPoint) //结束
    case resume //恢复
    case longPress(FileInfoProtocol) //长按事件
}

protocol PhotosScrollViewCellDelegate: AnyObject {
     ///点击时调用
    func photosScrollViewCell(didSelect photosScrollViewCell: PhotosScrollViewCell)
    
    ///拖拽滚动时调用或者长按回调
    func photosScrollViewCell(_ photosScrollViewCell: PhotosScrollViewCell,_ type: PhotosScrollViewType)
}

class PhotosScrollViewCell: UICollectionViewCell {

    ///判断拖拽以及拖拽时记录起始point
    fileprivate var isDrag: Bool = false
    fileprivate var isBeganPoint: CGPoint = .zero
    
    fileprivate lazy var singleTag: UITapGestureRecognizer = {
        let singleTag = UITapGestureRecognizer(target: self, action:#selector(imgView(withSingleTap:)))
        singleTag.numberOfTapsRequired = 1
        singleTag.require(toFail: self.doubleTag)
        return singleTag
    }()
    
    fileprivate lazy var doubleTag: UITapGestureRecognizer = {
        let doubleTag = UITapGestureRecognizer(target: self, action:#selector(imgView(withdoubleTap:)))
        doubleTag.numberOfTapsRequired = 2
        return doubleTag
    }()
    
    fileprivate lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(imgView(withLongPress:)))
        longPress.minimumPressDuration = 0.8
        return longPress
    }()
    
    fileprivate lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.isUserInteractionEnabled = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.contentSize = .zero
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.maximumZoomScale = 3
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }else{
            scrollView.translatesAutoresizingMaskIntoConstraints = false
        }
        return scrollView
    }()
    
    //指示器
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        let iView = UIActivityIndicatorView(frame: CGRect(x: (self.scrollView.frame.width - LXFit.fitFloat(60)) * 0.5, y: (self.scrollView.frame.height - LXFit.fitFloat(60)) * 0.5, width: LXFit.fitFloat(60), height: LXFit.fitFloat(60)))
        iView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        iView.layer.cornerRadius = LXFit.fitFloat(6)
        iView.clipsToBounds = true
        return iView
    }()
    
    // MARK: - public
    ///imgView的尺寸
    fileprivate(set) var imgViewZoomRect: CGRect = .zero
    ///代理
    weak var delegate: PhotosScrollViewCellDelegate?
    ///用于加载图片的代码块, 必须赋值
    var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    ///可选项 是否加载高清图
    var finishAnimation: ((FileInfoProtocol,UIImageView) -> ())?
    ///是否显示指示器
    var isFinishActivityAnimation: Bool = false {
        didSet {           
            if self.isFinishActivityAnimation {
                indicatorView.stopAnimating()
            }else{
                indicatorView.startAnimating()
            }
        }
    }
    
    ///数据源
    var model: FileInfoProtocol? {
        didSet {
            guard let m = model, m.width != 0 else { return }
            
            //ScrollView内容复位
            setResetScrollView()
            
            //设置图片尺寸
            setImgViewRect(m)
            
            //复值
            imgViewZoomRect = imgView.frame
            
            //设置图片
            loadBlock?(m,imgView)

            //设置高清图片
            finishAnimation?(m,imgView)
            
        }
    }
    
 
    // MARK: - system
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(imgView)
        scrollView.addSubview(indicatorView)
        scrollView.addGestureRecognizer(singleTag)
        scrollView.addGestureRecognizer(doubleTag)
        scrollView.addGestureRecognizer(longPress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotosScrollViewCell {
    
    ///设置图片尺寸
    fileprivate func setImgViewRect(_ model: FileInfoProtocol) {
        let imgW = bounds.width - LXFit.fitFloat(20)
        let imgH = imgW * model.height / model.width
        if imgH > bounds.height { //图片高度大于当前view高度
            scrollView.contentSize = CGSize(width: 0, height: imgH)
            imgView.frame = CGRect(x: 0, y: 0, width:imgW, height: imgH)
        } else{//图片高度小于等于当前view高度
            imgView.frame = CGRect(x: 0, y: (bounds.height - imgH) * 0.5, width: imgW, height: imgH)
        }
    }
    
    ///图片单击方法
    @objc fileprivate func imgView(withSingleTap gesture: UITapGestureRecognizer) {
        delegate?.photosScrollViewCell(didSelect: self)
    }
    
    ///图片双击方法
    @objc fileprivate func imgView(withdoubleTap gesture: UITapGestureRecognizer) {
        let scale: CGFloat = (scrollView.zoomScale == 1.0) ? 3.0 : 1.0
        let center = gesture.location(in: gesture.view)
        let size = CGSize(width: scrollView.frame.width / scale, height: scrollView.frame.height / scale)
        scrollView.zoom(to: CGRect(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5, width: size.width, height: size.height), animated: true)
        
        //外部调用尺寸（相对父视图是屏幕宽度的view）
        setResetImgViewZoomRect()
        
    }
     ///图片长按方法
    @objc fileprivate func imgView(withLongPress gesture: UITapGestureRecognizer) {
        
        if gesture.state == .began {
            guard let m = model, m.width != 0 else { return }
            delegate?.photosScrollViewCell(self, .longPress(m))
        }
    }
    
    ///复位
    fileprivate func setResetScrollView() {
        scrollView.contentSize = .zero
        scrollView.contentInset = .zero
        scrollView.zoomScale = 1.0
    }
    
     ///外部调用尺寸（相对父视图是屏幕宽度的view）
    fileprivate func setResetImgViewZoomRect() {
        
        if imgView.frame.height > scrollView.frame.height  {
            imgViewZoomRect = CGRect(x: -scrollView.contentOffset.x, y: -scrollView.contentOffset.y, width: imgView.frame.width, height: imgView.frame.height)
        }else {
            imgViewZoomRect = CGRect(x: -scrollView.contentOffset.x, y: (scrollView.frame.height -  imgView.frame.height) * 0.5, width: imgView.frame.width, height: imgView.frame.height)
        }
    }
}

 // MARK: - UIScrollViewDelegate
extension PhotosScrollViewCell: UIScrollViewDelegate {
    
    ///绑定缩放图片
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    ///缩放后设置位置坐标
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offSetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offSetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        imgView.center = CGPoint(x: scrollView.contentSize.width  * 0.5 - LXFit.fitFloat(20) + offSetX, y:  scrollView.contentSize.height * 0.5 + offSetY)
        
        //外部调用尺寸（相对父视图是屏幕宽度的view）
         setResetImgViewZoomRect()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //外部调用尺寸（相对父视图是屏幕宽度的view）
        setResetImgViewZoomRect()
        
        //滚动大图时 开始调用
        if isDrag {
            delegate?.photosScrollViewCell(self, .began(CGPoint(x: -scrollView.contentOffset.x + isBeganPoint.x, y: -scrollView.contentOffset.y + isBeganPoint.y)))
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= LXFit.fitFloat(100) && !scrollView.isZooming{
            isDrag = true
            isBeganPoint = scrollView.contentOffset
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
         isDrag = false
        //滚动大图时 停止调用
      if  scrollView.contentOffset.y < LXFit.fitFloat(-100) && !scrollView.isZooming{
            delegate?.photosScrollViewCell(self, .end(CGPoint(x: -scrollView.contentOffset.x + isBeganPoint.x, y: -scrollView.contentOffset.y + isBeganPoint.y)))
        }else{
            delegate?.photosScrollViewCell(self, .resume)
        }
    }
}

