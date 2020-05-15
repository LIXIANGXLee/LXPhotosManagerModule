//
//  LXPhotosListViewController.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/5/14.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXPhotosManager

class LXPhotosListViewController: UIViewController {
    // MARK: 定义属性
       fileprivate lazy var collectionView : UICollectionView = {
           let layout = UICollectionViewFlowLayout()
           layout.minimumLineSpacing = 10
           layout.minimumInteritemSpacing = 10
           layout.itemSize = CGSize(width: 120, height: 120)
           let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
           collectionView.dataSource = self
           collectionView.delegate = self
           
           collectionView.register(UINib(nibName: "PictureCell", bundle: nil), forCellWithReuseIdentifier: "cell")
           collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
           collectionView.backgroundColor = UIColor.white
                
           return collectionView
       }()
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
        self.navigationItem.title = "图片列表"
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
        models.append(model)
        models.append(model2)
        models.append(model)
        models.append(model1)
        models.append(model2)
        models.append(model)
        models.append(model2)
        models.append(model)
        models.append(model1)
        models.append(model2)
        models.append(model)
        models.append(model2)
        models.append(model)
        models.append(model1)
        models.append(model2)
        models.append(model)
        models.append(model2)
        models.append(model)
        
        
        view.addSubview(collectionView)
        
    }

}
// MARK:- collectionView的数据源&代理
extension LXPhotosListViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCell
        cell.photo = models[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //图片浏览器
        let pView = PhotosBrowserView()
        pView.delegate = self
        pView.loadBlock = { model, imgView in
          imgView.kf.setImage(with: URL(string: model.imgUrl)!)
        }
        pView.photos = models
        pView.startAnimation(with: indexPath.item, cellType: true)
        
    }
}

extension LXPhotosListViewController: PhotosBrowserViewDelagete {
    func photosBrowserView(cellIndex: Int, photos: [FileInfoProtocol]) -> UIView {
        return collectionView.cellForItem(at: IndexPath(item: cellIndex, section: 0)) ?? UIView()
    }
    
    
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
