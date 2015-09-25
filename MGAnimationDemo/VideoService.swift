//
//  VideoService.swift
//  MGAnimationDemo
//
//  Created by Tuan Truong on 9/24/15.
//  Copyright © 2015 Tuan Truong. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class VideoService: NSObject {
    func makeBlankVideo(blankImage: UIImage, videoSize: CGSize, outputPath: String, duration: Double, complete: () -> Void) {
        
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(outputPath)
        }
        catch {
            
        }
        
//        if fileManager.fileExistsAtPath(outputPath) {
//            complete()
//            return
//        }
        
        let fps: Double = 30
        
        // Start building video from defined frames
        do {
            
            let videoWriter = try AVAssetWriter(URL: NSURL(fileURLWithPath: outputPath), fileType: AVFileTypeQuickTimeMovie)
            
            let videoSettings = [
                AVVideoCodecKey : AVVideoCodecH264,
                AVVideoWidthKey : NSNumber(float: Float(videoSize.width)),
                AVVideoHeightKey : NSNumber(float: Float(videoSize.height))
            ]
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriter.addInput(videoWriterInput)
            
            // Start a session:
            videoWriter.startWriting()
            videoWriter.startSessionAtSourceTime(kCMTimeZero)
            
            let buffer: CVPixelBufferRef = pixelBufferFromCGImage(blankImage.CGImage!)
            
            var appendOK = true
            var i: Double = 0
            while appendOK && i < duration {
                if adaptor.assetWriterInput.readyForMoreMediaData {
                    let frameTime = CMTimeMake(Int64(i*fps), Int32(fps))
                    appendOK = adaptor.appendPixelBuffer(buffer, withPresentationTime: frameTime)
                    if !appendOK {
                        print("append error")
                    }
                }
                else {
                    print("adapter not ready")
                    NSThread.sleepForTimeInterval(0.1)
                }
                i++
            }
            
            videoWriter.finishWritingWithCompletionHandler({ () -> Void in
                complete()
            })
        }
        catch {
            print("AVAssetWriter error")
        }
    }
    
    private func pixelBufferFromCGImage(image: CGImageRef) -> CVPixelBufferRef {
        let size = UIImage(CGImage: image).size
        let options: Dictionary = [ kCVPixelBufferCGImageCompatibilityKey as String : NSNumber(bool: true), kCVPixelBufferCGBitmapContextCompatibilityKey as String : NSNumber(bool: true) ]
        var pxbuffer: CVPixelBufferRef?
        let _ = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options, &pxbuffer)
        
        CVPixelBufferLockBaseAddress(pxbuffer!, 0)
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(pxdata, Int(size.width), Int(size.height), 8, 4 * Int(size.width), rgbColorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        CGContextConcatCTM(context, CGAffineTransformMakeRotation(0))
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(size.width), CGFloat(size.height)), image)
        
        CVPixelBufferUnlockBaseAddress(pxbuffer!, 0);
        
        return pxbuffer!
    }
    
}
