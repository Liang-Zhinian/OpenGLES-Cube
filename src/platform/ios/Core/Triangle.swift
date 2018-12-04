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

class Triangle : NSObject {
    
    /// Element buffer object. Stores the indices that tell OpenGL what vertices to draw.
    var ebo = GLuint()
    
    /// Vertex buffer object. Stores our vertex information within the GPU's memory.
    var vbo = GLuint()
    
    /// Vertex array object. Stores vertex attribute calls that facilitate future drawing. Instead of having to bind/unbind
    /// several buffers constantly to perform drawn, you can simply bind your VAO, make the vertex attribute cals you would
    /// to draw elements on screen, and then whenever you want to draw you simply bind your VAO and it stores those other
    /// vertex attribute calls.
    var vao = GLuint()
    
    var Vertices:[Vertex] = [
    ]
    
    var Indices:[GLubyte] = [
        // Front
        0, 1, 2,
    ]
    
    override init() {
        super.init();
        
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
//        glBindVertexArrayOES(0)
    }
    
    func createVertexBuffers() {
        // Generate and bind a vertex array object.
        vao = Utils.createVAO()
        
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
        
        // The byte offset, in memory, of our color information within a Vertex object.
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        // Swift pointer object that stores the offset of the color information within our Vertex structure.
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        let normalOffset = MemoryLayout<GLfloat>.stride * 7
        let normalOffsetPointer = UnsafePointer<Int>(bitPattern: normalOffset)
        // Enable the position vertex attribute to then specify information about how the position of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribPosition)
        glVertexAttribPointer(vertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), nil)
        
        // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribColor)
        glVertexAttribPointer(vertexAttribColor, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), colorOffsetPointer)
        
        glEnableVertexAttribArray(vertexAttribNormal)
        glVertexAttribPointer(vertexAttribNormal, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), normalOffsetPointer)
        
        // Bind back to the default state.
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        
        glBindVertexArrayOES(0)
        
    }
    
    func updateVertices(vertices:[Vertex]) {
        Vertices = [];
        Vertices.append(contentsOf: vertices);
        createVertexBuffers()
    }
    
    func render() {
        if (vao == 0) {
            return;
        }
        
        glBindVertexArrayOES(vao);
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArrayOES(0)
    }
    
    func deleteBuffers() {
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
    }
}
