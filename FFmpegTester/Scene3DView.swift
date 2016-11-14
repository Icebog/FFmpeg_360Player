//
//  Scene3DView.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/23/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import GLKit

class Scene3DView: GLKView{
    fileprivate var sceneObjects = [NSObject]()
    
    // MARK: - Properties
    var camera = Camera(){
        didSet { self.setNeedsDisplay() }
    }
    
    // MARK: - Public interface
    func addSceneObject(_ object: NSObject){
        if !self.sceneObjects.contains(object){
            self.sceneObjects.append(object)
        }
    }
    
    func removeSceneObject(_ object: NSObject){
        if let index = self.sceneObjects.index(of: object){
            self.sceneObjects.remove(at: index)
        }
    }
    
    // MARK: - Overriden interface
    override func layoutSubviews(){
        super.layoutSubviews()
        self.camera.aspect = fabsf(Float(self.bounds.size.width / self.bounds.size.height))
    }
    
    override func display(){
        super.display()
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let objects = self.sceneObjects
        for object in objects{
            if let renderable = object as? Renderable{
                renderable.render(self.camera)
            }
        }
    }
}
