//
//  Utils.swift
//  airhockey
//
//  Created by sprite on 2018/12/4.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit


struct Utils {
    
    static var timeRecorder = NSMutableDictionary()
    static var analysisRecorder = NSMutableDictionary()
    static var delayRecorder:[Bool] = []
    
    static func setDelay(time:Double = 1, closure:@escaping ()->()) -> Int {
        let index:Int = delayRecorder.count
        delayRecorder.append(true)
        
        //        dispatch_after(
        //            dispatch_time(
        //                dispatch_time_t(DISPATCH_TIME_NOW),
        //                Int64(time * Double(NSEC_PER_SEC))
        //            ),
        //            dispatch_get_main_queue(), {
        //                if self.delayRecorder[index]{
        //                    closure()
        //                }
        //        })
        
        let mainQueue = DispatchQueue.main
        let deadline = DispatchTime.now() + time
        mainQueue.asyncAfter(deadline: deadline) {
            if self.delayRecorder[index]{
                closure()
            }
        }
        
        return index
    }
    
    static func cancelDelay(index:Int = -1){
        if -1 < index && index < delayRecorder.count && delayRecorder[index]{
            delayRecorder[index] = false
        }
    }
    
    static func createVAO() -> GLuint {
        var vao = GLuint();
        // Generate and bind a vertex array object.
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        assert(vao != 0);
        
        return vao;
    }
    
    static func createVBO(_ size: GLsizeiptr, _ data: UnsafeRawPointer!, _ usage: GLenum) -> GLuint {
        assert(data != nil);
        var vbo = GLuint();
        // Generatea a buffer for our vertex buffer object.
        glGenBuffers(1, &vbo)
        assert(vbo != 0);
        
        // Bind the vertex buffer object we just generated (created).
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // Pass data for our vertices to the vertex buffer object.
        //        let vertexBufferSize = Vertices.count * vertexSize
        glBufferData(GLenum(GL_ARRAY_BUFFER), size, data, usage)
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        
        return vbo;
    }
    
    static func createEBO(_ size: GLsizeiptr, _ data: UnsafeRawPointer!, _ usage: GLenum) -> GLuint {
        assert(data != nil);
        var ebo = GLuint();
        // EBO
        // Generatea a buffer for our element buffer object.
        glGenBuffers(1, &ebo)
        assert(ebo != 0);
        
        // Bind the element buffer object we just generated (created).
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        // Pass data for our element indices to the element buffer object.
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), size, data, usage)
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        
        return ebo;
    }
}
