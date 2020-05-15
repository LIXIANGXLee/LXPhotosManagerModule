//
//  SinglePhotoView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/16.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

//MARK: - 点击类型区分的枚举
public enum SinglePhotoViewTapType {
    ///点击图片
    case tapImgView(SinglePhotoViewType,SinglePhotoView)
    ///点击删除图片
    case deleteImgView(SinglePhotoView)
}

///当前view显示样式
public enum SinglePhotoViewType {
    /// 添加图片view用 isAdd = true 是默认的➕图片 false 是选择的图片
    /// addImage加号图片 nil 则使用默认的
    case add(isAdd: Bool,addImage: UIImage?)
    
    /// 九宫格view
    case nineGrid
}

//MARK: - 点击 回调协议
public protocol SinglePhotoViewDelegate: AnyObject {
     func singlePhotoView(with type: SinglePhotoViewTapType)
}

public class SinglePhotoView: UIView {
    
    ///加载图片方式
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?

    ///单个图片数据源
    public var photo: FileInfoProtocol? {
        didSet {
            guard let photo = self.photo else { return}
            loadBlock?(photo,imgView)
        }
    }
    
    /// 代理协议
    public weak var delegate: SinglePhotoViewDelegate?
    
    /// 默认是九宫格布局
    public var type: SinglePhotoViewType = .nineGrid { didSet { setDefaultAddImage() } }
    
    /// 默认 ➕ 图片
    public var addImage: UIImage? { didSet { setDefaultAddImage() } }
    
    /// 图片
    public var imgView: UIImageView!
    private var closeImgView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SinglePhotoView {
    
    ///设置默认加号➕ 图片
    private func setDefaultAddImage() {
        //选择添加图片的默认 ➕ 图片
        if case let .add(isAdd: isAdd,addImage: addImage) = self.type {
            if isAdd {
                if let addImg = addImage {
                    imgView.image = addImg
                }else{
                    imgView.image = UIImage.named("NinePhotoAdd")
                }
            }
        }
    }
    
    /// 初始化UI
    private func setUI() {
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.isUserInteractionEnabled = true
        imgView.clipsToBounds = true
        addSubview(imgView)
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImgView)))
        
        closeImgView = UIImageView()
        closeImgView.contentMode = .scaleAspectFill
        closeImgView.isUserInteractionEnabled = true
        closeImgView.clipsToBounds = true
        closeImgView.image = UIImage.named("NinePhotoDelete")
        addSubview(closeImgView)
        closeImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCloseImgView)))
    }
    
    /// 尺寸布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)

        //设置closeButton尺寸
        if case let .add(isAdd: isAdd, addImage: _) = self.type  {
            if !isAdd {
                 closeImgView.frame = CGRect(x: self.frame.width - 20, y: 0, width: 20, height: 20)
            }
        }
    }
    
    /// 删除图片
    @objc private func tapCloseImgView() {
        delegate?.singlePhotoView(with: SinglePhotoViewTapType.deleteImgView(self))
    }
    
    ///点击图片
    @objc private func tapImgView() {
        switch self.type {
        case .nineGrid:
            delegate?.singlePhotoView(with: SinglePhotoViewTapType.tapImgView(.nineGrid, self))
        case let .add(isAdd: isAdd, addImage: addImage):
            delegate?.singlePhotoView(with: SinglePhotoViewTapType.tapImgView(.add(isAdd: isAdd, addImage: addImage), self))
        }
    }
}
