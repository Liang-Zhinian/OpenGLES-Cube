//
//  CubeModel.swift
//  airhockey
//
//  Created by Sprite on 2018/12/5.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

import Foundation

struct CubeModel {
    static var POSITION_DATA_SIZE:GLint = 3;
    static var COLOR_DATA_SIZE:GLint = 4;
    static var NORMAL_DATA_SIZE:GLint = 3;
    static var CUBE_VERTICES_DATA:[GLfloat] = [
        // front
        1, -1, 1,
        1, 1, 1,
        -1, 1, 1,
        -1, -1, 1,
        // back
        1, 1, -1,
        1, -1, -1,
        -1, -1, -1,
        -1, 1, -1,
        // left
        -1, -1, 1,
        -1, 1, 1,
        -1, 1, -1,
        -1, -1, -1,
        // right
        1, -1, -1,
        1, 1, -1,
        1, 1, 1,
        1, -1, 1,
        // top
        1, 1, 1,
        1, 1, -1,
        -1, 1, -1,
        -1, 1, 1,
        // bottom
        1, -1, -1,
        1, -1, 1,
        -1, -1, 1,
        -1, -1, -1
    ];
    static var CUBE_COLOR_DATA:[GLfloat] = [
        // R, G, B, A
        // Front face (red)
        1.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0,
        
        // Right face (green)
        0.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        
        // Back face (blue)
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        
        // Left face (yellow)
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 0.0, 1.0,
        
        // Top face (cyan)
        0.0, 1.0, 1.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        0.0, 1.0, 1.0, 1.0,
        
        // Bottom face (magenta)
        1.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 1.0
    ];
    static var CUBE_NORMAL_DATA:[GLfloat] = [
        // front
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        // back
        0, 0, -1,
        0, 0, -1,
        0, 0, -1,
        0, 0, -1,
        // left
        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,
        -1, 0, 0,
        // right
        1, 0, 0,
        1, 0, 0,
        1, 0, 0,
        // top
        0, 1, 0,
        0, 1, 0,
        0, 1, 0,
        0, 1, 0,
        // bottom
        0, -1, 0,
        0, -1, 0,
        0, -1, 0,
        0, -1, 0
    ];
}
