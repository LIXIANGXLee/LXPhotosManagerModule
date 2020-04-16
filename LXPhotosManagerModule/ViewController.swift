//
//  ViewController.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/15.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXPhotosManager

class FileModel: FileInfoProtocol {
   
    var image: UIImage = UIImage()
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var imgUrl: String = ""
}

class ViewController: UIViewController {

    var imgViews = [UIImageView]()
    let datas = [
              "https://dss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1661707474,1451343575&fm=26&gp=0.jpg",
              "https://dss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3159064993,1446035142&fm=26&gp=0.jpg",
              "https://dss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2712496081,4225310564&fm=26&gp=0.jpg"
          ]
          
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    private func setUI() {
        
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
            
        // 九宫格
        let photoVeiw = NineGridPhotosView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 600))
        photoVeiw.delegate = self
        photoVeiw.loadBlock = { model, imgView in
            imgView.kf.setImage(with: URL(string: model.imgUrl)!)
        }
        photoVeiw.datasource = [model,model1,model2,model2,model1]
        view.addSubview(photoVeiw)
 
    }
}

extension ViewController: NineGridPhotosViewDelegate {
    func nineGridPhotosView(with index: Int, photoViews: [SinglePhotoView], datasource: [FileInfoProtocol]) {
        
        //图片浏览器
        let pView = PhotosBrowserView()
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
