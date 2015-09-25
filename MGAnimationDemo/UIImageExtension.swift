//
//  UIImageExtension.swift
//  MGAnimationDemo
//
//  Created by Tuan Truong on 9/23/15.
//  Copyright © 2015 Tuan Truong. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func imageAspectFillFrameWidth(frameWidth: CGFloat, frameHeight: CGFloat, crop: Bool = false) -> UIImage {
        let origialRatio = self.size.width / self.size.height
        let newRatio = frameWidth/frameHeight
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        if origialRatio > newRatio {
            newHeight = frameHeight
            newWidth = self.size.width * frameHeight / self.size.height
        }
        else {
            newWidth = frameWidth
            newHeight = self.size.height * frameWidth / self.size.width
        }
        
//        
//        if crop {
//            UIGraphicsBeginImageContextWithOptions(CGSizeMake(frameWidth, frameHeight), true, 0.0)
//            print(frameWidth - newWidth)
//            print(frameHeight - newHeight)
//            self.drawInRect(CGRectMake((frameWidth - newWidth)/2, (frameHeight - newHeight)/2, newWidth, newHeight))
//        }
//        else {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), true, 0.0)
            self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
//        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}