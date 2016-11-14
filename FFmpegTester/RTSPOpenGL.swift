//
//  RTSPOpenGL.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/24/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import UIKit
import GLKit

class RTSPOpenGL: GLKViewController {
    
    @IBOutlet var scene3DView: Scene3DView!
    
    @IBOutlet var imageView: UIImageView!
    
    fileprivate var context: EAGLContext!
    
    fileprivate var skysphere: Skysphere!
    
    var rtspPlayer:RTSPPlayer!
    
    //320 426
    let rtspTestPath:String = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
    
    //1920 960
    let httpTestPath:String = "http://www.kolor.com/360-videos-files/noa-neal-graffiti-360-music-video-full-hd.mp4"
    
    var lastFrameTime:Double = 0.0
    
    var nextFrameTimer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureContext()
        configureView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        //RTSP release
        if nextFrameTimer != nil {
            nextFrameTimer.invalidate()
        }
        
        if rtspPlayer != nil {
            rtspPlayer.releaseResources()
        }
        
        //OpenGL release
        if EAGLContext.current() == self.context{
            EAGLContext.setCurrent(nil)
        }
    }
    
    
    // This is one of update variants used by GLKViewController.
    // See comment to GLKViewControllerDelegate.glkViewControllerUpdate for more info.
    func update(){
        
    }
    
}

//MARK: - Actions
extension RTSPOpenGL{
    
    func panGestureAction(_ sender: UIPanGestureRecognizer){
        if (sender.state == .changed){
            let dt = CGFloat(self.timeSinceLastUpdate)
            let velocity = sender.velocity(in: sender.view)
            let translation = CGPoint(x: velocity.x * dt, y: velocity.y * dt)
            
            let camera = self.scene3DView.camera
            let scale = Float(UIScreen.main.scale)
            let dh = Float(translation.x / self.view.frame.size.width) * camera.fovRadians * scale
            let dv = Float(translation.y / self.view.frame.size.height) * camera.fovRadians * scale
            camera.yaw += dh
            camera.pitch += dv
        }
    }
    
}

//MARK: - RTSP Controller
extension RTSPOpenGL{
    func playRTSP(){
        lastFrameTime = -1
        rtspPlayer.seekTime(0.0)
        
        if nextFrameTimer != nil {
            nextFrameTimer.invalidate()
        }
        
        nextFrameTimer = Timer.scheduledTimer(timeInterval: 1.0 / rtspPlayer.fps, target: self, selector: #selector(RTSPPanel.displayNextFrame(_:)), userInfo: nil, repeats: true)
        
    }
    
    func displayNextFrame(_ timer:Timer){
        let startTime:TimeInterval = Date().timeIntervalSinceReferenceDate
        
        if !rtspPlayer.stepFrame() {
            timer.invalidate()
            return
        }
        
        imageView.image = rtspPlayer.currentImage
        
        
        if let currentImage:UIImage = rtspPlayer.currentImage{
            
            if let cgiImage = currentImage.cgImage {
                

                rtspPlayer.baseAddress(from: cgiImage, completion: { (size, baseAddress) in
                    
                    self.skysphere.updateTexture(size, imageData: baseAddress)
                    
                })
                        
            }
        }
        
        let frameTime:Double = 1.0 / (Date().timeIntervalSinceReferenceDate / startTime)
        
        if lastFrameTime < 0.0 {
            lastFrameTime = frameTime
        }else{
            lastFrameTime = getLERP(frameTime, lastFrameTime: lastFrameTime, factor: 0.8)
        }
        
        //        print("fps: \(rtspPlayer.fps)")
    }
    
    fileprivate func getLERP(_ frameTime:Double,lastFrameTime:Double,factor:Double) -> Double {
        //        LERP(A,B,C) ((A)*(1.0-C)+(B)*C)
        return frameTime * (1.0 - factor) + lastFrameTime * factor
    }
}

//MARK: - OpenGL Controller
extension RTSPOpenGL{
        fileprivate func configureContext(){
            context = EAGLContext(api: EAGLRenderingAPI.openGLES3)
            EAGLContext.setCurrent(context)
        }
    
        fileprivate func configureView(){
            self.scene3DView.context = self.context
    
            self.skysphere = Skysphere(radius: 60)
            self.scene3DView.addSceneObject(self.skysphere)
            
            // Pan gesture recognizer
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(RTSPOpenGL.panGestureAction(_:)))
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            self.view.addGestureRecognizer(panGesture)
        }
    
}

