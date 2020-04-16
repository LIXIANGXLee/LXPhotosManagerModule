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

 **效果图展示和手势拖动时的效果** 


![效果图](https://images.gitee.com/uploads/images/2020/0413/210512_a13591d4_1890422.png "Simulator Screen Shot - iPhone 11 Pro Max - 2020-04-13 at 21.01.36.png")
![收拾拖动时的效果图](https://images.gitee.com/uploads/images/2020/0413/210819_01e0de32_1890422.png "Simulator Screen Shot - iPhone 11 Pro Max - 2020-04-13 at 21.07.25.png")
