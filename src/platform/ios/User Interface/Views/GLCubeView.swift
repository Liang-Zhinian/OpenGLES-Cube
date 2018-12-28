//
//  GLCubeView.swift
//  ChainReactApp
//
//  Created by Sprite on 2018/12/8.
//  Copyright © 2018年 Facebook. All rights reserved.
//

import QuartzCore
import OpenGLES
import GLKit
import Foundation
import UIKit

@objc class GLCubeView: UIView {
    
    var _eaglLayer: CAEAGLLayer?
    var _context: EAGLContext?
    
    /// Effect to facilitate having to write shaders in order to achieve shading and lighting.
    var effect = GLKBaseEffect()
    
    var _beta:Float!
    var _garma:Float!
    var camera:SphereCamera!
    var PI = Float(M_PI)
    
    var _depthRenderBuffer = GLuint()
    var _colorRenderBuffer = GLuint()
    
    // OpenGL Matricies
    var _modelViewMatrix:GLKMatrix4!
    var _projectionMatrix:GLKMatrix4!
    var _modelViewProjectionMatrix:GLKMatrix4!;
    var _normalMatrix:GLKMatrix3!;
    
    var _rotMatrix:GLKMatrix4 = GLKMatrix4MakeScale(1, 1, 1)
    var _quatStart:GLKQuaternion = GLKQuaternionMake(0, 0, 0, 1)
    var _quat:GLKQuaternion = GLKQuaternionMake(0, 0, 0, 1)
    
    var _curRed:Float = 0.0
    var _increasing:Bool = true
    
    var _slerping:Bool = true
    var _slerpCur:Float = 0.0
    var _slerpMax:Float = 0.0
    var _slerpStart:GLKQuaternion = GLKQuaternionMake(0, 0, 0, 1)
    var _slerpEnd:GLKQuaternion = GLKQuaternionMake(0, 0, 0, 1)
    var _autoRotate:Bool = false
    var _shader:Shader!
    var _cube:Cube!
    var _triangle:Triangle!
    
    /// Used to store and determine the rotation value of our drawn geometry.
    var rotation: Float = 0.0
    
    var _anchor_position:GLKVector3!
    var _current_position:GLKVector3!
    
    override class var layerClass: AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if (self.setupLayer() != 0) {
            NSLog("OpenGLView init():  setupLayer() failed")
            return
        }
        if (self.setupContext() != 0) {
            NSLog("OpenGLView init():  setupContext() failed")
            return
        }
        if (self.setupDepthBuffer() != 0) {
            NSLog("OpenGLView init():  setupDepthBuffer() failed")
            return
        }
        if (self.setupRenderBuffer() != 0) {
            NSLog("OpenGLView init():  setupRenderBuffer() failed")
            return
        }
        if (self.setupFrameBuffer() != 0) {
            NSLog("OpenGLView init():  setupFrameBuffer() failed")
            return
        }
        if (self.setupDisplayLink() != 0) {
            NSLog("OpenGLView init():  setupDisplayLink() failed")
        }
        
        glEnable(GLenum(GL_DEPTH_TEST));
        glDepthFunc(GLenum(GL_LEQUAL));
        // Enable Transparency
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        resize()
        addGestureRecognizer()
        
        _cube = Cube();
        _cube.createVertexBuffers()
        
        _triangle = Triangle()
        
