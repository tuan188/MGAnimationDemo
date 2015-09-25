//
//  AnimationService.swift
//  MGAnimationDemo
//
//  Created by Tuan Truong on 9/25/15.
//  Copyright © 2015 Tuan Truong. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class AnimationService: NSObject {
    func animationLayerFromImages(images: [UIImage], texts: [String], frameSize: CGSize, startTime: Double = CACurrentMediaTime()) -> CALayer {
        let parentLayer = CALayer()
        
        let animationTime: Double = 3
        
        let fadeTime: Double = 1
        let backgroundOpacity: Float = 0.5
        
        for (index, image) in images.enumerate() {
            let bgLayer = CALayer()
            bgLayer.contents = image.CGImage
            bgLayer.frame = CGRectMake(0, 0, frameSize.width, frameSize.height)
            bgLayer.contentsGravity = kCAGravityResizeAspectFill
            bgLayer.opacity = backgroundOpacity
            
            let contentLayer = CALayer()
            contentLayer.contents = image.CGImage
            contentLayer.frame = CGRectMake(0, 0, frameSize.width, frameSize.height)
            contentLayer.contentsGravity = kCAGravityTop
            
            let animation = animationWithDuration(animationTime, autoReverse: false, fromValue: nil, toValue: contentLayer.position.x + 150, beginTime: (Double(index) * animationTime) + startTime, keyPath: "position.x", repeatCount: 0, fillMode: nil)
            
            if index > 0 {
                bgLayer.opacity = 0
                contentLayer.opacity = 0
                let fadeInAnimation = animationWithDuration(fadeTime, autoReverse: false, fromValue: 0, toValue: 1, beginTime: (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
                
                let bgFadeInAnimation = animationWithDuration(fadeTime, autoReverse: false, fromValue: 0, toValue: backgroundOpacity, beginTime: (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
                
                bgLayer.addAnimation(bgFadeInAnimation, forKey: "bgFadeIn")
                contentLayer.addAnimation(fadeInAnimation, forKey: "fadeIn")
            }
            
            let fadeOutAnimation = animationWithDuration(fadeTime, autoReverse: false, fromValue: 1, toValue: 0, beginTime: animationTime + (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
            
            let bgFadeOutAnimation = animationWithDuration(fadeTime, autoReverse: false, fromValue: backgroundOpacity, toValue: 0, beginTime: animationTime + (Double(index) * animationTime) + startTime - fadeTime, keyPath: "opacity", repeatCount: 0, fillMode: kCAFillModeForwards)
            
            
            contentLayer.addAnimation(fadeOutAnimation, forKey: "fadeOut")
            contentLayer.addAnimation(animation, forKey: "animate")
            
            bgLayer.addAnimation(bgFadeOutAnimation, forKey: "bgFadeOut")
            
            
            
            parentLayer.addSublayer(bgLayer)
            parentLayer.addSublayer(contentLayer)
        }
        
        return parentLayer
    }
    
    private func animationWithDuration(duration: Double, autoReverse: Bool, fromValue: AnyObject?, toValue: AnyObject?, beginTime: Double, keyPath: String, repeatCount: Float, fillMode: String?) -> CAAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = keyPath
        if let fromValue = fromValue {
            animation.fromValue = fromValue
        }
        animation.toValue = toValue
        
        if let fillMode = fillMode{
            animation.fillMode = fillMode
        }
        animation.beginTime = beginTime
        animation.autoreverses = autoReverse
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.removedOnCompletion = false
        
        return animation
    }
}