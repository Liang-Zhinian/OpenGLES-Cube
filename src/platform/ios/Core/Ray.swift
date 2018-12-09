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
    var PI = Float(M_PI)
    
    init(x:Float, y:Float, width:Float, height:Float, modelviewMatrix: GLKMatrix4, projectionMatrix: GLKMatrix4) {
        super.init()
        
        print("init1 => width: "+String(width)+", height: "+String(height))
        // translate mouse coordinates so that the origin lies in the center
        // of the view port
        var xPoint = x - width / 2
        var yPoint = y - height / 2
        xPoint = xPoint/width * 2
        yPoint = -yPoint/height * 2
        
        let scalar:Float = Float(UIScreen.main.scale)
        
        xPoint = xPoint * scalar
        yPoint = yPoint * scalar
        
        print("init1 => xPoint: "+String(xPoint)+", yPoint: "+String(yPoint))
        
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
        
        print("init1 => near : " + String(near.x) + " " + String(near.y) + " " + String(near.z))
        print("init1 => far : " + String(far.x) + " " + String(far.y) + " " + String(far.z))
    }
    
    init(x:Float, y:Float, camera: SphereCamera) {
        //follow http://schabby.de/picking-opengl-ray-tracing/
        let viewVector3 = GLKVector3Normalize(GLKVector3Subtract(camera.target, camera.position))
        var hVector3 = GLKVector3Normalize(GLKVector3CrossProduct(viewVector3, camera.up))
        var vVector3 = GLKVector3Normalize(GLKVector3CrossProduct(hVector3, viewVector3))
        
        let width = Float(camera.width)
        let height = Float(camera.height)
        print("init2 => width: "+String(width)+", height: "+String(height))
        
        // convert fovy to radians
        let rad = camera.fov * PI / 180
        let vLength = tan( rad / 2 ) * camera.near
        let hLength = vLength * (width / height)
        
        vVector3 = GLKVector3MultiplyScalar(vVector3, vLength)
        hVector3 = GLKVector3MultiplyScalar(hVector3, hLength)
        
        // translate mouse coordinates so that the origin lies in the center
        // of the view port
        var xPoint = x - width / 2
        var yPoint = y - height / 2
        xPoint = xPoint/width * 2
        yPoint = -yPoint/height * 2
        
        print("init2 => xPoint: "+String(xPoint)+", yPoint: "+String(yPoint))
        
        // compute direction of picking ray by subtracting intersection point
        
        var direction = GLKVector3Add(GLKVector3MultiplyScalar(viewVector3, camera.near), GLKVector3MultiplyScalar(hVector3, xPoint))
        direction = GLKVector3Add(direction, GLKVector3MultiplyScalar(vVector3, yPoint))
        
        // linear combination to compute intersection of picking ray with
        // view port plane
        near = GLKVector3Add(camera.position, direction)
        far = GLKVector3Add(camera.position, GLKVector3MultiplyScalar(direction, camera.far / camera.near))
        
        print("init2 => near : " + String(near.x) + " " + String(near.y) + " " + String(near.z))
        print("init2 => far : " + String(far.x) + " " + String(far.y) + " " + String(far.z))
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
