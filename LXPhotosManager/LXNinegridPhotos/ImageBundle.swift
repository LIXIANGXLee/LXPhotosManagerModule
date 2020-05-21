//
//  ImageBundle.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/19.
//  Copyright © 2020 李响. All rights reserved.
// 加载图片扩展

import UIKit

fileprivate class ConvenienceBundleSelfPath {}
public extension UIImage {
    
    /// 图片加载
   static func named(_ imageName: String?) -> UIImage? {
       guard let imageName = imageName else { return nil }
       return imageBundle.imageNamed(imageName)
   }
   
   private static var imageBundle = ConvenienceSelfBundle(bundlePath: Bundle(for: ConvenienceBundleSelfPath.self).bundlePath, bundleName: "NineGridPhotos.bundle")
}
