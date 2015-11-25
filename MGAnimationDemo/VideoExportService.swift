//
//  VideoService.swift
//  MP_ARNewYearIOS
//
//  Created by Truong Anh Tuan on 6/2/15.
//  Copyright (c) 2015 com.framgia. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class VideoExportService: NSObject {
    
    weak var delegate: VideoExportServiceDelegate?
    private var progressTimer: NSTimer?
    private var exporter: AVAssetExportSession!
    private var input: VideoExportInput!
    
    func exportVideoWithInput(input: VideoExportInput) {
        self.input = input
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.exportVideoAsync()
        }
    }
    
    private func exportVideoAsync() {
        
        var inputParams = [AVAudioMixInputParameters]()
        
        // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        //audio
//        let videoAudioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
//        if input.videoAsset.tracksWithMediaType(AVMediaTypeAudio).count > 0 {
//            do {
//                try videoAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, input.videoAsset.duration), ofTrack: input.videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0] , atTime: kCMTimeZero)
//            } catch _ {
//            }
//        }
//        
//        let videoAudioParams = self.audioParamsForTrack(videoAudioTrack, volume: input.videoVolume)
//        inputParams.append(videoAudioParams)
        
        // 3 - Video track
        let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let videoAssetTrack = input.videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0]  
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, input.videoAsset.duration), ofTrack: videoAssetTrack, atTime: kCMTimeZero)
        } catch _ {
        }
        
        // 3.0 - Audio track
        if let audioAsset = input.audioAsset {
            let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            do {
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset.duration), ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0] , atTime: kCMTimeZero)
            } catch _ {
            }
            let audioParams = self.audioParamsForTrack(audioTrack, volume: input.bgmVolume)
            inputParams.append(audioParams)
        }
        
        // 3.1 - Create AVMutableVideoCompositionInstruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, input.videoAsset.duration)
        
        // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
  
        videolayerInstruction.setTransform(videoAssetTrack.preferredTransform, atTime: kCMTimeZero)
        videolayerInstruction.setOpacity(0.0, atTime: input.videoAsset.duration)
        
        
        // 3.3 - Add instructions
        mainInstruction.layerInstructions = [videolayerInstruction]
        let mainCompositionInst = AVMutableVideoComposition()
        let naturalSize = videoAssetTrack.naturalSize
        
        mainCompositionInst.renderSize = naturalSize
        mainCompositionInst.instructions = [mainInstruction]
        print(Int32(CMTimeGetSeconds(input.videoAsset.duration)))
//        mainCompositionInst.frameDuration = CMTimeMake(Int64(1), Int32(CMTimeGetSeconds(input.videoAsset.duration)))
        
        mainCompositionInst.frameDuration = CMTimeMake(1, 60)

        
        
        self.applyVideoEffectsToComposition(mainCompositionInst, size: naturalSize)
        
        // 4 - Get path

        let tempPath = input.videoPath
        let url = NSURL(fileURLWithPath: tempPath)
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = inputParams as [AVAudioMixInputParameters]
        
        // 5 - Create exporter
        exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter.timeRange = input.range
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.videoComposition = mainCompositionInst
        exporter.audioMix = audioMix
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("timerTick"), userInfo: nil, repeats: true)
        }
        
        self.exporter.exportAsynchronouslyWithCompletionHandler { [weak self]() -> Void in
            self?.finishExportAtFileUrl(url)
        }
    }
    
    func timerTick() {
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.videoExportServiceExportProgress(self.exporter.progress)
        }
        
    }
    
    private func finishExportAtFileUrl(url: NSURL) {
        dispatch_async(dispatch_get_main_queue()) {
            self.progressTimer?.invalidate()
            if self.exporter.status == AVAssetExportSessionStatus.Completed {
                self.delegate?.videoExportServiceExportSuccess()
            }
            else {
                self.delegate?.videoExportServiceExportFailedWithError(self.exporter.error!)
            }
        }
        
    }
    
    private func audioParamsForTrack(track: AVAssetTrack, volume: Float) -> AVAudioMixInputParameters {
        let audioInputParams = AVMutableAudioMixInputParameters(track: track)
        audioInputParams.setVolume(volume, atTime: kCMTimeZero)
        audioInputParams.trackID = track.trackID
        return audioInputParams.copy() as! AVAudioMixInputParameters
    }
    
    private func applyVideoEffectsToComposition(composition: AVMutableVideoComposition, size: CGSize) {
        let videoLayer = CALayer()
        videoLayer.frame = input.videoFrame
        
        let parentLayer = CALayer()
        parentLayer.frame = input.videoFrame
        parentLayer.addSublayer(videoLayer)
        if let animationLayer = input.animationLayer {
            parentLayer.addSublayer(animationLayer)
        }
        
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        
    }
    
}
