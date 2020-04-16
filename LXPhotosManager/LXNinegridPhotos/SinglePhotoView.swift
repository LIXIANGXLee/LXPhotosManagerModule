//
//  SinglePhotoView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/16.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

//点击类型区分的枚举
public enum SinglePhotoViewTapType {
    //点击图片
    case tapImgView(SinglePhotoView)
    //点击删除图片
    case deleteImgView(SinglePhotoView)
}

//点击 回调协议
public protocol SinglePhotoViewDelegate: AnyObject {
     func singlePhotoView(with type: SinglePhotoViewTapType)
}

public class SinglePhotoView: UIView {
    
    //加载图片方式
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?

    //单个图片数据源
    public var photo: FileInfoProtocol? {
        didSet {
            guard let photo = self.photo else { return}
            loadBlock?(photo,imgView)
        }
    }
    
    //代理协议
    public weak var delegate: SinglePhotoViewDelegate?
    
    //图片
    public var imgView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SinglePhotoView {

    private func setUI() {
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.isUserInteractionEnabled = true
        imgView.clipsToBounds = true
        addSubview(imgView)
        
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImgView)))
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    //图片点击
    @objc private func tapImgView() {
        delegate?.singlePhotoView(with: SinglePhotoViewTapType.tapImgView(self))
    }
}
