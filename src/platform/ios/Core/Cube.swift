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


class Cube : DrawableElement {
    
    /// Element buffer object. Stores the indices that tell OpenGL what vertices to draw.
    var ebo = GLuint()
    
    /// Vertex buffer object. Stores our vertex information within the GPU's memory.
    var vbo = GLuint()
    
    /// Vertex array object. Stores vertex attribute calls that facilitate future drawing. Instead of having to bind/unbind
    /// several buffers constantly to perform drawn, you can simply bind your VAO, make the vertex attribute cals you would
    /// to draw elements on screen, and then whenever you want to draw you simply bind your VAO and it stores those other
    /// vertex attribute calls.
    var vao = GLuint()
    var textureObjectId = GLuint()
    var textureVBO = GLuint()
    
    var _textureMatrix:GLKMatrix4!
    
    var Vertices:[Vertex]=[]
    var Indices:[GLubyte]=[]
    var verticesBuffer:[GLfloat] = []
    var colorBuffer:[GLfloat] = []
    var normalBuffer:[GLfloat] = []
    var textureBuffer:[GLfloat] = []
    
    public var texture:Texture!
    
    override init() {
        super.init();
        
        let ves = VertexGenerator.genOneCubeVertices(position: GLKVector3Make(0, 0, 0), color: (1,0.5,0,1))
        let ins = VertexGenerator.genOneCubeIndices(index: 0)
        Vertices = []
        Indices = []
        Vertices.append(contentsOf: ves)
        Indices.append(contentsOf: ins)
        
        for i in (0 ..< Vertices.count) {
            let vertex = Vertices[i]
            verticesBuffer.append(contentsOf: [vertex.Position.x, vertex.Position.y, vertex.Position.z])
            colorBuffer.append(contentsOf: [vertex.Color.r, vertex.Color.g, vertex.Color.b, vertex.Color.a])
            textureBuffer.append(contentsOf: [vertex.TexCoord.x, vertex.TexCoord.y])
            normalBuffer.append(contentsOf: [vertex.Normal.x, vertex.Normal.y, vertex.Normal.z])
        }
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
        
//        textureVBO = Utils.createEBO(textureBuffer.size(), &textureBuffer, GLenum(GL_DYNAMIC_DRAW));
        
        /*
         // Enable the position vertex attribute to then specify information about how the position of a vertex is stored.
         let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
         glEnableVertexAttribArray(vertexAttribPosition)
         glVertexAttribPointer(vertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), nil)
         
         // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
         let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
         // The byte offset, in memory, of our color information within a Vertex object.
         let colorOffset = MemoryLayout<GLfloat>.stride * 3
         // Swift pointer object that stores the offset of the color information within our Vertex structure.
         let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
         glEnableVertexAttribArray(vertexAttribColor)
         glVertexAttribPointer(vertexAttribColor, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), colorOffsetPointer)
        
        let vertexAttribNormal = GLuint(GLKVertexAttrib.normal.rawValue)
        let normalOffset = MemoryLayout<GLfloat>.stride * 9
        let normalOffsetPointer = UnsafePointer<Int>(bitPattern: normalOffset)
        glEnableVertexAttribArray(vertexAttribNormal)
        glVertexAttribPointer(vertexAttribNormal, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), normalOffsetPointer)
         */
        
        
        //Textures
        let vertexAttribTexCoord0 = GLuint(GLKVertexAttrib.texCoord0.rawValue)
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
        texture = Texture(pathForResource: "/assets/textures/texture_numbers", ofType: "png")
        textureObjectId = load_png_asset_into_texture("textures/texture_numbers.png")
    }
    
    
    override func draw() {
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
        
        // Enable Transparency
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        var shader:Shader = ShaderManager.getShaderWithName("/assets/shaders/cube_shader");
        glUseProgram(shader.program);
        
        // update the attribute color
        let vertexColorLocation:GLuint = GLuint(shader.getAttribute("a_Color"));
        glEnableVertexAttribArray(vertexColorLocation);
        // Pass in the color info
        glVertexAttribPointer(
            vertexColorLocation,
            4,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            0,
            colorBuffer
        );
 
        withUnsafePointer(to: &_projectionMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 16, {
                glUniformMatrix4fv(shader.getUniform("u_ProjectionMatrix"), 1, 0, $0)
            })
        })
        withUnsafePointer(to: &_modelViewMatrix, {
            $0.withMemoryRebound(to: Float.self, capacity: 16, {
                glUniformMatrix4fv(shader.getUniform("u_MvMatrix"), 1, 0, $0)
            })
        })
        
        let vertexAttribPosition = GLuint(shader.getAttribute("a_Position"))
        glEnableVertexAttribArray(vertexAttribPosition)
        glVertexAttribPointer(vertexAttribPosition,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              0,
                              verticesBuffer)
        
         let vertexAttribNormal = GLuint(shader.getAttribute("a_Normal"))
         glEnableVertexAttribArray(vertexAttribNormal)
         glVertexAttribPointer(vertexAttribNormal,
                               3,
                               GLenum(GL_FLOAT),
                               GLboolean(UInt8(GL_FALSE)),
                               0,
                               normalBuffer)
        

        var lightPos:GLKVector3 = GLKVector3Make(-20, 10, -10)
        withUnsafePointer(to: &lightPos, {
            $0.withMemoryRebound(to: Float.self, capacity: 16, {
                glUniform3fv(shader.getUniform("u_LightPos"), 1, $0)
            })
        })
        
        
        glActiveTexture(GLenum(GL_TEXTURE0));
        glBindTexture(GLenum(GL_TEXTURE_2D), textureObjectId);
        
        glUniform1i(shader.getUniform("u_Texture"), 0)
        let vertexAttribTextureCoord = GLuint(shader.getAttribute("a_TextureCoord"))
        glEnableVertexAttribArray(vertexAttribTextureCoord)
        glVertexAttribPointer(vertexAttribTextureCoord,
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              0,
                              textureBuffer)
//        withUnsafePointer(to: &textureBuffer, {
//            $0.withMemoryRebound(to: Float.self, capacity: 16, {
//                glUniformMatrix4fv(shader.getUniform("u_Texture"), 1, 0, $0)
//            })
//        })
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), textureVBO);
 
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        // Draw the cube.
        //        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(Indices.count));
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArrayOES(0)
        
        glDisableVertexAttribArray(vertexAttribPosition);
        glDisableVertexAttribArray(vertexColorLocation);
        glDisableVertexAttribArray(vertexAttribNormal);
        glDisableVertexAttribArray(vertexAttribTextureCoord);
        glBindTexture(GLenum(GL_TEXTURE_2D), 0);
        glDisable(GLenum(GL_BLEND));
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
