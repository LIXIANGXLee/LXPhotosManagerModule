//
//  LXPhotosBrowserViewController.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/17.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXPhotosManager

public class FileModel: FileInfoProtocol {
    public var isNetWork: Bool = true
    public var image: UIImage = UIImage()
    public var height: CGFloat = 0.0
    public var width: CGFloat = 0.0
    public var imgUrl: String = ""
}


class LXPhotosBrowserViewController: UIViewController {
   
    
    var imgViews = [UIImageView]()
    let datas = [
  "https://dss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1661707474,1451343575&fm=26&gp=0.jpg",
  "https://dss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3159064993,1446035142&fm=26&gp=0.jpg",
  "https://dss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2712496081,4225310564&fm=26&gp=0.jpg"
          ]
    
    var models = [FileInfoProtocol]()
    deinit {
           print("\(self)内存已释放")
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "九宫格图片"
        self.view.backgroundColor = UIColor.white
        
        let model = FileModel()
        model.width = 250
        model.height = 250
        model.imgUrl = datas[0]

        let model1 = FileModel()
        model1.width = 500
        model1.height = 375
        model1.imgUrl = datas[1]

        let model2 = FileModel()
        model2.width = 500
        model2.height = 313
        model2.imgUrl = datas[2]
        
        models.append(model1)
        models.append(model2)
        models.append(model)
        models.append(model2)
        models.append(model)
        models.append(model1)
        models.append(model2)
        models.append(model2)
        models.append(model)
        models.append(model1)
        models.append(model2)
        models.append(model2)
        models.append(model)
        models.append(model1)
        models.append(model2)
      
        setUI()
        
    }

    private func setUI() {
        // 九宫格
        let photoVeiw = NineGridPhotosView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 500))

        photoVeiw.delegate = self
        photoVeiw.loadBlock = { model, imgView in
            imgView.kf.setImage(with: URL(string: model.imgUrl)!)
        }
        photoVeiw.datasource = models
        photoVeiw.photoMaxCount = 7

        view.addSubview(photoVeiw)

    }
}

extension LXPhotosBrowserViewController: NineGridPhotosViewDelegate {
    func nineGridPhotosView(with index: Int, photoViews: [SinglePhotoView], datasource: [FileInfoProtocol]) {
        
        //图片浏览器
        let pView = PhotosBrowserView()
        pView.delegate = self
        pView.imgViews = photoViews.map({ (singlePhotoView) -> UIImageView in
            return singlePhotoView.imgView
        })
        pView.loadBlock = { model, imgView in
          imgView.kf.setImage(with: URL(string: model.imgUrl)!)
        }
        pView.photos = datasource
        pView.startAnimation(with: index, cellType: false)

    }
}

extension LXPhotosBrowserViewController: PhotosBrowserViewDelagete {

    /// 长按保存图片
    func photosBrowserView(longPress photosBrowserView: PhotosBrowserView, _ model: FileInfoProtocol) {

        UIImageView().kf.setImage(with: URL(string: model.imgUrl), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacge, url) in
            
            SaveAsset.saveImageToAsset(with:  image ?? UIImage()) { (type) in
               if case .success = type {
                     let msg = "保存图片成功"
                        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        alertController.modalPresentationStyle = .fullScreen
                       self.present(alertController, animated: true, completion: nil)
                   }else if case let  .failure(error) = type {
                          let alertController = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                          alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                          alertController.modalPresentationStyle = .fullScreen
                         self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
