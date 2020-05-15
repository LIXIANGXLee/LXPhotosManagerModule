//
//  LXFit.swift
//  LXFoundationManager
//
//  Created by XL on 2020/4/23.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

public enum LXFitType: Int {
    /// 关闭适配
    case none = 0
    /// |~| 开启手机屏幕式配
    case flex = 1
}

// MARK: - 屏幕尺寸适配
public final class LXFit: NSObject {
    //默认是屏幕适配（外部可全局设置）
    public static var fitType = LXFitType.flex
}

// MARK: - UIFont 字体大小扩展的分类
extension UIFont {
   public var fitFont: UIFont { return self|~| }
}

// MARK: - 屏幕尺寸 扩展的分类
extension LXFit {
    public static func fitInt(_ value: Int) -> CGFloat { value|~| }
    public static func fitFloat(_ value: CGFloat) -> CGFloat { return value|~| }
    public static func fitDouble(_ value: CGFloat) -> Double { return Double(value|~|) }
    public static func fitFoint(_ value: CGPoint) -> CGPoint { value|~| }
    public static func fitSize(_ value: CGSize) -> CGSize { value|~| }
    public static func fitRect(_ value: CGRect) -> CGRect { value|~| }
    public static func fitEdgeInsets(_ value: UIEdgeInsets) -> UIEdgeInsets { value|~| }
}

// MARK: -  屏幕适配api
extension LXFit {
    
     /// 尺寸适配
     ///
     /// - Parameters:
     ///   - value: 尺寸大小
    fileprivate static func fitSize( _ value: CGFloat)  -> CGFloat {
        switch LXFit.fitType {
        case .none:
            return value
        case .flex:
            return value * CGFloat(UIScreen.main.bounds.width /  CGFloat(375.0))
        }
    }
}

// MARK: -  自定义运算符 operator |~|
postfix operator |~|
/// 重载运算符
public postfix func |~| (value: CGFloat) -> CGFloat {
    return LXFit.fitSize(value)
}

public postfix func |~| (font: UIFont) -> UIFont {
    return font.withSize(font.pointSize|~|)
}

public postfix func |~| (value: Int) -> CGFloat {
    return CGFloat(value)|~|
}

public postfix func |~| (value: Float) -> CGFloat {
    return CGFloat(value)|~|
}

public postfix func |~| (value: CGPoint) -> CGPoint {
    return CGPoint(
        x: value.x|~|,
        y: value.y|~|
    )
}
public postfix func |~| (value: CGSize) -> CGSize {
    return CGSize(
        width: value.width|~|,
        height: value.height|~|
    )
}
public postfix func |~| (value: CGRect) -> CGRect {
    return CGRect(
        x: value.origin.x|~|,
        y: value.origin.y|~|,
        width: value.size.width|~|,
        height: value.size.height|~|
    )
}
public postfix func |~| (value: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(
        top: value.top|~|,
        left: value.left|~|,
        bottom: value.bottom|~|,
        right: value.right|~|
    )
}
