//
//  LXConvenienceBundle.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/19.
//  Copyright © 2020 李响. All rights reserved.
// 图片构造器 @X1 @X2 @X3 图片构建

import UIKit

//MARK: - 快速从bundle中加载图片
public struct ConvenienceBundle {
    private let path: String?           //默认bundle下文件夹名字
    private let bundlePath: String     //bundle文件全路径
    private let bundleName: String
    
    /// 初始化一个便利bundle构建器
    public init(bundlePath: String, bundleName: String, path: String? = nil) {
        self.bundlePath = bundlePath
        self.path = path
        self.bundleName = bundleName
    }
    /// 根据资源名称和资源路径加载资源,
    ///
    /// - imageNamed: 图片的名称或者路径
    /// - path: bundle中的路径,如果指定则不使用默认的路径
    public func imageNamed(_ imageName: String, path: String? = nil) -> UIImage? {
        var imagePath = "\(bundlePath)/\(bundleName)/"
        if let path = path {
            imagePath = imagePath + "\(path)/"
        } else if let path = self.path, path.count > 0 {
            imagePath = imagePath + "\(path)/"
        }
        imagePath = imagePath + imageName
        return ImageBuilder.loadImage(imagePath)
    }
}
/// 图片建造器,根据全路径返回适合的图片资源
fileprivate struct ImageBuilder {
    static var x1ImageBuilder: ImageAdaptNode = X1ImageBuilder(successor: X2ImageBuilder(successor: X3ImageBuilder()))
    static var x2ImageBuilder: ImageAdaptNode = X2ImageBuilder(successor: X3ImageBuilder(successor: X1ImageBuilder()))
    static var x3ImageBuilder: ImageAdaptNode = X3ImageBuilder(successor: X2ImageBuilder(successor: X1ImageBuilder()))
    static func loadImage(_ imagePath: String) -> UIImage? {
        let scale = UIScreen.main.scale
        if abs(scale - 3) <= 0.01 {
            return x3ImageBuilder.loadImage(imagePath)
        }else if abs(scale - 2) <= 0.01 {
            return x2ImageBuilder.loadImage(imagePath)
        }else {
            return x1ImageBuilder.loadImage(imagePath)
        }
    }
}

/// 声明责任链结点(责任链设计模式)
fileprivate protocol ImageAdaptNode {
    init(successor: ImageAdaptNode?)
    func loadImage(_ imagePath: String) -> UIImage?
}

/// 二倍图建造器
fileprivate struct X2ImageBuilder: ImageAdaptNode {
    private var successor: ImageAdaptNode?
    init(successor: ImageAdaptNode? = nil) {
        self.successor = successor
    }
    /// 试图加载二倍图
    func loadImage(_ imagePath: String) -> UIImage? {
        //加载二倍图,加载失败则继续遍历职责链
        if let image = UIImage(contentsOfFile: "\(imagePath)@2x.png") {
            return image
        }else{
            return successor?.loadImage(imagePath)
        }
    }
}

/// 三倍图建造器
fileprivate struct X3ImageBuilder: ImageAdaptNode {
    private var successor: ImageAdaptNode?
    init(successor: ImageAdaptNode? = nil) {
        self.successor = successor
    }
    /// 试图加载三倍图
    func loadImage(_ imagePath: String) -> UIImage? {
        if let image = UIImage(contentsOfFile: "\(imagePath)@3x.png") {
            return image
        }else{
            return successor?.loadImage(imagePath)
        }
    }
}

/// 一倍图建造器
fileprivate struct X1ImageBuilder: ImageAdaptNode {
    private var successor: ImageAdaptNode?
    init(successor: ImageAdaptNode? = nil) {
        self.successor = successor
    }
    /// 试图加载一倍图
    func loadImage(_ imagePath: String) -> UIImage? {
        if let image = UIImage(contentsOfFile: "\(imagePath).png") {
            return image
        }else{
            return successor?.loadImage(imagePath)
        }
    }
}
