//
//  FileInfoProtocol.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit


@objc public protocol FileInfoProtocol {
    
   @objc var image:  UIImage { get set }
   @objc var height: CGFloat { get set }
   @objc var width:  CGFloat { get set }
    
    // 如果是图片选择器 则是图片   如果是视频 则是缩略图
   @objc var imgUrl: String  { get set }
    
    // 视频 的 url
   @objc var videoUrl: String  { get set }

    //isNetWork = true 为网络数据 false为本地数据
   @objc var isNetWork: Bool  { get set }

}
