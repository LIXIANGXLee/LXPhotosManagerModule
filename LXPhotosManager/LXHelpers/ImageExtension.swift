//
//  UIImageExtension.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/5/21.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    
      /// 获取视频缩略图
      ///
      /// - Parameters:
      ///   - seconds 获取第几秒缩略图
      ///   - videoUrl: 视频Url (本地的url和远程的url都可以)
    public static func imageWithVideo(start seconds: Float64 = 0, videoUrl: URL?) -> UIImage?{
          guard let videoUrl = videoUrl else { return nil }
          
          let asset = AVURLAsset(url: videoUrl, options: nil)
          let generator = AVAssetImageGenerator(asset: asset)
          generator.appliesPreferredTrackTransform = true
          let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: 600)
          guard let image = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }
          let shotImage = UIImage(cgImage: image)
          return shotImage;
      }
    
      /// 旋转图片(解决拍照90度问题)
      public func fixOrientation() -> UIImage {
         if self.imageOrientation == .up {
             return self
         }
         var transform = CGAffineTransform.identity
         switch self.imageOrientation {
         case .down, .downMirrored:
             transform = transform.translatedBy(x: self.size.width, y: self.size.height)
             transform = transform.rotated(by: .pi)
             break
         case .left, .leftMirrored:
             transform = transform.translatedBy(x: self.size.width, y: 0)
             transform = transform.rotated(by: .pi / 2)
             break
         case .right, .rightMirrored:
             transform = transform.translatedBy(x: 0, y: self.size.height)
             transform = transform.rotated(by: -.pi / 2)
             break
         default:
             break
         }
         switch self.imageOrientation {
         case .upMirrored, .downMirrored:
             transform = transform.translatedBy(x: self.size.width, y: 0)
             transform = transform.scaledBy(x: -1, y: 1)
             break
         case .leftMirrored, .rightMirrored:
             transform = transform.translatedBy(x: self.size.height, y: 0);
             transform = transform.scaledBy(x: -1, y: 1)
             break
         default:
             break
         }
         let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
         ctx?.concatenate(transform)
         switch self.imageOrientation {
         case .left, .leftMirrored, .right, .rightMirrored:
             ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
             break
         default:
             ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
             break
         }
         let cgimg: CGImage = (ctx?.makeImage())!
         let img = UIImage(cgImage: cgimg)
         return img
     }
}
