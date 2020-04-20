//
//  SaveAsset.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/20.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import Photos

public enum SaveAssetType {
   
    case success(UIImage) //图片保存成功
    case failure(String) //图片保存失败
}

public class SaveAsset: NSObject {
 
    //创建图片唯一标识
    fileprivate static var assetImageLocalIdentifier: String?
    
    //创建相册薄的唯一标识
    fileprivate static var assetCollectionLocalIdentifier: String?
  
    public typealias CallBack = ((SaveAssetType) -> ())
    //回调函数
    fileprivate static var callBack: CallBack?
    fileprivate static var colloctionName: String?
    fileprivate static var image: UIImage = UIImage()

}

//MARK: - public 保存图片
public extension SaveAsset {
    
    @available(iOS 9, *)
    static func saveImageToAsset(with image: UIImage,
                                 colloctionName: String = "LXPhotos",
                                 callBack: CallBack?) {
        self.colloctionName = colloctionName
        self.image = image
        self.callBack = callBack

        //判断是否授权
        getAuthorization()
    }
}

//MARK: - private 似有方法 授权
extension SaveAsset {
   fileprivate class func getAuthorization() {
       let status = PHPhotoLibrary.authorizationStatus()
       switch status {
       case .restricted,.denied:
           DispatchQueue.main.async {
            callBack?(.failure("请在手机的设置>隐私>相机中开启的相册访问权限"))
            return
           }
       case .authorized:
            //写入图片
           self.writeImageToAsset()
       case .notDetermined:
           PHPhotoLibrary.requestAuthorization { (s) in
               if s == .authorized {
                   self.writeImageToAsset()
               }
           }
       default: break
       }
   }
}

//MARK: - private 似有方法 获取相册薄 写入图片到相册薄
extension SaveAsset {
    ///图片写入相册
    @available(iOS 9, *)
    fileprivate class func writeImageToAsset() {
         //1先保存图片到系统相册
         PHPhotoLibrary.shared().performChanges({
            assetImageLocalIdentifier =  PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier
         }) { (success, error) in
             if success == false { //创建相簿失败
                 DispatchQueue.main.async {
                    callBack?(.failure("创建相簿失败!"))
                 }
             }else {//创建相簿成功
                 // 2.获取相薄
                let assetCollection = getAssetCollection(with: colloctionName!)
                if assetCollection == nil {
                    DispatchQueue.main.async {//获取相册失败 直接返回
                        callBack?(.failure("获取相册薄失败"))
                    }
                    return
                }
               PHPhotoLibrary.shared().performChanges({
                 // 3.添加"相机胶卷"中的图片A到"相簿"D中
                 // 获得图片
                 if assetImageLocalIdentifier != nil {
                      let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetImageLocalIdentifier!], options: nil)
                     
                    // 添加图片到相簿中的请求
                   let request = PHAssetCollectionChangeRequest(for: assetCollection!)
                     request?.insertAssets(asset, at: IndexSet(arrayLiteral: 0))
                 }
               }) { (success, error) in
                 if success {
                     DispatchQueue.main.async {
                         callBack?(.success(image))
                     }
                 }else {
                     DispatchQueue.main.async {
                         callBack?(.failure("保存图片失败!"))
                     }
                 }
             }
         }
     }
 }
 
     ///获取相薄
    fileprivate class func getAssetCollection(with colloctionName: String) -> PHAssetCollection? {
         //获取系统相册薄 如果有当前相册薄直接返回当前的
         let assetCollections = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
          var assetCollection: PHAssetCollection?
          assetCollections.enumerateObjects { (collection, index, isStop) in
             if collection.localizedTitle == colloctionName {
                 assetCollection = collection
             }
          }
         
         //获取到当前相册薄
         if assetCollection != nil { return assetCollection! }
         
         do {
             try PHPhotoLibrary.shared().performChangesAndWait {
                assetCollectionLocalIdentifier =  PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: colloctionName).placeholderForCreatedAssetCollection.localIdentifier
             }
         }catch { return nil }
         if assetCollectionLocalIdentifier != nil {
             return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [(assetCollectionLocalIdentifier!)], options: nil).firstObject
         }else { return nil }
     }
}
