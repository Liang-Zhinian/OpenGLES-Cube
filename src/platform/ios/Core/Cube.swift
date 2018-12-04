//
//  Cube.swift
//  airhockey
//
//  Created by Sprite on 2018/12/2.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit


class Cube : NSObject {
    static var POSITION_DATA_SIZE:GLint = 3;
    static var COLOR_DATA_SIZE:GLint = 4;
    static var NORMAL_DATA_SIZE:GLint = 3;
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
    
    /// Element buffer object. Stores the indices that tell OpenGL what vertices to draw.
    var ebo = GLuint()
    
    /// Vertex buffer object. Stores our vertex information within the GPU's memory.
    var vbo = GLuint()
    
    /// Vertex array object. Stores vertex attribute calls that facilitate future drawing. Instead of having to bind/unbind
    /// several buffers constantly to perform drawn, you can simply bind your VAO, make the vertex attribute cals you would
    /// to draw elements on screen, and then whenever you want to draw you simply bind your VAO and it stores those other
    /// vertex attribute calls.
    var vao = GLuint()
    
    var Vertices:[Vertex] = []
    
    var Indices:[GLubyte] = [
        // Front
        0, 1, 2,
        2, 3, 0,
        // Back
        4, 6, 5,
        4, 6, 7,
        // Left
        8, 9, 10,
        10, 11, 8,
        // Right
        12, 13, 14,
        14, 15, 12,
        // Top
        16, 17, 18,
        18, 19, 16,
        // Bottom
        20, 21, 22,
        22, 23, 20
    ]
    
    public var texture:Texture!
    
    override init() {
        super.init();
        
        let ves = VertexGenerator.genOneCubeVertices(position: GLKVector3Make(0, 0, 0), color: (1,0.5,0,1))
        let ins = VertexGenerator.genOneCubeIndices(index: 0)
        Vertices = []
        Indices = []
        Vertices.append(contentsOf: ves)
        Indices.append(contentsOf: ins)
        
    }
    
    func createVertexBuffers() {
        // Generate and bind a vertex array object.
//        vao = Utils.createVAO()
        
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
        
        // VBO
        let vertexBufferSize = Vertices.count * vertexSize
        vbo = Utils.createVBO(vertexBufferSize, &Vertices, GLenum(GL_DYNAMIC_DRAW));
        
        // EBO
        let indexBufferSize = Indices.size()
        ebo = Utils.createEBO(indexBufferSize, &Indices, GLenum(GL_DYNAMIC_DRAW));
        
        // Helper variables to identify the position and color attributes for OpenGL calls.
        let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
        let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
        let vertexAttribNormal = GLuint(GLKVertexAttrib.normal.rawValue)
        let vertexAttribTexCoord0 = GLuint(GLKVertexAttrib.texCoord0.rawValue)
        
        // The byte offset, in memory, of our color information within a Vertex object.
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        // Swift pointer object that stores the offset of the color information within our Vertex structure.
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        let normalOffset = MemoryLayout<GLfloat>.stride * 9
        let normalOffsetPointer = UnsafePointer<Int>(bitPattern: normalOffset)
        // Enable the position vertex attribute to then specify information about how the position of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribPosition)
        glVertexAttribPointer(vertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), nil)
        
        // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribColor)
        glVertexAttribPointer(vertexAttribColor, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), colorOffsetPointer)
        
        glEnableVertexAttribArray(vertexAttribNormal)
        glVertexAttribPointer(vertexAttribNormal, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), normalOffsetPointer)
        
        //Textures
        let textureOffset = MemoryLayout<GLfloat>.stride * 7
        let textureOffsetPointer = UnsafePointer<Int>(bitPattern: textureOffset)
        glEnableVertexAttribArray(vertexAttribTexCoord0);
        glVertexAttribPointer(vertexAttribTexCoord0, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), textureOffsetPointer);
        
        glActiveTexture(GLenum(GL_TEXTURE0));
        configureDefaultTexture();
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArrayOES(0)
    }
    
    func configureDefaultTexture() {
        texture = Texture(pathForResource: "texture_numbers", ofType: "png")
    }

    
    func render() {
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArrayOES(0)
    }
    
    func deleteBuffers() {
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
    }
    
    func intersect(ray:Ray!) -> [GLKVector3] {
        var result:[GLKVector3] = []
        for index in (1 ..< (Indices.count+1)) {
            if index != 1 && index % 3 == 0{
                let aa = Vertices[Int(Indices[index-3])].Position
                let bb = Vertices[Int(Indices[index-2])].Position
                let cc = Vertices[Int(Indices[index-1])].Position
                let nn = Vertices[Int(Indices[index-1])].Normal
                let a:GLKVector3 = GLKVector3Make(aa.x, aa.y, aa.z)
                let b:GLKVector3 = GLKVector3Make(bb.x, bb.y, bb.z)
                let c:GLKVector3 = GLKVector3Make(cc.x, cc.y, cc.z)
                let n:GLKVector3 = GLKVector3Make(Float(nn.x), Float(nn.y), Float(nn.z))
                let data = ray.intersectsTriangle(a: a, b: b, c: c, normal:n)
                if data.intersect {
                    print("intersect point: " + String( data.result!.x) + " " + String( data.result!.y) + " " + String( data.result!.z) + " " + String(index / 3))
                    result.append(contentsOf:[a,b,c])
                }
            }
        }
        return result;
    }
}
