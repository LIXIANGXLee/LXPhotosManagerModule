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
        
        for i in 0..<datas.count {
           
           let imgView = UIImageView(frame: CGRect(x: 10 + 100 * i, y: 100, width: 100, height: 100))
           imgView.contentMode = .scaleAspectFill
           imgView.clipsToBounds = true
           view.addSubview(imgView)
           imgView.isUserInteractionEnabled = true
           imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgViewClick)))
           imgView.kf.setImage(with: URL(string: datas[i])!)
            
           imgViews.append(imgView)
            
        }
        
    }
    
    @objc func imgViewClick(gesture: UITapGestureRecognizer) {
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
        
           let pView = PhotosBrowserView()
           pView.imgViews = imgViews
           pView.loadBlock = { model, imgView in
            imgView.kf.setImage(with: URL(string: model.imgUrl)!)
            
           }
           pView.photos = [model,model1,model2]
           pView.startAnimation(with: imgViews.firstIndex(of: gesture.view as! UIImageView) ?? 0, cellType: false)

    }
}


