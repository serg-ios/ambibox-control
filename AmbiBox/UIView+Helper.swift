//
//  UIView+Helper.swift
//  iOS Prismatik
//
//  Created by Sergio Rodríguez Rama on 25/11/2018.
//  Copyright © 2018 Sergio Rodríguez Rama. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func getColourFromPoint(point: CGPoint) -> UIColor? {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        var pixelData: [UInt8] = [0, 0, 0, 0]
        guard let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context)
        guard pixelData.count > 3 else { return nil}
        let red: CGFloat = CGFloat(pixelData[0]) / 255.0
        let green: CGFloat = CGFloat(pixelData[1]) / 255.0
        let blue: CGFloat = CGFloat(pixelData[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixelData[3]) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
