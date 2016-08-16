//
//  RTSPPanel.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/23/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import UIKit


class RTSPPanel: UIViewController {
    
//    @IBOutlet private var scene3DView: Scene3DView!
    
    @IBOutlet var imageView: UIImageView!
    
//    private var context: EAGLContext!
    
//    private var skysphere: Skysphere!
    
    var rtspPlayer:RTSPPlayer!
    
    //320 426
    let rtspTestPath:String = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
    
    //1920 960
    let httpTestPath:String = "http://www.kolor.com/360-videos-files/noa-neal-graffiti-360-music-video-full-hd.mp4"
    
    var lastFrameTime:Double = 0.0
    
    var nextFrameTimer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        configureContext()
//        configureView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        rtspPlayer = RTSPPlayer(videoPath: rtspTestPath, usesTcp: false)
//        rtspPlayer.outputHeight = 960
//        rtspPlayer.outputWidth = 1920
        
        if rtspPlayer != nil {
            playRTSP()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        //RTSP release
        if nextFrameTimer != nil {
            nextFrameTimer.invalidate()
        }
        
        if rtspPlayer != nil {
            rtspPlayer.releaseResources()
        }
        
        //OpenGL release
//        if EAGLContext.currentContext() == self.context{
//            EAGLContext.setCurrentContext(nil)
//        }
    }
    
    
    // This is one of update variants used by GLKViewController.
    // See comment to GLKViewControllerDelegate.glkViewControllerUpdate for more info.
    func update(){
        
        
//        if rtspPlayer != nil {
//            print("fps ~> \(rtspPlayer.fps)")
//            
//            if !rtspPlayer.stepFrame() {
//                return
//            }
//            
//            if let currentImage:UIImage = rtspPlayer.currentImage{
//                
//                if let cgiImage = currentImage.CGImage {
//                    
//                    let baseAddress = rtspPlayer.baseAddressFromCGImage(cgiImage)
//                    
//                    skysphere.updateTexture(currentImage.size, imageData: baseAddress)
//                    
//                }
//            }
//            
//        }
        
        
//        CGImageRef imageRef=[myImage CGImage];
//        CVImageBufferRef pixelBuffer = [self pixelBufferFromCGImage:imageRef];
    }

}

//MARK: - Actions
extension RTSPPanel{
    
    @IBAction func cancelPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func panGestureAction(sender: UIPanGestureRecognizer){
//        if (sender.state == .Changed){
//            let dt = CGFloat(self.timeSinceLastUpdate)
//            let velocity = sender.velocityInView(sender.view)
//            let translation = CGPoint(x: velocity.x * dt, y: velocity.y * dt)
//            
//            let camera = self.scene3DView.camera
//            let scale = Float(UIScreen.mainScreen().scale)
//            let dh = Float(translation.x / self.view.frame.size.width) * camera.fovRadians * scale
//            let dv = Float(translation.y / self.view.frame.size.height) * camera.fovRadians * scale
//            camera.yaw += dh
//            camera.pitch += dv
//        }
//    }

}

//MARK: - RTSP Controller
extension RTSPPanel{
    func playRTSP(){
        lastFrameTime = -1
        rtspPlayer.seekTime(0.0)
        
        if nextFrameTimer != nil {
            nextFrameTimer.invalidate()
        }
        
        nextFrameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / rtspPlayer.fps, target: self, selector: #selector(RTSPPanel.displayNextFrame(_:)), userInfo: nil, repeats: true)
       
    }
    
    func displayNextFrame(timer:NSTimer){
        let startTime:NSTimeInterval = NSDate().timeIntervalSinceReferenceDate
        
        if !rtspPlayer.stepFrame() {
            timer.invalidate()
            return
        }
        
        imageView.image = rtspPlayer.currentImage
        
        let frameTime:Double = 1.0 / (NSDate().timeIntervalSinceReferenceDate / startTime)
        
        if lastFrameTime < 0.0 {
            lastFrameTime = frameTime
        }else{
            lastFrameTime = getLERP(frameTime, lastFrameTime: lastFrameTime, factor: 0.8)
        }
        
//        print("fps: \(rtspPlayer.fps)")
    }
    
    private func getLERP(frameTime:Double,lastFrameTime:Double,factor:Double) -> Double {
//        LERP(A,B,C) ((A)*(1.0-C)+(B)*C)
        return frameTime * (1.0 - factor) + lastFrameTime * factor
    }
}

//MARK: - OpenGL Controller
extension RTSPPanel{
//    private func configureContext(){
//        context = EAGLContext(API: EAGLRenderingAPI.OpenGLES3)
//        EAGLContext.setCurrentContext(context)
//    }
//    
//    private func configureView(){
//        self.scene3DView.context = self.context
//        
//        self.skysphere = Skysphere(radius: 60)
//        self.scene3DView.addSceneObject(self.skysphere)
//        
//        // Pan gesture recognizer
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(RTSPPanel.panGestureAction(_:)))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.maximumNumberOfTouches = 1
//        self.view.addGestureRecognizer(panGesture)
//    }
    
}
