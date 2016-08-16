//
//  Vertex.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/23/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import GLKit

typealias VertexPositionComponent = (GLfloat, GLfloat, GLfloat)
typealias VertexTextureCoordinateComponent = (GLfloat, GLfloat)

struct TextureVertex{
    var position: VertexPositionComponent = (0, 0, 0)
    var texture: VertexTextureCoordinateComponent = (0, 0)
}
