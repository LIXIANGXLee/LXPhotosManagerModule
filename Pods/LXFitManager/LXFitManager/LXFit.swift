//
//  LXFit.swift
//  LXFitManager
//
//  Created by XL on 2020/4/23.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

/// 是否开启屏幕尺寸适配（适配或者关闭适配）
public enum LXFitType: Int {
    /// 关闭适配
    case none = 0
    /// |~| 开启手机屏幕尺寸适配
    case flex = 1
}

// MARK: - 屏幕尺寸适配
public final class LXFit: NSObject {
    
    ///默认是屏幕适配
    ///（外部可全局设置，设置none为全局禁止屏幕适配，默认是屏幕适配）
    public static var fitType: LXFitType = LXFitType.flex
    
    /// 按照屏幕宽适配 默认是iphone6 适配标准 可自行修改 适配的标准以宽度为准
    /// 如果修改适配标准，推荐在启动程序时就设置，以免在设置之前使用不准确问题
    public static var fitWidthOfIpnone: Double = 375.0
    
}

// MARK: - UIFont Int CGFloat Double CGSize CGRect UIEdgeInsets扩展的分类
extension UIFont {
    /// UIFont 字体大小适配
    public var fitFont: UIFont { return self|~| }
}

extension Int {
    /// Int 屏幕尺寸大小适配
    public var fitFloat: CGFloat { return CGFloat(self)|~| }
}

extension CGFloat {
    /// CGFloat 屏幕尺寸大小适配
    public var fitFloat: CGFloat { self|~| }
}

extension Double {
    /// Double 屏幕尺寸大小适配
    public var fitDouble: Double { self|~| }
}

extension CGSize {
    /// CGSize 屏幕尺寸大小适配
    public var fitSize: CGSize { self|~| }
}

extension CGRect {
    /// CGRect 屏幕尺寸大小适配
    public var fitRect: CGRect { self|~| }
}

extension CGPoint {
    /// CGPoint 屏幕尺寸大小适配
    public var fitPoint: CGPoint { self|~| }
}

extension UIEdgeInsets {
    /// UIEdgeInsets 屏幕尺寸大小适配
    public var fitEdgeInset: UIEdgeInsets { self|~| }
}

// MARK: - 屏幕尺寸适配 扩展的分类 可以通过类方法调用，也可以通过以上的分类调用，更方便快捷
extension LXFit {
    /// Int 屏幕尺寸大小适配
    public static func fitFloat(_ value: Int) -> CGFloat { value.fitFloat }
    
    /// CGFloat 屏幕尺寸大小适配
    public static func fitFloat(_ value: CGFloat) -> CGFloat { value.fitFloat }
    
    /// Double 屏幕尺寸大小适配
    public static func fitDouble(_ value: Double) -> Double { value.fitDouble }
    
    /// CGPoint 屏幕尺寸大小适配
    public static func fitFoint(_ value: CGPoint) -> CGPoint { value.fitPoint }
    
    /// CGSize 屏幕尺寸大小适配
    public static func fitSize(_ value: CGSize) -> CGSize { value.fitSize }
    
    /// CGRect 屏幕尺寸大小适配
    public static func fitRect(_ value: CGRect) -> CGRect { value.fitRect }
    
    /// UIEdgeInsets 屏幕尺寸大小适配
    public static func fitEdgeInsets(_ value: UIEdgeInsets) -> UIEdgeInsets { value.fitEdgeInset }
}

// MARK: -  屏幕尺寸适配的api 当前文件可访问
extension LXFit {
    
    /// 尺寸适配
    ///
    /// - Parameters:
    ///   - value: 尺寸大小
    fileprivate static func fitSize( _ value: Double)  -> Double {
        switch LXFit.fitType {
        case .none: return value
        case .flex: return value * Double(UIScreen.main.bounds.width) / LXFit.fitWidthOfIpnone
        }
    }
}

// MARK: -  自定义运算符 operator |~|
postfix operator |~|

/// 重载运算符
fileprivate postfix func |~| (value: Double) -> Double { LXFit.fitSize(Double(value)) }

fileprivate postfix func |~| (font: UIFont) -> UIFont { font.withSize(CGFloat(font.pointSize)|~|) }

fileprivate postfix func |~| (value: Int) -> Int { Int(Double(value)|~|) }

fileprivate postfix func |~| (value: CGFloat) -> CGFloat { CGFloat(Double(value)|~|) }

fileprivate postfix func |~| (value: CGPoint) -> CGPoint { CGPoint(x: Double(value.x)|~|,y: Double(value.y)|~|) }

fileprivate postfix func |~| (value: CGSize) -> CGSize { CGSize(width:value.width|~|,height: value.height|~|) }

fileprivate postfix func |~| (value: CGRect) -> CGRect { CGRect(x:value.origin.x|~|,y: value.origin.y|~|,width:value.size.width|~|,height: value.size.height|~|) }

fileprivate postfix func |~| (value: UIEdgeInsets) -> UIEdgeInsets { UIEdgeInsets(top: value.top|~|,left: value.left|~|,bottom: value.bottom|~|,right: value.right|~|) }
