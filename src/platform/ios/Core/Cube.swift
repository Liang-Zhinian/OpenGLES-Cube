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
    var textureObjectIds:[GLuint]=[]
//    var textureBuffer:[Float]=[]
    
    var Vertices:[Vertex]=[]
    var Indices:[GLubyte]=[]
    
    var renderWithGLKit:Bool = false
    
    override init() {
        super.init();
        
        let ves = VertexGenerator.genOneCubeVertices(position: GLKVector3Make(0, 0, 0), color: (1, 0.5, 0, 1))
        let ins = VertexGenerator.genOneCubeIndices(index: 0)
        Vertices = []
        Indices = []
        Vertices.append(contentsOf: ves)
        Indices.append(contentsOf: ins)
        
        for i in (0 ..< Vertices.count) {
            let vertex = Vertices[i]
//            verticesBuffer.append(contentsOf: [vertex.Position.x, vertex.Position.y, vertex.Position.z])
//            colorBuffer.append(contentsOf: [vertex.Color.r, vertex.Color.g, vertex.Color.b, vertex.Color.a])
//            textureBuffer.append(contentsOf: [vertex.TexCoord.x, vertex.TexCoord.y])
//            normalBuffer.append(contentsOf: [vertex.Normal.x, vertex.Normal.y, vertex.Normal.z])
        }
    }
    
    func createVertexBuffers() {
        // Generate and bind a vertex array object.
        vao = Utils.createVAO()
        
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
        
        // VBO
        let vertexBufferSize = Vertices.count * vertexSize
        vbo = Utils.createVBO(vertexBufferSize, &Vertices, GLenum(GL_DYNAMIC_DRAW));
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        // EBO
        let indexBufferSize = Indices.size()
        ebo = Utils.createEBO(indexBufferSize, &Indices, GLenum(GL_DYNAMIC_DRAW));
//        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        
        let shader:Shader = ShaderManager.getShaderWithName("assets/shaders/cube_shader");
        
        var vertexAttribPosition = GLuint(shader.getAttribute("a_Position"));
        
        var vertexAttribColor = GLuint(shader.getAttribute("a_Color"));
        
        var vertexAttribNormal = GLuint(shader.getAttribute("a_Normal"));
        
        var vertexAttribTexCoord0 = GLuint(shader.getAttribute("a_TextureCoord"))
        
        if (renderWithGLKit) {
            vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
            
            vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
            
            vertexAttribNormal = GLuint(GLKVertexAttrib.normal.rawValue)
            
            vertexAttribTexCoord0 = GLuint(GLKVertexAttrib.texCoord0.rawValue)
        }
        
        configurePosition(attribute: vertexAttribPosition, stride: GLsizei(vertexSize))
        configureColor(attribute: vertexAttribColor, stride: GLsizei(vertexSize))
        configureTexture(attribute: vertexAttribTexCoord0, stride: GLsizei(vertexSize))
        configureNormal(attribute: vertexAttribNormal, stride: GLsizei(vertexSize))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        
        // were done so unbind the VAO
        glBindVertexArrayOES(0);
    }
    
    func configurePosition(attribute: GLuint, stride: GLsizei){
        // Enable the position vertex attribute to then specify information about how the position of a vertex is stored.
         glEnableVertexAttribArray(attribute)
         glVertexAttribPointer(attribute, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), stride, nil)
    }
    
    func configureColor(attribute: GLuint, stride: GLsizei){
         // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
         // The byte offset, in memory, of our color information within a Vertex object.
         let colorOffset = MemoryLayout<GLfloat>.stride * 3
         // Swift pointer object that stores the offset of the color information within our Vertex structure.
         let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
         glEnableVertexAttribArray(attribute)
         glVertexAttribPointer(attribute, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), stride, colorOffsetPointer)
    }
    
    func configureNormal(attribute: GLuint, stride: GLsizei){
        let normalOffset = MemoryLayout<GLfloat>.stride * 9
        let normalOffsetPointer = UnsafePointer<Int>(bitPattern: normalOffset)
        glEnableVertexAttribArray(attribute)
        glVertexAttribPointer(attribute, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), stride, normalOffsetPointer)
    }
    
    func configureTexture(attribute: GLuint, stride: GLsizei){
        //Textures
        let textureOffset = MemoryLayout<GLfloat>.stride * 7
        let textureOffsetPointer = UnsafePointer<Int>(bitPattern: textureOffset)
        glEnableVertexAttribArray(attribute);
        glVertexAttribPointer(attribute, 2, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), stride, textureOffsetPointer);
        glActiveTexture(GLenum(GL_TEXTURE0));
        if (!renderWithGLKit) {
//            glGenTextures(1, &textureObjectId);
//            configureDefaultTexture(fileName: "assets/textures/texture_numbers.png", textureObjectId: textureObjectId);
            loadTextures()
        }
    }
    
    func configureDefaultTexture(fileName: String, textureObjectId:GLuint) {
        let uiImage = UIImage(named: fileName);
        if (uiImage == nil) {
            print("Failed to load image " + fileName);
            exit(1);
        }
        let spriteImage:CGImage = uiImage!.cgImage!;
    
        let width:GLsizei = GLsizei(spriteImage.width);
        let height:GLsizei = GLsizei(spriteImage.height);
        let rect = CGRect.init(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize.init(width: Int(width), height: Int(height)))
    
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var bitmapByteCount:Int;
        var bitmapBytesPerRow:Int;
        let pixelsWide = Int(width);
        let pixelsHigh = Int(height);
        
        bitmapBytesPerRow   = (pixelsWide * 4);// 1
        bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
        
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)

        guard let spriteContext = CGContext.init(data: pixelData,
                                                 width: Int(width),
                                                 height: Int(height),
                                                 bitsPerComponent: 8,
                                                 bytesPerRow: bitmapBytesPerRow,
                                                 space: colorSpace,
                                                 bitmapInfo: UInt32(bitmapInfo.rawValue))
            else {
                // cannot create context - handle error
                exit(1)
        }
        
        spriteContext.draw(spriteImage, in: rect, byTiling: true)
    
