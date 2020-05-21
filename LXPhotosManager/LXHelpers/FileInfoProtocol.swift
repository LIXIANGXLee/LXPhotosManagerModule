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
   @objc var imgUrl: String  { get set }
    
    //isNetWork = true 为网络数据 false为本地数据
   @objc var isNetWork: Bool  { get set }

}
