//
//  RTSPSceneKit.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/28/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class RTSPSceneKit: UIViewController, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var sceneView: SCNView!
    
    @IBOutlet var imageView: UIImageView!
    
    
    var rtspPlayer:RTSPPlayer!
    
    //320 426
    let rtspTestPath:String = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
    
    //1920 960
    let httpTestPath:String = "http://www.kolor.com/360-videos-files/noa-neal-graffiti-360-music-video-full-hd.mp4"
    
    var lastFrameTime:Double = 0.0
    
    var nextFrameTimer:NSTimer!
    
    var scene:SCNScene!
    
    var cameraNode:SCNNode!
    var cameraRollNode:SCNNode!
    var cameraPitchNode:SCNNode!
    var cameraYawNode:SCNNode!
    
    var imageNode:SCNNode!
    
    var motionManager: CMMotionManager?
    
    // Geometry
    var geometryNode: SCNNode = SCNNode()
    
    // Gestures
    var currentAngle: Float = 0.0
    var currentAngleX: Float = 0.0
    var currentAngleY: Float = 0.0
    
    var oldY: Float = 0.0
    var oldX: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        sceneView.backgroundColor = UIColor.darkGrayColor()
        
        setUpCamera()
        setUpImageNode()
//        setUpTestCamera()
//        setUpOmniLight()
//        setUpAmbientLigh()

//        sceneView.allowsCameraControl = true
        
        
        rtspPlayer = RTSPPlayer(videoPath: httpTestPath, usesTcp: false)
        
        if rtspPlayer != nil {
            playRTSP()
        }
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let camerasNodeAngles = getCamerasNodeAngle()
        
         cameraNode.eulerAngles = SCNVector3Make(Float(camerasNodeAngles[0]), Float(camerasNodeAngles[1]), Float(camerasNodeAngles[2]))
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension RTSPSceneKit{
    
    func setUpAmbientLigh(){
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLightTypeAmbient
        ambientLightNode.light?.color = UIColor(white: 0.67, alpha: 1.0)
        
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func setUpOmniLight(){
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLightTypeOmni
        omniLightNode.light!.color = UIColor(white: 0.25, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
    }

    func setUpTestCamera(){
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
//        cameraNode.camera?.zFar = 75
        cameraNode.position = SCNVector3Make(0,0,102.426)
        scene.rootNode.addChildNode(cameraNode)
    }

    
    func setUpImageNode(){

        imageNode = SCNNode()
        imageNode.geometry = SCNSphere(radius: 30)
        imageNode.geometry?.firstMaterial?.doubleSided = true
        
//        var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
//        transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)
//        
//        imageNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 0.0, -1.0, 0.0)
//        imageNode.geometry?.firstMaterial?.diffuse.contentsTransform = transform
        
        imageNode.position = SCNVector3(x: 0, y: 0, z: 0)
        imageNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        scene.rootNode.addChildNode(imageNode)
        
        // Add gestures on screen
//        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RTSPSceneKit.panGesture(_:)))
//        sceneView.addGestureRecognizer(panRecognizer)
        
    }
    
    func setUpCamera(){
        let camX:Float = 0.0
        let camY:Float = 0.0
        let camZ:Float = 0.0
        let zFar:Double = 40.0
        
        let camera = SCNCamera()
        camera.zFar = zFar
        
        
        scene = SCNScene()
        
        cameraNode = SCNNode()
        cameraNode.camera = camera
        
        cameraRollNode = SCNNode()
        cameraRollNode.addChildNode(cameraNode)
        
        cameraPitchNode = SCNNode()
        cameraPitchNode.addChildNode(cameraRollNode)
        
        cameraYawNode = SCNNode()
        cameraYawNode.addChildNode(cameraPitchNode)
        
        sceneView.scene = scene
        
        cameraNode.position = SCNVector3(x: camX , y: camY, z: camZ)
        
        let camerasNodeAngles = getCamerasNodeAngle()
        
        cameraNode.eulerAngles = SCNVector3Make(Float(camerasNodeAngles[0]), Float(camerasNodeAngles[1]), Float(camerasNodeAngles[2]))
        
        scene.rootNode.addChildNode(cameraYawNode)
        
        sceneView.pointOfView = cameraNode
        sceneView.playing = true
        sceneView.delegate = self
        
        // Respond to user head movement. Refreshes the position of the camera 60 times per second.
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical)
        
        // Add gestures on screen
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RTSPSceneKit.panGesture(_:)))
        view.addGestureRecognizer(panRecognizer)
        
    }
    
    
