//
//  PhotosScrollView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXFitManager

protocol PhotosScrollViewDelegate: AnyObject {
    
     // MARK: - 点击时调用
    func photosScrollView(_ photosScrollView: PhotosScrollView, didSelectPhotoAt index: Int)
    // MARK: - cell滚动偏移量
    func photosScrollView(_ photosScrollView: PhotosScrollView, contentOffSetAt index: Int)
     // MARK: -  拖拽滚动时调用或者长按回调
    func photosScrollView(_ photosScrollView: PhotosScrollView, _ type: PhotosScrollViewType)

}

class PhotosScrollView: UIView {
    fileprivate let identified = "PhotosScrollViewCell";

    fileprivate var index: Int
    fileprivate var cellType: Bool
    fileprivate lazy var layOut: UICollectionViewFlowLayout = {
        let layOut = UICollectionViewFlowLayout()
        layOut.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layOut.itemSize = CGSize(width: self.bounds.width + LXFit.fitFloat(20),
                                 height: self.bounds.height)
        layOut.minimumLineSpacing = .leastNormalMagnitude
        layOut.minimumInteritemSpacing = .leastNormalMagnitude
        return layOut
    }()
    
    fileprivate(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0,
                                                            y: 0,
                                                            width: self.bounds.width + LXFit.fitFloat(20),
                                                            height: self.bounds.height),
                                              collectionViewLayout: self.layOut)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(PhotosScrollViewCell.self,
                                forCellWithReuseIdentifier: identified)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }else{
            collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
        return collectionView
    }()
    
    fileprivate lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: 0,
                                                      y: self.bounds.height - PhotosBrowserConst.TabBarH - LXFit.fitFloat(20),
                                                      width: self.bounds.width,
                                                      height: LXFit.fitFloat(20)))
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.isEnabled = false
        return pageControl
    }()
    
    fileprivate var photosScrollCell: PhotosScrollViewCell!
    
    // MARK: - public
    ///代理
     weak var delegate: PhotosScrollViewDelegate?
     var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    ///可选项 是否加载高清图
     var finishAnimation: ((FileInfoProtocol,UIImageView) -> ())?
    ///是否显示指示器
     var isFinishActivityAnimation: Bool = false {
        didSet {
           photosScrollCell.isFinishActivityAnimation = self.isFinishActivityAnimation
        }
    }
    
     var photos: [FileInfoProtocol] = [FileInfoProtocol]() {
        didSet {
            //异常处理
            if index >=  photos.count {return}
            //设置显示器的总个数
            pageControl.numberOfPages = photos.count > 9 ? 0 : photos.count
            
            //刷新表格
            collectionView.reloadData()
            
            /// 移动偏移量
            collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(index),
                                                    y: 0), animated: false)
        
         }
     }
    
    // MARK: - system
    init(frame: CGRect, _ index: Int, _ cellType: Bool) {
        self.index = index
        self.cellType = cellType
        super.init(frame: frame)
        
        // 添加滚动view
        addSubview(collectionView)
        
        // pageControll
        addSubview(pageControl)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - UICollectionViewDelegate
extension PhotosScrollView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width + 0.5
        if pageControl.numberOfPages != 0 {
            pageControl.currentPage = Int(page) % pageControl.numberOfPages
        }
        
        //传递索引
        delegate?.photosScrollView(self, contentOffSetAt: Int(page))
    }
}

// MARK: - UICollectionViewDataSource
extension PhotosScrollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        photosScrollCell = collectionView.dequeueReusableCell(withReuseIdentifier: identified,
                                                              for: indexPath) as? PhotosScrollViewCell
        photosScrollCell.loadBlock = loadBlock
        photosScrollCell.finishAnimation = finishAnimation
        photosScrollCell.model = photos[indexPath.item]
        photosScrollCell.delegate = self
        return photosScrollCell
    }
}

// MARK: - PhotosScrollViewCellDelegate
extension PhotosScrollView: PhotosScrollViewCellDelegate {
    func photosScrollViewCell(_ photosScrollViewCell: PhotosScrollViewCell, _ type: PhotosScrollViewType) {
        delegate?.photosScrollView(self, type)
    }
    
    func photosScrollViewCell(didSelect photosScrollViewCell: PhotosScrollViewCell) {
        guard let indexpath = collectionView.indexPath(for: photosScrollViewCell) else { return}
        delegate?.photosScrollView(self, didSelectPhotoAt: indexpath.item)
    }    
}