//        glGenTextures(1, &textureObjectId);
        glBindTexture(GLenum(GL_TEXTURE_2D), textureObjectId);
    
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR_MIPMAP_LINEAR);
    
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), pixelData);
        glBindTexture(GLenum(GL_TEXTURE_2D), 0);
    }
    
    func loadTextures() {
        textureObjectIds = [0,0,0,0,0,0]
        glGenTextures(6, &textureObjectIds);
        assert(textureObjectIds.count == 6)
        for i in (0 ..< 6) {
            configureDefaultTexture(fileName: "assets/textures/dice"+String(i+1)+".png", textureObjectId: textureObjectIds[i]);
        }
    }
    
    override func draw() {
        glBindVertexArrayOES(vao);
        
        if (!renderWithGLKit) {
            let shader:Shader = ShaderManager.getShaderWithName("assets/shaders/cube_shader");
            glUseProgram(shader.program);
            
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
            
            var lightPos:GLKVector3 = GLKVector3Make(1, 0, -10)
            withUnsafePointer(to: &lightPos, {
                $0.withMemoryRebound(to: Float.self, capacity: 12, {
                    glUniform3fv(shader.getUniform("u_LightPos"), 1, $0)
                })
            })
            
//            glBindTexture(GLenum(GL_TEXTURE_2D), textureObjectId);
            
            //Point to our buffers
            for i in (0 ..< 6) {
                glBindTexture(GLenum(GL_TEXTURE_2D), textureObjectIds[i]);
                let indiceOffset = i * 6
                let indiceOffsetPointer = UnsafePointer<Int>(bitPattern: indiceOffset)
                glDrawElements(GLenum(GL_TRIANGLES), GLsizei(6), GLenum(GL_UNSIGNED_BYTE), indiceOffsetPointer)
            }
        }
        
//        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArrayOES(0)
        
//        glDisableVertexAttribArray(vertexAttribPosition);
//        glDisableVertexAttribArray(vertexColorLocation);
//        glDisableVertexAttribArray(vertexAttribNormal);
//        glDisableVertexAttribArray(vertexAttribTexCoord);
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
