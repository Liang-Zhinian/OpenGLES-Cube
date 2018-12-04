//
//  Ray.swift
//  airhockey
//
//  Created by sprite on 2018/12/4.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

import Foundation

class Ray : NSObject {
    var near:GLKVector3!;
    var far:GLKVector3!;
    
    init(x:Float, y:Float, width:Float, height:Float, modelviewMatrix: GLKMatrix4, projectionMatrix: GLKMatrix4) {
        super.init()
        
        // translate mouse coordinates so that the origin lies in the center
        // of the view port
        var xPoint = x - width / 2
        var yPoint = y - height / 2
        xPoint = xPoint/width * 2
        yPoint = -yPoint/height * 2
        
        xPoint = x * Float(UIScreen.main.scale)
        yPoint = y * Float(UIScreen.main.scale)
        
        var testResult:Bool=false;
        
        var viewport:[GLint]=[0,0,0,0];
        glGetIntegerv(GLenum(GL_VIEWPORT), &viewport);
        
        let uiKitOffset:Int = 1; //Need to factor in the height of the nav bar + the height of the tab bar at the bottom in the storyboard.
        near = GLKMathUnproject(GLKVector3Make(xPoint,
                                               (yPoint - Float(viewport[3] + uiKitOffset)) * -1,
                                               0.0),
                                modelviewMatrix,
                                projectionMatrix,
                                &viewport[0] ,
                                &testResult);
        
        far = GLKMathUnproject(GLKVector3Make(xPoint,
                                              (yPoint - Float(viewport[3] + uiKitOffset)) * -1,
                                              1.0),
                               modelviewMatrix,
                               projectionMatrix,
                               &viewport[0] ,
                               &testResult);
    }
    
    func intersectsTriangle(a: GLKVector3, b: GLKVector3, c: GLKVector3, normal:GLKVector3) -> (intersect:Bool, result:GLKVector3?){
        //follow http://sarvanz.blogspot.com/2012/03/probing-using-ray-casting-in-opengl.html
        
        let ray = GLKVector3Subtract(far, near)
        let nDotL = GLKVector3DotProduct(normal, ray)
        //是否跟三角面在同一平面或者背对三角面
        if nDotL >= 0 {
            return (intersect:false, result:nil)
        }
        
        let d = GLKVector3DotProduct(normal, GLKVector3Subtract(a, near)) / nDotL
        //是否在最近点和最远点之外
        if (d < 0 || d > 1) {
            return (intersect:false, result:nil)
        }
        
        let p = GLKVector3Add(near, GLKVector3MultiplyScalar(ray, d))
        let n1 = GLKVector3CrossProduct( GLKVector3Subtract(b, a),  GLKVector3Subtract(p, a))
        let n2 = GLKVector3CrossProduct( GLKVector3Subtract(c, b),  GLKVector3Subtract(p, b))
        let n3 = GLKVector3CrossProduct( GLKVector3Subtract(a, c),  GLKVector3Subtract(p, c))
        
        if GLKVector3DotProduct(normal, n1) >= 0 &&
            GLKVector3DotProduct(normal, n2) >= 0 &&
            GLKVector3DotProduct(normal, n3) >= 0{
            return (intersect:true, result:p)
        }else{
            return (intersect:false, result:nil)
        }
    }
}
