//
//  LXNinegridPhotosView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/16.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXFitManager

//点击 回调协议
public protocol NineGridPhotosViewDelegate: AnyObject {
    
    ///数据源回调
    func nineGridPhotosView(with index: Int,photoViews: [SinglePhotoView],datasource: [FileInfoProtocol])
    
    ///点击视频播放
    func nineGridPhotosView(videoPlay model: FileInfoProtocol)
}

public class NineGridPhotosView: UIView {

    //MARK: - 私有属性
    ///存放所有图片的集合
    private var photoViews = [SinglePhotoView]()
    private var currentDatasource =  [FileInfoProtocol]()

     //MARK: - 公共属性
    /// 加载图片方式
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    
    /// 加载最大高度回调
    public var loadCurrentViewMaxY: ((CGFloat) -> ())?
   
    ///图片文件数据源
    public var datasource =  [FileInfoProtocol](){
        didSet { setDataWithUI() }
    }
    
    /// 图片最大个数（默认最大个数是9个）
    public var photoMaxCount: Int = 9 {
        didSet { setDataWithUI() }
    }
    
    /// 代理协议
    public weak var delegate: NineGridPhotosViewDelegate?
    
    /// 只有一张图片的时候设置（多张不用设置）
    public var singleViewH: CGFloat = LXFit.fitFloat(180)
    public var singleViewW: CGFloat = LXFit.fitFloat(180)

    /// 多张图片的间隔
    public var marginRol: CGFloat = LXFit.fitFloat(5.0)
    public var marginCol: CGFloat = LXFit.fitFloat(5.0)

    private var type: SinglePhotoType
    
    /// 自定义指定构造器
    /// frame 默认尺寸设置
    /// addImage 加号 ➕ 图片修改（不设置 则使用默认的）
    public init(frame: CGRect,
                type: SinglePhotoType = .photo)
    {
        self.type = type
        super.init(frame: frame)
        backgroundColor = UIColor.white

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 公共属性
extension NineGridPhotosView {
    
    ///设置数据与UI
    private func setDataWithUI() {
       //设置数据
       setCurrentDatasource()
       
       //初始化UI界面
       setUI()
    }
    
    /// 设置数据
    private func setCurrentDatasource() {
        if  datasource.count >= photoMaxCount{
            var datas = [FileInfoProtocol]()
            for (index,photo) in datasource.enumerated() {
                if index >= photoMaxCount {
                    break
                }else{
                    datas.append(photo)
                }
            }
           currentDatasource = datas
        }
    }
    
    /// 初始化UI
    private func setUI() {
        var photoView: SinglePhotoView
        for (index,photo) in self.currentDatasource.enumerated() {
            
            if index >= photoViews.count  { //判断是否在缓存里取
                photoView = SinglePhotoView()
                photoView.delegate = self
                photoView.type = .nineGrid(type: type)
                photoView.tag = index
                addSubview(photoView)
                photoViews.append(photoView)
            }else {
                photoView = photoViews[index]
            }
            //SinglePhotoView 信息配置
            photoView.isHidden = false
            photoView.loadBlock = loadBlock
            photoView.photo = photo
        }
        
        //SinglePhotoView 视图控制
        for index in currentDatasource.count..<photoViews.count {
            let photoView = photoViews[index]
            photoView.isHidden = true
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if (currentDatasource.count == 1) {
            let photo = currentDatasource[0]
            let photoW = photo.width
            let photoH = photo.height
            var imgW: CGFloat = 0.0
            var imgH: CGFloat = 0.0
            if photoW != 0.0 && photoH != 0.0 {
                if photoH > photoW {
                    imgH = min(photoH, singleViewH)
                    imgW = imgH * photoW / photoH
                }else{
                    imgW = min(photoW, singleViewW)
                    imgH = imgW * photoH / photoW
                }
            }
            
            let photoView = photoViews[0]
            photoView.frame = CGRect(x: 0, y: 0, width: imgW, height: imgH)
            
            }else if(currentDatasource.count > 1){
                // 总列数
                var totalCols = 3;
                if (currentDatasource.count == 4) {
                    totalCols = 2
                }
            
                let imgW = (self.frame.width - CGFloat((totalCols - 1)) * marginRol) / CGFloat(totalCols)
                let imgH = imgW;

                for i in 0..<currentDatasource.count {
                     let col = i % totalCols
                     let rol = i / totalCols
                     let photoView = photoViews[i]
                     photoView.frame = CGRect(x: (imgW + marginCol) * CGFloat(col), y: (imgH + marginRol) * CGFloat(rol), width: imgW, height: imgH)
                }
           }
        
        if currentDatasource.count > 0 {
            //设置当前view最大高度
            self.frame.size.height = photoViews[currentDatasource.count - 1].frame.maxY
        }else {
            self.frame.size.height = 0
        }
        
        // 最大高度回调
        loadCurrentViewMaxY?(self.frame.maxY)
    }
}

//MARK: - 类扩展（代理回调）
extension NineGridPhotosView: SinglePhotoViewDelegate {

    public func singlePhotoView(with photoViewTapType: SinglePhotoViewTapType) {

        switch photoViewTapType {
        case let .tapImgView(_, type, singlePhotoView):
            
            if type == .photo {
                let photoViews = self.photoViews.filter { (photoView) -> Bool in
                    return photoView.tag < currentDatasource.count
                }
                delegate?.nineGridPhotosView(with: singlePhotoView.tag, photoViews: photoViews, datasource: currentDatasource)
            }else {
                if let photo = singlePhotoView.photo {
                   delegate?.nineGridPhotosView(videoPlay: photo)
               }
            }
            
        default:
            break
        }
    }
}
