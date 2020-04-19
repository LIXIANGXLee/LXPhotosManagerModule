# LXPhotosManagerModule

#### 项目介绍
 **

### 最完美、最轻量级的图片管理!
** 

#### 安装说明
方式1 ： cocoapods安装库 
        ** pod 'LXPhotosManager'
        pod install** 

方式2:   **直接下载压缩包 解压**    **LXPhotosManager **   

#### 使用说明
 **下载后压缩包 解压   请先 pod install  在运行项目** 

###  模型数据 必须遵守协议  FileInfoProtocol
  
```
class FileModel: FileInfoProtocol {
    var image: UIImage = UIImage()
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var imgUrl: String = ""
 }
```
####九宫格展示（微信朋友圈图片方式）

```
  let photoVeiw = NineGridPhotosView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 600))
  photoVeiw.delegate = self
  photoVeiw.loadBlock = { model, imgView in
     imgView.kf.setImage(with: URL(string: model.imgUrl)!)
  }
  photoVeiw.datasource = [model,model1,model2,model3,model4]
  view.addSubview(photoVeiw)

```
####九宫格展示 点击调用图片浏览器 (图片浏览)

```
  let pView = PhotosBrowserView()
  pView.imgViews = [imgView,imgView1,imgView2]
  pView.loadBlock = { model, imgView in
    imgView.kf.setImage(with: URL(string: model.imgUrl)!)
  }
  pView.photos = [model,model1,model2]
  let index =  [imgView,imgView1,imgView2].firstIndex(of: gesture.view) ?? 0
  pView.startAnimation(with: index, cellType: false)

```
####UICollectionView 点击调用图片浏览器 (图片浏览)

```
  //图片浏览器
  let pView = PhotosBrowserView()
  pView.delegate = self
  pView.loadBlock = { model, imgView in
    imgView.kf.setImage(with: URL(string: model.imgUrl)!)
  }
  pView.photos = models
  pView.startAnimation(with: indexPath.item, cellType: true)
  
  //必须实现代理方法
  extension ViewController: PhotosBrowserViewDelagete {
      func photosBrowserView(cellIndex: Int, photos: [FileInfoProtocol]) -> UIView {
          return collectionView.cellForItem(at: IndexPath(item: cellIndex, section: 0)) ?? UIView()
      }
  }
  
```
####  点击加号 可以选择相册图片 或者相机拍照  或者网络图片 删除图片缓存策略

```
  let addView  = AddPhotosView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 600))
  addView.delegate = self
  view.addSubview(addView)
  addView.loadBlock = { model, imgView in
     if model.isNetWork { // 网络图片z加载
         imgView.kf.setImage(with: URL(string: model.imgUrl)!)
     }else{ // 相册图片加载
         imgView.image = model.image
     }
  }
  addView.pubPhotoModels = models
  
  //代理方法 选择后的数据源
  func addPhotosView(with datasource: [FileInfoProtocol]) {
       print(datasource)
   }
```
 **效果图展示和手势拖动时的效果** 


![效果图](https://images.gitee.com/uploads/images/2020/0413/210512_a13591d4_1890422.png "Simulator Screen Shot - iPhone 11 Pro Max - 2020-04-13 at 21.01.36.png")
![收拾拖动时的效果图](https://images.gitee.com/uploads/images/2020/0413/210819_01e0de32_1890422.png "Simulator Screen Shot - iPhone 11 Pro Max - 2020-04-13 at 21.07.25.png")
![选择添加图片](https://images.gitee.com/uploads/images/2020/0419/233028_ab66df44_1890422.png "Simulator Screen Shot - iPhone 11 Pro Max - 2020-04-19 at 22.43.20.png")