        _rotMatrix = GLKMatrix4Identity;
        _quat = GLKQuaternionMake(0, 0, 0, 1);
        _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("OpenGLView init(coder:) has not been implemented")
    }
    
    func setupLayer() -> Int {
        _eaglLayer = self.layer as? CAEAGLLayer
        if (_eaglLayer == nil) {
            NSLog("setupLayer:  _eaglLayer is nil")
            return -1
        }
        _eaglLayer!.isOpaque = true
        return 0
    }
    
    func resize() {
//        self.camera = SphereCamera(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.camera = SphereCamera(width: self.bounds.width, height: self.bounds.height)
        self.effect.transform.projectionMatrix = self.camera.projection
    }
    
    func setupContext() -> Int {
        let api : EAGLRenderingAPI = EAGLRenderingAPI.openGLES2
        _context = EAGLContext(api: api)
        
        if (_context == nil) {
            NSLog("Failed to initialize OpenGLES 2.0 context")
            return -1
        }
        if (!EAGLContext.setCurrent(_context)) {
            NSLog("Failed to set current OpenGL context")
            return -1
        }
        return 0
    }
    
    func setupDepthBuffer() -> Int {
        glGenRenderbuffers(1, &_depthRenderBuffer);
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _depthRenderBuffer);
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        return 0
    }
    
    func setupFrameBuffer() -> Int {
        var framebuffer: GLuint = 0
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
                                  GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), _depthRenderBuffer);
        return 0
    }
    
    func setupRenderBuffer() -> Int {
        glGenRenderbuffers(1, &_colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        
        if (_context == nil) {
            NSLog("setupRenderBuffer():  _context is nil")
            return -1
        }
        if (_eaglLayer == nil) {
            NSLog("setupRenderBuffer():  _eagLayer is nil")
            return -1
        }
        if (_context!.renderbufferStorage(Int(GL_RENDERBUFFER), from: _eaglLayer!) == false) {
            NSLog("setupRenderBuffer():  renderbufferStorage() failed")
            return -1
        }
        return 0
    }
    
    func setupDisplayLink() -> Int {
        let displayLink : CADisplayLink = CADisplayLink(target: self, selector: #selector(GLCubeView.render(displayLink:)))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode(rawValue: RunLoopMode.defaultRunLoopMode.rawValue))
        return 0
    }
    
    func render(displayLink: CADisplayLink) -> Int {
        
        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        
        drawBackground(displayLink: displayLink)
        
        drawCube(displayLink: displayLink)
        
        _triangle.draw()
        
        _context!.presentRenderbuffer(Int(GL_RENDERBUFFER))
        return 0
    }
    
    func drawBackground(displayLink: CADisplayLink) {
        if (_increasing) {
            _curRed += Float(1.0 * displayLink.duration);
        } else {
            _curRed -= Float(1.0 * displayLink.duration);
        }
        if (_curRed >= 1.0) {
            _curRed = 1.0;
            _increasing = false;
        }
        if (_curRed <= 0.0) {
            _curRed = 0.0;
            _increasing = true;
        }
        
        if (_slerping) {
            _slerpCur += Float(displayLink.duration);
            var slerpAmt:Float = _slerpCur / _slerpMax;
            if (slerpAmt > 1.0) {
                slerpAmt = 1.0;
                _slerping = false;
            }
            
            _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
        }
        
        // Set the color we want to clear the screen with (before drawing) to black.
        glClearColor(_curRed, 0.85, 0.85, 1.0)
        // Clear the contents of the screen (the color buffer) with the black color we just set.
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
    }
    
    func drawCube(displayLink: CADisplayLink) {
        
        let aspect = fabsf(Float(self.bounds.size.width) / Float(self.bounds.size.height))
        let projectionMatrix = self.camera.projection //GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1, 100.0);
        self.effect.transform.projectionMatrix = projectionMatrix
        _projectionMatrix = projectionMatrix
        
        let scaleMatrix:GLKMatrix4 = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
        var rotationMatrix:GLKMatrix4 = GLKMatrix4MakeWithQuaternion(_quat);
        
        // Compute the model view matrix for the object rendered with GLKit
        var modelViewMatrix:GLKMatrix4 = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0);
//        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, self.camera.view);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, scaleMatrix);
        modelViewMatrix = self.camera.view
        
        self.effect.transform.modelviewMatrix = modelViewMatrix
        _modelViewMatrix = modelViewMatrix
        
        // Compute the model view matrix for the object rendered with ES2
        modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0);
//        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, self.camera.view);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, scaleMatrix);
        modelViewMatrix = self.camera.view
        
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil);
        
        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        
        updateDE(_cube, displayLink: displayLink)
        
        _cube.draw();
    }
    
    func updateDE(_ de:DrawableElement, displayLink: CADisplayLink) {
        de._userScale = 1.0
        de._projectionMatrix = _projectionMatrix;
        de._modelViewMatrix = _modelViewMatrix;
        de.update(Float(displayLink.duration));
    }
    
    //
    // MARK: - Touch Handling
    //
    
    /// Used to detect when a tap occurs on screen so we can pause updates of our program.
    ///
    /// - Parameters:
    ///   - touches: The touches that occurred on screen.
    ///   - event: Describes the user interactions in the app.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Pause or unpause updating our program.
        //        isPaused = !isPaused
        
        let touches = Array(touches)
        if touches.count >= 1{
            let touch:UITouch = touches.first!
            let location = touch.location(in: self)
            _anchor_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
            _current_position = _anchor_position
            _beta = self.camera.beta
            _garma = self.camera.garma
            
            _quatStart = _quat;
            
            _anchor_position = projectOntoSurface(touchPoint: _anchor_position);
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = Array(touches)
        if touches.count >= 1{
            let touch:UITouch = touches.first!
            let location = touch.location(in: self)
            _current_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
            let diff = CGPoint(x: CGFloat(_current_position.x - _anchor_position.x), y: CGFloat(_current_position.y - _anchor_position.y))
            // As the user drags, we use GLKMatrix4Rotate to rotate the cube a number of degrees.
            // For every pixel the user drags, we rotate the cube 1/2 degree.
            let beta = GLKMathDegreesToRadians(Float(diff.y) / 2.0);
            let garma = GLKMathDegreesToRadians(Float(diff.x) / 2.0);
            
            self.camera.update(beta: _beta + beta, garma: _garma + garma)
            
            let previousLocation:CGPoint = touch.previousLocation(in: self)
            let diff2:CGPoint = CGPoint(x:previousLocation.x - location.x, y:previousLocation.y - location.y)
            
            let rotX:Float = -1 * GLKMathDegreesToRadians(Float(diff2.y / 2.0));
            let rotY:Float = -1 * GLKMathDegreesToRadians(Float(diff2.x / 2.0));
            /*
            GLKVector3 xAxis = GLKVector3Make(1, 0, 0);
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
            GLKVector3 yAxis = GLKVector3Make(0, 1, 0);
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
            */
            
            var isInvertible:Bool = false
            let xAxis:GLKVector3 = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0))
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
            let yAxis:GLKVector3 = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0))
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z)
            
            _current_position = projectOntoSurface(touchPoint: _current_position)
            
            computeIncremental()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pick(x: Float(_anchor_position.x), y: Float(_anchor_position.y))
    }
    
    func doubleTap(tap: UITapGestureRecognizer) {
        
        _slerping = true;
        _slerpCur = 0;
        _slerpMax = 1.0;
        _slerpStart = _quat;
        _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
        
    }
    
    // convert a 2D touch point to a point on a virtual 3D sphere surrounding the object
    func projectOntoSurface(touchPoint :GLKVector3 ) -> GLKVector3
    {
        // Imagine we have a virtual sphere surrounding our object, with a radius of 1/3 the screen width.
        // The center of the sphere is the center of the object we’re rotating.
        // We want to let the user “grab and drag” this sphere to rotate the object.
        let radius:Float = Float(self.bounds.size.width/3)
        let center:GLKVector3 = GLKVector3Make(Float(self.bounds.size.width/2), Float(self.bounds.size.height/2), 0)
        var P:GLKVector3 = GLKVector3Subtract(touchPoint, center)
        
        // Flip the y-axis because pixel coords increase toward the bottom.
        P = GLKVector3Make(P.x, P.y * -1, P.z);
        
        let radius2 = radius * radius;
        let length2 = P.x*P.x + P.y*P.y;
        
        if (length2 <= radius2) {
            P.z = sqrt(radius2 - length2);
        }
        else
        {
            /*
             P.x *= radius / sqrt(length2);
             P.y *= radius / sqrt(length2);
             P.z = 0;
             */
            P.z = radius2 / (2.0 * sqrt(length2));
            let length = sqrt(length2 + P.z * P.z);
            P = GLKVector3DivideScalar(P, length);
        }
        
        return GLKVector3Normalize(P);
    }
    
    func computeIncremental() {
        
        let axis:GLKVector3 = GLKVector3CrossProduct(_anchor_position, _current_position);
        let dot = GLKVector3DotProduct(_anchor_position, _current_position);
        let angle = acosf(dot);
        
        var Q_rot:GLKQuaternion = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis);
        Q_rot = GLKQuaternionNormalize(Q_rot);
        
        // TODO: Do something with Q_rot...
        _quat = GLKQuaternionMultiply(Q_rot, _quatStart);
    }
    
    func pick(x:Float, y:Float){
        let width = Float(self.camera.width)
        let height = Float(self.camera.height)
        
//        let ray = Ray(x:x, y:y, width: width, height: height, modelviewMatrix: effect.transform.modelviewMatrix, projectionMatrix: effect.transform.projectionMatrix);
        let ray = Ray(x:x, y:y, camera: self.camera);
        let points = _cube.intersect(ray:ray)
        if (points.count >= 3) {
            drawPickedTriangle(a:points[0], b:points[1], c:points[2])
        } else {
            print("nothing picked")
        }
    }
    
    func drawPickedTriangle(a:GLKVector3, b:GLKVector3, c:GLKVector3) {
        let vertices:[Vertex] = [
            Vertex(Position: (a.x, a.y, a.z), Color: (1, 0, 0, 0.4), TexCoord: (x:0, y:1), Normal: (0, 0, 1)),
            Vertex(Position: (b.x, b.y, b.z), Color: (1, 1, 0, 0.4), TexCoord: (x:0, y:1), Normal: (0, 0, 1)),
            Vertex(Position: (c.x, c.y, c.z), Color: (1, 0, 1, 0.4), TexCoord: (x:0, y:1), Normal: (0, 0, 1)),
            ];
        _triangle.updateVertices(vertices: vertices);
    }
    
    func addGestureRecognizer() {
        let dtRec:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(GLCubeView.doubleTap(tap:)))
        dtRec.numberOfTapsRequired = 2;
        self.addGestureRecognizer(dtRec);
    }
    
    func getNormalizedPoint(in view: UIView?, locationInView:CGPoint) -> CGPoint
    {
        let normalizedX:CGFloat = ((locationInView.x / (view?.bounds.size.width)!) * 2 - 1);
        let normalizedY:CGFloat = (-((locationInView.y / (view?.bounds.size.height)!) * 2 - 1));
        return CGPoint(x: normalizedX, y: normalizedY);
    }
}


