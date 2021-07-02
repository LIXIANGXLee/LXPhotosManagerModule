//
//  SinglePhotoConfig.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/5/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXFitManager

public enum SinglePhotoType {
    case video // 视频
    case photo // 图片
}

public struct SinglePhotoConfig {
   /// 指定构造器
    public init(type: SinglePhotoType = SinglePhotoType.photo ,
               addImage: UIImage? = UIImage.named("NinePhotoAdd"),
               deleteImage: UIImage? = UIImage.named("NinePhotoDelete"),
               deleteImageSize: CGSize = CGSize(width: LXFit.fitFloat(20),
                                                height: LXFit.fitFloat(20)),
               videoPlayImage: UIImage? = UIImage.named("video_centerPlay"),
               videoPlayImageSize: CGSize = CGSize(width: LXFit.fitFloat(20), height: LXFit.fitFloat(20)),
               deleteImagePointOffSet: CGPoint = CGPoint.zero,
               marginCol: CGFloat = LXFit.fitFloat(10),
               marginRol: CGFloat = LXFit.fitFloat(10),
               marginLeft: CGFloat = LXFit.fitFloat(10),
               marginright: CGFloat = LXFit.fitFloat(10),
               colCount: Int = 4,
               photoMaxCount: Int = 9,
               deleteImageRadius: CGFloat = 0)
   {
       self.type = type
       self.addImage = addImage
       self.deleteImage = deleteImage
       self.deleteImageSize = deleteImageSize
       self.videoPlayImage = videoPlayImage
       self.videoPlayImageSize = videoPlayImageSize
       self.deleteImagePointOffSet = deleteImagePointOffSet
       self.marginCol = marginCol
       self.marginRol = marginRol
       self.marginLeft = marginLeft
       self.marginright = marginright
       self.colCount = colCount
       self.photoMaxCount = photoMaxCount
       self.deleteImageRadius = deleteImageRadius
   }
    
    /// 类型 默认是图片
    public var type: SinglePhotoType
    
    /// 删除的图片  图片修改（不设置 则使用默认的）
    public var deleteImage: UIImage?
    /// 删除图片的尺寸（不设置 则使用默认的尺寸）
    public var deleteImageSize: CGSize
    /// 删除图片相对目前位置的偏移量（不设置 则使用默认的尺寸）
    public var deleteImagePointOffSet: CGPoint
    /// 设置圆角大小
    public var deleteImageRadius: CGFloat
    
    /// 视频播放小按钮
    public var videoPlayImage: UIImage?
    ///视频播放按钮大小
    public var videoPlayImageSize: CGSize

    /// 加号➕图片  图片修改（不设置 则使用默认的）
    public var addImage: UIImage?

    ///图片的间距
    public var marginCol: CGFloat
    public var marginRol: CGFloat
    public var marginLeft: CGFloat
    public var marginright: CGFloat

    ///横向显示几个图片（默认是4个）
    public var colCount: Int
    
    ///添加图片的最大个数（默认是9个）
    public var photoMaxCount: Int
    
    
}