//    func panGesture(sender: UIPanGestureRecognizer) {
//        let translation = sender.translationInView(sender.view!)
//        var newAngle = (Float)(translation.x)*(Float)(M_PI)/180.0
//        
//        newAngle += currentAngle
//        
//        imageNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
//        
//        if(sender.state == UIGestureRecognizerState.Ended) {
//            currentAngle = newAngle
//        }
//    }
    
    func panGesture(sender: UIPanGestureRecognizer){
        
        let translation = sender.translationInView(sender.view!)
        let protection : Float = 2.0
        
        if (abs(Float(translation.x) - oldX) >= protection){
            let newAngleX = Float(translation.x) - oldX - protection
            currentAngleX = newAngleX/100 + currentAngleX
            oldX = Float(translation.x)
        }
        
        if (abs(Float(translation.y) - oldY) >= protection){
            let newAngleY = Float(translation.y) - oldY - protection
            currentAngleY = newAngleY/100 + currentAngleY
            oldY = Float(translation.y)
        }
        
        if(sender.state == UIGestureRecognizerState.Ended) {
            oldX = 0
            oldY = 0
        }
    }
    
    func getCamerasNodeAngle() -> [Double] {
        
        var camerasNodeAngle1: Double!              = 0.0
        var camerasNodeAngle2: Double!              = 0.0
        
        //        let orientation = UIApplication.sharedApplication().statusBarOrientation.rawValue
        //
        //        print("\(orientation)")
        //
        //        if orientation == 1 {
        //            camerasNodeAngle1                       = -M_PI_2
        //        } else if orientation == 2 {
        //            camerasNodeAngle1                       = M_PI_2
        //        } else if orientation == 3 {
        //            camerasNodeAngle1                       = 0.0
        //            camerasNodeAngle2                       = M_PI
        //        }
        
        
        switch UIDevice.currentDevice().orientation{
        case .Portrait, .Unknown:
            camerasNodeAngle1 = -M_PI_2
//            camerasNodeAngle1 = -M_PI
        case .PortraitUpsideDown:
            camerasNodeAngle1 = M_PI_2
        case .LandscapeLeft:
            camerasNodeAngle1 = 0.0
            camerasNodeAngle2 = M_PI
        default:
            break
        }
        
        return [ -M_PI_2, camerasNodeAngle1, camerasNodeAngle2]
        
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        dispatch_async(dispatch_get_main_queue()) {
            
            if let mm = self.motionManager, let motion = mm.deviceMotion {
                let currentAttitude = motion.attitude
                
                var roll: Double = currentAttitude.roll
                
                if UIDevice.currentDevice().orientation == .LandscapeRight{
                    roll = -1.0 * (-M_PI - roll)
                }
                
                self.cameraRollNode.eulerAngles.x = Float(roll) - self.currentAngleY
                self.cameraPitchNode.eulerAngles.z = Float(currentAttitude.pitch)
                self.cameraYawNode.eulerAngles.y = Float(currentAttitude.yaw) + self.currentAngleX
            }
            
        }
    }

//    default camera
//    orientation ~> 0.0,0.0,0.0,1.0
//    rotation ~> 0.0,0.0,0.0,0.0
//    position ~> 0.0,0.0,102.426
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let orientation = sceneView.pointOfView?.orientation
//        let rotation = sceneView.pointOfView?.rotation
//        let position = sceneView.pointOfView?.position
//        
//        
//        print("orientation ~> \(orientation!.x),\(orientation!.y),\(orientation!.z),\(orientation!.w)")
//        print("rotation ~> \(rotation!.x),\(rotation!.y),\(rotation!.z),\(rotation!.w)")
//        print("position ~> \(position!.x),\(position!.y),\(position!.z)")
//        
//    }
    
}


extension RTSPSceneKit{
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
        
        
        imageNode.geometry?.firstMaterial?.diffuse.contents = rtspPlayer.currentImage
        
        if let currentImage = rtspPlayer.currentImage{

            imageView.image = currentImage
            
        }
        
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
