//
//  PictureCell.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/16.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXPhotosManager

class PictureCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!

    public var photo: FileInfoProtocol? {
        didSet {
            guard let photo = self.photo else { return}
            imgView.kf.setImage(with: URL(string: photo.imgUrl))
        }
    }
}
