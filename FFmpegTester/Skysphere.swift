//
//  Skysphere.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/23/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import GLKit
import CoreGraphics
import QuartzCore

class Skysphere: NSObject, Renderable{
    fileprivate let radius: Float
    fileprivate let rows: Int
    fileprivate let columns: Int
    
    init(radius: Float, rows: Int = 20, columns: Int = 20){
        self.radius = radius
        self.rows = max(2, rows)
        self.columns = max(3, columns)
        super.init()
        
        self.prepareEffect()
        self.load()
    }
    
    deinit{
        self.unload()
    }
    
    fileprivate let effect = GLKBaseEffect()
    fileprivate var vertices = [TextureVertex]()
    fileprivate var indices = [UInt32]()
    fileprivate var vertexArray: GLuint = 0
    fileprivate var vertexBuffer: GLuint = 0
    fileprivate var indexBuffer: GLuint = 0
    fileprivate var texture: GLuint = 0
    
    fileprivate func prepareEffect(){
        self.effect.colorMaterialEnabled = GLboolean(GL_TRUE)
        self.effect.useConstantColor = GLboolean(GL_FALSE)
    }
    
    fileprivate func load(){
        self.unload()
        
        // Generate vertices and indices
        self.generateVertices()
        self.generateIndicesForTriangleStrip()
        
        // Create OpenGL's buffers
        glGenVertexArraysOES(1, &self.vertexArray)
        glBindVertexArrayOES(self.vertexArray)
        
        glGenBuffers(1, &self.vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TextureVertex>.size * self.vertices.count, self.vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(1, &self.indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<UInt>.size * self.indices.count, self.indices, GLenum(GL_STATIC_DRAW))
        
        
        // Describe vertex format to OpenGL
        let ptr = UnsafePointer<GLfloat>(bitPattern: 0)
        let sizeOfVertex = GLsizei(MemoryLayout<TextureVertex>.size)
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), sizeOfVertex, ptr)
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), GLint(2), GLenum(GL_FLOAT), GLboolean(GL_FALSE), sizeOfVertex, ptr?.advanced(by: 3))
        
        
        glBindVertexArrayOES(0)
    }
    
    fileprivate func unload(){
        self.vertices.removeAll()
        self.indices.removeAll()
        
        glDeleteBuffers(1, &self.vertexBuffer)
        glDeleteBuffers(1, &self.indexBuffer)
        glDeleteVertexArraysOES(1, &self.vertexArray)
        glDeleteTextures(1, &self.texture)
    }
    
    fileprivate func generateVertices(){
        let deltaAlpha = Float(2.0 * M_PI) / Float(self.columns)
        let deltaBeta = Float(M_PI) / Float(self.rows)
        for row in 0...self.rows{
            let beta = Float(row) * deltaBeta
            let y = self.radius * cosf(beta)
            let tv = Float(row) / Float(self.rows)
            for col in 0...self.columns
            {
                let alpha = Float(col) * deltaAlpha
                let x = self.radius * sinf(beta) * cosf(alpha)
                let z = self.radius * sinf(beta) * sinf(alpha)
                
                let position = GLKVector3(v: (x, y, z))
                let tu = Float(col) / Float(self.columns)
                
                let vertex = TextureVertex(position: position.v, texture: (tu, tv))
                self.vertices.append(vertex)
            }
        }
    }
    
    fileprivate func generateIndicesForTriangleStrip(){
        for row in 1...self.rows{
            let topRow = row - 1
            let topIndex = (self.columns + 1) * topRow
            let bottomIndex = topIndex + (self.columns + 1)
            for col in 0...self.columns{
                self.indices.append(UInt32(topIndex + col))
                self.indices.append(UInt32(bottomIndex + col))
            }
            
            self.indices.append(UInt32(topIndex))
            self.indices.append(UInt32(bottomIndex))
        }
    }
    
    // MARK: - Texture
    func loadTexture(_ image: UIImage?){
        guard let image = image else{
            return
        }
        
        guard let width = image.cgImage?.width else {
            return
        }
        
        guard let height = image.cgImage?.height else {
            return
        }
        
        
        let imageData = UnsafeMutablePointer<GLubyte>.allocate(capacity: Int(width * height * 4))
        
        let imageColorSpace = image.cgImage?.colorSpace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let gc = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: imageColorSpace!, bitmapInfo: bitmapInfo.rawValue)
        gc?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        self.updateTexture(CGSize(width: width, height: height), imageData: imageData)
        free(imageData)
    }
    
    func updateTexture(_ size: CGSize, imageData: UnsafeMutableRawPointer){
        
        if self.texture == 0{
            glGenTextures(1, &self.texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
            
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_REPEAT))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_REPEAT))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        }
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(size.width), GLsizei(size.height), 0, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), imageData)
    }
    
    // MARK: - Renderable
    func render(_ camera: Camera){
        guard self.texture != 0 else{
            return
        }
        
        glBindVertexArrayOES(self.vertexArray)
        
        self.effect.transform.projectionMatrix = camera.projection
        self.effect.transform.modelviewMatrix = camera.view
        self.effect.texture2d0.enabled = GLboolean(GL_TRUE)
        self.effect.texture2d0.name = self.texture
        self.effect.prepareToDraw()
        
        let bufferOffset = UnsafePointer<UInt>(bitPattern: 0)
        glDrawElements(GLenum(GL_TRIANGLE_STRIP), GLsizei(self.indices.count - 2), GLenum(GL_UNSIGNED_INT), bufferOffset)
        
        glBindVertexArrayOES(0)
    }
}

