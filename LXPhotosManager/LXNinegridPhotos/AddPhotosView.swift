//
//  AddPhotosView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/19.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class AddPhotosView: UIView {
    //MARK: - 私有属性
    //存放所有图片的集合
    private var photoViews = [SinglePhotoView]()
    private var photoModels = [FileInfoProtocol]()
    
    //缓存策略的图片集合
    private var cacheIMgViews = [SinglePhotoView]()
    
    //MARK: - 共有属性
    //数据源（可外部传入）
    public var pubPhotoModels = [FileInfoProtocol]() {
        didSet {
            for photoModel in pubPhotoModels {
                photoModels.append(photoModel)
                setNomalUI(with: photoModel)
            }
            setLayOut()
        }
    }
    
    //加载图片方式
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    
    // 加载最大高度回调
    public var loadCurrentViewMaxY: ((CGFloat) -> ())?

    //MARK: - 共有属性
    public var marginCol: CGFloat = 10
    public var marginRol: CGFloat = 10

    //显示横向几个（默认是4个）
    public var colCount: Int = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化UI
        setAddUI()
        // 布局 尺寸
        setLayOut()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AddPhotosView {
    private func setAddUI() {
       let photoView  = SinglePhotoView()
       photoView.delegate = self
       photoView.type = .add(isAdd: true)
       addSubview(photoView)
       photoViews.append(photoView)
    }
    
    //设置正常图片
    private func setNomalUI(with photo: FileInfoProtocol) {
        let photoView: SinglePhotoView
        if self.cacheIMgViews.count > 0 {
            photoView =  self.cacheIMgViews.first!
            photoView.isHidden = false
        }else {
            photoView = SinglePhotoView()
            photoView.delegate = self
            photoView.type = .add(isAdd: false)
            addSubview(photoView)
        }
       
       photoView.loadBlock = loadBlock
       photoView.photo = photo
       photoViews.insert(photoView, at: photoViews.count - 1)

    }
    
 private func setLayOut() {

    let w: CGFloat = (self.frame.width - marginCol * CGFloat(colCount - 1)) / CGFloat(colCount)
    let h = w
        for i in 0..<photoViews.count {
            let pictureView = photoViews[i]
            let col = i % colCount
            let row = i / colCount
            pictureView.frame = CGRect(x: (marginCol + w) * CGFloat(col), y: (marginRol + h) * CGFloat(row), width: w, height: h)
            pictureView.tag = i
        }
        self.frame.size.height = photoViews[photoViews.count - 1].frame.maxY
    
        loadCurrentViewMaxY?(self.frame.maxY)
    }
}

extension AddPhotosView {
    
    //获取跟控制器
    fileprivate func aboveViewController() -> UIViewController? {
        var aboveController = UIApplication.shared.delegate?.window??.rootViewController
        while aboveController?.presentedViewController != nil {
            aboveController = aboveController?.presentedViewController
        }
        return aboveController
    }
    
   private func selectLicense() {
       let sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheetController.addAction(UIAlertAction(title: "打开相机", style: .default, handler: {  [weak self] (alert) in
             self?.openCamera()
        }))
       sheetController.addAction(UIAlertAction(title: "打开相册", style: .default, handler: {  [weak self] (alert) in
               self?.openAlbum()
        }))
       sheetController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
       aboveViewController()?.present(sheetController, animated: true, completion: nil)
  }
    
  private func openCamera() {
           let picker = UIImagePickerController()
           picker.delegate = self
           //判断是否有上传相册权限
           if PrivilegeManager.isSupportCamera {
               picker.sourceType = .camera
               picker.modalPresentationStyle = .fullScreen

               aboveViewController()?.present(picker, animated: true, completion: nil)
           }else{
               let msg = "启动相机失败,请在手机设置中打开相机权限"
               let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
               alertController.modalPresentationStyle = .fullScreen

              aboveViewController()?.present(alertController, animated: true, completion: nil)
           }
       }
       private func openAlbum() {
           let picker = UIImagePickerController()
           picker.delegate = self
           //判断是否有上传相册权限
           if PrivilegeManager.isSupportPhotoAlbum {
               picker.sourceType = .photoLibrary
               picker.modalPresentationStyle = .fullScreen
               aboveViewController()?.present(picker, animated: true, completion: nil)
           }else{
               let msg = "打开相册失败,请在手机设置中打开相册权限"
               let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
               alertController.modalPresentationStyle = .fullScreen
               aboveViewController()?.present(alertController, animated: true, completion: nil)
           }
       }
    
    private func selectPhotoBrowser(index: Int) {
        //图片浏览器
        let pView = PhotosBrowserView()
        pView.imgViews = photoViews.filter({ [weak self] (singlePhotoView) -> Bool in
            return singlePhotoView.tag != ((self?.photoViews.count ?? 0) - 1)
        }).map({ (singlePhotoView) -> UIImageView in
            return singlePhotoView.imgView
        })
        
        pView.loadBlock = loadBlock
        pView.photos = self.photoModels
        pView.startAnimation(with: index, cellType: false)
    }
 
}

extension AddPhotosView: SinglePhotoViewDelegate {
    func singlePhotoView(with type: SinglePhotoViewTapType) {
        switch type {
        case let .tapImgView(singleType, singlePhotoView):
            if case let  SinglePhotoViewType.add(isAdd: isAdd) = singleType {
                if isAdd { // 点击➕号
                    self.selectLicense()
                }else { // 点击图片
                    self.selectPhotoBrowser(index: singlePhotoView.tag)
                }
            }
        case let .deleteImgView(singlePhotoView):
            self.cacheIMgViews.append(singlePhotoView)
            singlePhotoView.isHidden = true
            self.photoViews.remove(at: singlePhotoView.tag)
            self.photoModels.remove(at: singlePhotoView.tag)
            setLayOut()
        }
    }
}

extension AddPhotosView: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    //点击使用图片, 使用该图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        aboveViewController()?.dismiss(animated: true, completion: nil)
       
        guard let image = info[.originalImage] as? UIImage else {  return  }
        
        let photo = PhotoModel(image: image, height: image.size.height, width: image.size.width)
        photoModels.append(photo)
        //创建UI
        setNomalUI(with: photo)
        // 布局 尺寸
        setLayOut()
    }
}

public class PhotoModel: FileInfoProtocol {
    public var isNetWork: Bool
    public var image: UIImage
    public var height: CGFloat
    public var width: CGFloat
    public var imgUrl: String
    init(image: UIImage,
         height: CGFloat,
         width: CGFloat,
         isNetWork: Bool = false,
         imgUrl: String = "")
    {
        self.image = image
        self.height = height
        self.width = width
        self.imgUrl = imgUrl
        self.isNetWork = isNetWork
    }
}

public class PrivilegeManager: NSObject {
    
    /// 判断是否有访问相机的权限
    public static var isSupportCamera: Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .denied || authStatus == .restricted {
            return false
        }
        return true
    }
    
    /// 判断是否有访问麦克风的权限
    public static var isSupportAudio: Bool {
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        if authStatus == .denied || authStatus == .restricted {
            return false
        }
        return true
    }
        
    /// 判断程序是否有访问相册的权限
    public static var isSupportPhotoAlbum: Bool {
        
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted {
            return false
        }
        return true
    }
    
}
