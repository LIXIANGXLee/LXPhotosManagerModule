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
import LXFitManager

/// 回调协议
public protocol AddPhotosViewDelegate: AnyObject {
    
    ///数据源回调
    func addPhotosView(with datasource: [FileInfoProtocol])
    
    ///长按回调
    func addPhotosView(longPress addPhotosView : AddPhotosView, model: FileInfoProtocol)

}
//MARK: -  添加图片的类
public class AddPhotosView: UIView {
    //MARK: - 私有属性
    ///存放所有图片的集合
    private var photoViews = [SinglePhotoView]()
    private var photoModels = [FileInfoProtocol]()
    
    ///缓存策略的图片集合
    private var cacheImgViews = [SinglePhotoView]()
    
    /// 加号 ➕ 和删除图片的配置信息
    private var config: SinglePhotoConfig
    
    //MARK: - 共有属性
    ///数据源（可外部传入）
    public var pubPhotoModels = [FileInfoProtocol]() {
        didSet {
            for photoModel in pubPhotoModels {
                photoModels.append(photoModel)
                setNomalUI(with: photoModel)
            }
            setLayOut()
        }
    }
    
    ///加载图片方式
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    
    /// 加载最大高度回调
    public var loadCurrentViewMaxY: ((CGFloat) -> ())?

    /// 代理协议
    public weak var delegate: AddPhotosViewDelegate?
    
    /// 自定义指定构造器
    /// frame 默认尺寸设置
    /// addImage 加号 ➕ 图片修改（不设置 则使用默认的）
    public init(frame: CGRect,
         config: SinglePhotoConfig = SinglePhotoConfig())
    {
        self.config = config
        super.init(frame: frame)
        backgroundColor = UIColor.white

        //初始化UI
        setAddUI()
        // 布局 尺寸
        setLayOut()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - 类扩展（UI）
extension AddPhotosView {
    /// 初始化UI
    private func setAddUI() {
       let photoView  = SinglePhotoView()
       photoView.delegate = self
       photoView.type = .add(isAdd: true, config: config)
       addSubview(photoView)
       photoViews.append(photoView)
    }
    
    ///设置正常图片
    private func setNomalUI(with photo: FileInfoProtocol) {
        let photoView: SinglePhotoView
        if self.cacheImgViews.count > 0 {
            photoView =  self.cacheImgViews.first!
            self.cacheImgViews.removeFirst()
            photoView.isHidden = false
        }else {
            photoView = SinglePhotoView()
            photoView.delegate = self
            photoView.type = .add(isAdd: false, config: config)
            addSubview(photoView)
        }
       
       photoView.loadBlock = loadBlock
       photoView.photo = photo
       photoViews.insert(photoView, at: photoViews.count - 1)

    }
    
    /// 尺寸布局
    private func setLayOut() {

        let w: CGFloat = (self.frame.width - config.marginCol * CGFloat(config.colCount - 1) - config.marginLeft - config.marginright) / CGFloat(config.colCount)
        let h = w
        var maxSelfH: CGFloat = 0
        for i in 0..<photoViews.count {
            let pictureView = photoViews[i]
            let col = i % config.colCount
            let row = i / config.colCount
            pictureView.tag = i
            pictureView.frame = CGRect(x: config.marginLeft + (config.marginCol + w) * CGFloat(col), y:((config.deleteImagePointOffSet.y < 0) ? -config.deleteImagePointOffSet.y : 0) + (config.marginRol + h) * CGFloat(row), width: w, height: h)
            pictureView.isHidden = false
            if photoViews.count > config.photoMaxCount {
               pictureView.isHidden = i == config.photoMaxCount
               maxSelfH = photoViews[photoViews.count - 2].frame.maxY
            }else{
               maxSelfH = photoViews[photoViews.count - 1].frame.maxY
            }
            
        }
        ///当前view最大高度
        self.frame.size.height = maxSelfH
        ///在大高度回调
        loadCurrentViewMaxY?(self.frame.maxY)
        ///代理回调
        delegate?.addPhotosView(with: self.photoModels)
    }
}

//MARK: - 类扩展（VC）
extension AddPhotosView {
    
    ///获取跟控制器
    fileprivate func aboveViewController() -> UIViewController? {
        var aboveController = UIApplication.shared.delegate?.window??.rootViewController
        while aboveController?.presentedViewController != nil {
            aboveController = aboveController?.presentedViewController
        }
        return aboveController
    }

    /// 相册相机选择
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

    /// 选择相机
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
     /// 选择相册
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

    ///图片浏览器
    private func selectPhotoBrowser(index: Int) {
        //图片浏览器
        let pView = PhotosBrowserView()
        pView.delegate = self
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

//MARK: - 类扩展（代理回调）
extension AddPhotosView: PhotosBrowserViewDelagete {
    public func photosBrowserView(longPress photosBrowserView: PhotosBrowserView, _ model: FileInfoProtocol) {
        delegate?.addPhotosView(longPress: self, model: model)
    }
}

//MARK: - 类扩展（代理回调）
extension AddPhotosView: SinglePhotoViewDelegate {
    public func singlePhotoView(with type: SinglePhotoViewTapType) {
        switch type {
        case let .tapImgView(singleType, singlePhotoView):
            if case let  SinglePhotoViewType.add(isAdd: isAdd, config: _) = singleType {
                if isAdd { // 点击➕号
                    self.selectLicense()
                }else { // 点击图片
                    self.selectPhotoBrowser(index: singlePhotoView.tag)
                }
            }
        case let .deleteImgView(singlePhotoView):
            self.cacheImgViews.append(singlePhotoView)
            singlePhotoView.isHidden = true
            // 删除需小心 加判断 否则 连点击 会有越界问题
            if self.photoViews.contains(singlePhotoView){
                self.photoViews.remove(at: singlePhotoView.tag)
                self.photoModels.remove(at: singlePhotoView.tag)
            }
            setLayOut()
        }
    }
}

//MARK: - 类扩展（代理回调）
extension AddPhotosView: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    //点击使用图片, 使用该图片
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        aboveViewController()?.dismiss(animated: true, completion: nil)
       
        guard let image = info[.originalImage] as? UIImage else {  return  }
        
        let photo = PhotoModel(image: image,
                               height: image.size.height,
                               width: image.size.width)
        photoModels.append(photo)
        //创建UI
        setNomalUI(with: photo)
        // 布局 尺寸
        setLayOut()
    }
}

///模型数据
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

//MARK: - 类扩展（隐私管理）
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
