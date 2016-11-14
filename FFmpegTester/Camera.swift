//
//  Camera.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/23/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import GLKit

class Camera: NSObject {
    
    fileprivate var projectionMatrix = GLKMatrix4()
    fileprivate var viewMatrix = GLKMatrix4()
    
    // MARK: - Projection matrix properties
    var fovRadians: Float = GLKMathDegreesToRadians(65.0){
        didSet { self.updateProjectionMatrix() }
    }
    
    var aspect: Float = (320.0 / 480.0){
        didSet { self.updateProjectionMatrix() }
    }
    
    var nearZ: Float = 0.1{
        didSet { self.updateProjectionMatrix() }
    }
    
    var farZ: Float = 100.0
        {
        didSet { self.updateProjectionMatrix() }
    }
    
    // MARK: - View matrix - yaw, pitch
    var yaw: Float = 0.0{
        didSet { self.updateViewMatrix() }
    }
    
    var pitch: Float = 0.0{
        didSet { self.updateViewMatrix() }
    }
    
    // MARK: - Matrix getters
    var projection: GLKMatrix4{
        get { return self.projectionMatrix }
    }
    
    var view: GLKMatrix4{
        get { return self.viewMatrix }
    }
    
    // MARK: - Init
    init(fovRadians: Float = GLKMathDegreesToRadians(65.0), aspect: Float = (320.0 / 480.0), nearZ: Float = 0.1, farZ: Float = 100){
        super.init()
        self.fovRadians = fovRadians
        self.aspect = aspect
        self.nearZ = nearZ
        self.farZ = farZ
        self.updateProjectionMatrix()
        self.updateViewMatrix()
    }
    
    // MARK: - Updaters
    fileprivate func updateProjectionMatrix(){
        self.projectionMatrix = GLKMatrix4MakePerspective(self.fovRadians, self.aspect, self.nearZ, self.farZ)
    }
    
    fileprivate func updateViewMatrix(){
        let cosPitch = cosf(self.pitch)
        let sinPitch = sinf(self.pitch)
        let cosYaw = cosf(self.yaw)
        let sinYaw = sinf(self.yaw)
        
        let xaxis = GLKVector3(v: (cosYaw, 0, -sinYaw))
        let yaxis = GLKVector3(v: (sinYaw * sinPitch, cosPitch, cosYaw * sinPitch))
        let zaxis = GLKVector3(v: (sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw))
        
        self.viewMatrix = GLKMatrix4(m:
            (
                xaxis.x, yaxis.x, zaxis.x, 0,
                xaxis.y, yaxis.y, zaxis.y, 0,
                xaxis.z, yaxis.z, zaxis.z, 0,
                0, 0, 0, 1
        ))
    }


}
