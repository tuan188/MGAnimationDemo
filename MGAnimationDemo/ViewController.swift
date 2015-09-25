//
//  ViewController.swift
//  MGAnimationDemo
//
//  Created by Tuan Truong on 9/23/15.
//  Copyright © 2015 Tuan Truong. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, VideoExportServiceDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var animationView: UIView!
    
    var playerViewController: MPMoviePlayerViewController?
    
    var localBlankVideoPath:  String {
        get {
            return kDocumentsPath.stringByAppendingPathComponent("video".stringByAppendingPathExtension("mp4")!)
        }
    }
    
    var videoID = NSUUID().UUIDString
    
    var localVideoPath:  String {
        get {
            return kDocumentsPath.stringByAppendingPathComponent(videoID.stringByAppendingPathExtension("mp4")!)
        }
    }
    
    let videoService = VideoService()
    let videoExportService = VideoExportService()
    let animationService = AnimationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        videoExportService.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func createAnimation() {
        if animationView.layer.sublayers != nil {
            for layer in animationView.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        
        let layer = animationService.animationLayerFromImages([ UIImage(named: "p1")!, UIImage(named: "p2")!, UIImage(named: "l1")!, UIImage(named: "l2")!, UIImage(named: "l3")!], texts: [], frameSize: animationView.bounds.size)
        
        
        animationView.layer.addSublayer(layer)
        
    }

    @IBAction func onStartButtonClicked(sender: AnyObject) {
        createAnimation()
    }
    
    @IBAction func onExportButtonClicked(sender: AnyObject) {
        progressView.progress = 0
        
        videoService.makeBlankVideo(UIImage(named: "whiteBg")!, videoSize: CGSizeMake(300, 200), outputPath: localBlankVideoPath, duration: 15) { () -> Void in
            print(self.localBlankVideoPath)
            self.exportVideo()
        }
    }
    
    @IBAction func onPlayButtonClicked(sender: AnyObject) {
        playVideo()
    }
    
    private func playVideo() {
        let url = NSURL(fileURLWithPath: self.localVideoPath)
        self.playerViewController = MPMoviePlayerViewController(contentURL: url)
        self.navigationController?.presentMoviePlayerViewControllerAnimated(self.playerViewController!)
    }
    
    private func exportVideo() {
        let input = VideoExportInput()
        videoID = NSUUID().UUIDString
        input.videoPath = localVideoPath
        
        let asset = AVAsset(URL: NSURL(fileURLWithPath: self.localBlankVideoPath))
        input.videoAsset = asset
        input.videoFrame = self.animationView.bounds
        input.range = CMTimeRangeMake(kCMTimeZero, asset.duration)
        input.animationLayer = animationService.animationLayerFromImages([ UIImage(named: "p1")!, UIImage(named: "p2")!, UIImage(named: "l1")!, UIImage(named: "l2")!, UIImage(named: "l3")!], texts: [], frameSize: animationView.bounds.size, startTime: AVCoreAnimationBeginTimeAtZero)
        
        
        self.videoExportService.exportVideoWithInput(input)
    }
    
    // MARK: - VideoExportServiceDelegate
    
    func videoExportServiceExportSuccess() {
        print("Success")
   
        dispatch_async(dispatch_get_main_queue()) {
            self.playVideo()
        }
       
    }
    
    func videoExportServiceExportFailedWithError(error: NSError) {
        print(error)
    }
    
    func videoExportServiceExportProgress(progress: Float) {
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = progress
        }
    }
}

