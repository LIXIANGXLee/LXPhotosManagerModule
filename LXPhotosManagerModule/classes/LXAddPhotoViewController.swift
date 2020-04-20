//
//  LXAddPhotoViewController.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/17.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

class LXAddPhotoViewController: UIViewController {
    let datas = [
                 "https://dss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1661707474,1451343575&fm=26&gp=0.jpg",
                 "https://dss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3159064993,1446035142&fm=26&gp=0.jpg",
                 "https://dss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2712496081,4225310564&fm=26&gp=0.jpg"
             ]
    var models = [FileInfoProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        
        view.backgroundColor = UIColor.white
        
        let addView  = AddPhotosView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 600))
        view.addSubview(addView)
        addView.delegate = self

        addView.loadBlock = { model, imgView in
            if model.isNetWork {
                imgView.kf.setImage(with: URL(string: model.imgUrl)!)
            }else{
                imgView.image = model.image
            }
        }
        addView.pubPhotoModels = models
        addView.loadCurrentViewMaxY = { maxY in
            print("---------\(maxY)")
        }
    }

}

extension LXAddPhotoViewController: AddPhotosViewDelegate {
    func addPhotosView(with datasource: [FileInfoProtocol]) {
        print("--=-=-=-=",datasource)
    }
    func addPhotosView(longPress addPhotosView: AddPhotosView, model: FileInfoProtocol) {
        
        if model.isNetWork {
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
        }else {
            SaveAsset.saveImageToAsset(with:  model.image) { (type) in
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
