//
//  VideoExportInput.swift
//  MP_ARNewYearIOS
//
//  Created by Tuan Truong on 7/22/15.
//  Copyright (c) 2015 com.framgia. All rights reserved.
//

import UIKit
import AVFoundation

class VideoExportInput: NSObject {
    var videoAsset: AVAsset!
    var audioAsset: AVAsset?
    
    var range: CMTimeRange!
    var videoFrame: CGRect!
    
    var videoVolume: Float = 1
    var bgmVolume: Float = 1
    
    var videoPath: String!
    
    var animationLayer: CALayer?
}
