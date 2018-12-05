

import QuartzCore
import OpenGLES
import GLKit
import Foundation


func F3(x:Float, _ y:Float, _ z:Float) -> (x:Float, y:Float, z:Float){
    return (x:x, y:y, z:z)
}

func sizeofVertex() -> Int {
    // The size, in memory, of a Vertex structure.
    let vertexSize:Int = MemoryLayout<Vertex>.stride
    return vertexSize;
}

//
// MARK: - View Controller
//

/// Our subclass of GLKViewController to perform drawing, and logic updates using OpenGL ES.
final class CubeViewController: GLKViewController {
    //
    // MARK: - Variables And Properties
    //
    
    /// Reference to provide easy access to our EAGLContext.
    var context: EAGLContext?
    
    /// Effect to facilitate having to write shaders in order to achieve shading and lighting.
    var effect = GLKBaseEffect()
    
    /// Used to store and determine the rotation value of our drawn geometry.
    var rotation: Float = 0.0
    
    var appendIndex:Int = 0
    
    var _anchor_position:GLKVector3!
    var _current_position:GLKVector3!
    var _beta:Float!
    var _garma:Float!
    var camera:SphereCamera!
    var PI = Float(M_PI)
    
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
    
    //
    // MARK: - Initialization
    //
    
    //
    // MARK: - View Controller
    //
    
    /// Called when the view controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform OpenGL setup, create buffers, pass geometry data to memory.
        setupContext()
        setupEffect()
        setupGL()
        resize()
        addGestureRecognizer()
        
        _rotMatrix = GLKMatrix4Identity;
        _quat = GLKQuaternionMake(0, 0, 0, 1);
        _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    }
    
    /// Method to deinitialize and perform cleanup when the view controller is removed from memory.
    deinit {
        // Delete buffers, cleanup memory, etc.
        tearDownGL()
    }
    
    //
    // MARK: - Private Methods
    //
    
    /// Setup the current OpenGL context, generate and find necessary buffers, and store geometry data in memory (buffers).
    
    func setupContext() {
        // Create an OpenGL ES 3.0 context and store it in our local variable.
        self.context = EAGLContext(api: .openGLES2)
        
        if (self.context == nil) {
            print("Failed to initialize OpenGLES 2.0 context!")
            exit(1)
        }
        
        if (!EAGLContext.setCurrent(self.context)) {
            print("Failed to set current OpenGL context!")
            exit(1)
        }
        
        // Set the current EAGLContext to our context we created when performing OpenGL setup.
        EAGLContext.setCurrent(context)
        
        // Perform checks and unwrap options in order to perform more OpenGL setup.
        if let view = self.view as? GLKView, let context = context {
            // Set our view's context to the EAGLContext we just created.s
            view.context = context
            
            view.drawableColorFormat = GLKViewDrawableColorFormat.RGBA8888
            view.drawableDepthFormat = GLKViewDrawableDepthFormat.format16
            view.drawableStencilFormat = GLKViewDrawableStencilFormat.format8
            view.drawableMultisample = GLKViewDrawableMultisample.multisample4X
            
            // Set ourselves as delegates of GLKViewControllerDelegate
            delegate = self
        }
        
    }
    
    func setupEffect() {
        self.effect.texture2d0.enabled = GLboolean(GL_TRUE)
        configureDefaultLight()
//        configureDefaultMaterial()
    }
    
    func configureDefaultLight(){
        self.effect.light0.enabled = GLboolean(GL_TRUE)
        self.effect.light0.position = GLKVector4Make(2, 5, 10, 1.0);
        self.effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1.0);
        self.effect.light0.ambientColor = GLKVector4Make(1, 0, 1, 1);
        self.effect.light0.specularColor = GLKVector4Make(1, 1, 0, 1);
    }
    
    func configureDefaultMaterial() {
        
        self.effect.colorMaterialEnabled = GLboolean(GL_TRUE)
        self.effect.texture2d0.enabled = GLboolean(GL_FALSE);
        
        self.effect.material.ambientColor = GLKVector4Make(0.3,0.3,0.3,1.0);
        self.effect.material.diffuseColor = GLKVector4Make(0.3,0.3,0.3,1.0);
        self.effect.material.emissiveColor = GLKVector4Make(0.0,0.0,0.0,1.0);
        self.effect.material.specularColor = GLKVector4Make(0.0,0.0,0.0,1.0);
        
        self.effect.material.shininess = 0;
    }
    
    private func setupGL() {
        
//        _shader = Shader()
//        _shader.loadShaders()
        
        // init GL stuff here
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glEnable(GLenum(GL_DEPTH_TEST));
        glDepthFunc(GLenum(GL_LEQUAL));
        // Enable Transparency
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        _cube = Cube();
        _cube.createVertexBuffers()
        
        _triangle = Triangle();
        
        effect.texture2d0.name = _cube.texture.effectPropertyTexture.name;
    }
    
    func addGestureRecognizer() {
        let dtRec:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CubeViewController.doubleTap(tap:)))
        dtRec.numberOfTapsRequired = 2;
        self.view.addGestureRecognizer(dtRec);
    }
    
    func resize() {
        
        self.camera = SphereCamera(width: view.bounds.width,
                                   height: view.bounds.height)
        self.effect.transform.projectionMatrix = self.camera.projection
    }
    
    
    /// Perform cleanup, and delete buffers and memory.
    private func tearDownGL() {
        // Set the current EAGLContext to our context. This ensures we are deleting buffers against it and potentially not a
        // different context.
        EAGLContext.setCurrent(context)
        
        // Delete the vertex array object, the element buffer object, and the vertex buffer object.
        _cube.deleteBuffers()
        _triangle.deleteBuffers()
        
        // Set the current EAGLContext to nil.
        EAGLContext.setCurrent(nil)
        
        // Then nil out or variable that references our EAGLContext.
        context = nil
    }
    
    //
    // MARK: - Touch Handling
    //
    
    
    func getNormalizedPoint(in view: UIView?, locationInView:CGPoint) -> CGPoint
    {
        let normalizedX:CGFloat = ((locationInView.x / (view?.bounds.size.width)!) * 2 - 1);
        let normalizedY:CGFloat = (-((locationInView.y / (view?.bounds.size.height)!) * 2 - 1));
        return CGPoint(x: normalizedX, y: normalizedY);
    }
    
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
            let location = touch.location(in: view)
            _anchor_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
            _current_position = _anchor_position
            
            _quatStart = _quat;
            
            _beta = self.camera.beta
            _garma = self.camera.garma
            
            let normalizedPoint = getNormalizedPoint(in: self.view, locationInView: location)
//            pick(x: Float(normalizedPoint.x), y: Float(normalizedPoint.y))
            pick(x: Float(_anchor_position.x), y: Float(_anchor_position.y))
            
            _anchor_position = projectOntoSurface(touchPoint: _anchor_position);
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = Array(touches)
        if touches.count >= 1{
            let touch:UITouch = touches.first!
            let location = touch.location(in: view)
            let lastLoc:CGPoint = touch.previousLocation(in: view)
            let diff:CGPoint = CGPoint(x:lastLoc.x - location.x, y:lastLoc.y - location.y)
            
            let rotX:Float = -1 * GLKMathDegreesToRadians(Float(diff.y / 2.0));
            let rotY:Float = -1 * GLKMathDegreesToRadians(Float(diff.x / 2.0));
            
            var isInvertible:Bool = false
            let xAxis:GLKVector3 = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0))
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
            let yAxis:GLKVector3 = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0))
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z)
            
            _current_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
            _current_position = projectOntoSurface(touchPoint: _current_position)
            
            computeIncremental()
            
            let beta = GLKMathDegreesToRadians(Float(diff.y) / 2.0);
            let garma = GLKMathDegreesToRadians(Float(diff.x) / 2.0);
            
            self.camera.update(beta: _beta + beta, garma: _garma + garma)
        }
    }
    
    func doubleTap(tap: UITapGestureRecognizer) {
    
        _slerping = true;
        _slerpCur = 0;
        _slerpMax = 1.0;
        _slerpStart = _quat;
        _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
    
    }
    
    func projectOntoSurface(touchPoint :GLKVector3 ) -> GLKVector3
    {
        let radius:Float = Float(view.bounds.size.width/3)
        let center:GLKVector3 = GLKVector3Make(Float(self.view.bounds.size.width/2), Float(self.view.bounds.size.height/2), 0)
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
        
        let ray = Ray(x:x, y:y, width: width, height: height, modelviewMatrix: effect.transform.modelviewMatrix, projectionMatrix: effect.transform.projectionMatrix);
        let points = _cube.intersect(ray:ray)
        if (points.count >= 3) {
            drawPickedTriangle(a:points[0], b:points[1], c:points[2])
        } else {
            print("nothing picked")
        }
    }
    
    func drawPickedTriangle(a:GLKVector3, b:GLKVector3, c:GLKVector3) {
        let vertices:[Vertex] = [
            Vertex(Position: (a.x, a.y, a.z), Color: (0, 0, 0, 1), TexCoord: (x:0, y:1), Normal: (0, 0, -1)),
            Vertex(Position: (b.x, b.y, b.z), Color: (0, 0, 0, 1), TexCoord: (x:0, y:1), Normal: (0, 0, -1)),
            Vertex(Position: (c.x, c.y, c.z), Color: (0, 0, 0, 1), TexCoord: (x:0, y:1), Normal: (0, 0, -1)),
            ];
        _triangle.updateVertices(vertices: vertices);
    }
}

//
// MARK: - GLKViewController Delegate
//
extension CubeViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
        if (_increasing) {
            _curRed += Float(1.0 * self.timeSinceLastUpdate);
        } else {
            _curRed -= Float(1.0 * self.timeSinceLastUpdate);
        }
        if (_curRed >= 1.0) {
            _curRed = 1.0;
            _increasing = false;
        }
        if (_curRed <= 0.0) {
            _curRed = 0.0;
            _increasing = true;
        }
        
        if (_autoRotate) {
            self.rotation += Float(self.timeSinceLastUpdate * 0.5);
        }
        
        let aspect = fabsf(Float(view.bounds.size.width) / Float(view.bounds.size.height))
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 0.1, 100.0);
        self.effect.transform.projectionMatrix = projectionMatrix
        _projectionMatrix = projectionMatrix
        
        if (_slerping) {
            _slerpCur += Float(self.timeSinceLastUpdate);
            var slerpAmt:Float = _slerpCur / _slerpMax;
            if (slerpAmt > 1.0) {
                slerpAmt = 1.0;
                _slerping = false;
            }
            
            _quat = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
        }
        
        let scaleMatrix:GLKMatrix4 = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
        var rotationMatrix:GLKMatrix4 = GLKMatrix4MakeWithQuaternion(_quat);

        // Compute the model view matrix for the object rendered with GLKit
        var modelViewMatrix:GLKMatrix4 = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0);
//        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, self.camera.view);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, scaleMatrix);

        self.effect.transform.modelviewMatrix = modelViewMatrix
        _modelViewMatrix = modelViewMatrix

        // Compute the model view matrix for the object rendered with ES2
        modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0);
//        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, self.camera.view);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, scaleMatrix);

        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil);

        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
 
        updateDE(_cube)
    }
    
    func updateDE(_ de:DrawableElement) {
        de._userScale = 1.0
        de._projectionMatrix = _projectionMatrix;
        de._modelViewMatrix = _modelViewMatrix;
        de.update(Float(self.timeSinceLastUpdate));
    }
}

//
// MARK: - GLKView Delegate
//

/// Extension to implement the GLKViewDelegate methods.
extension CubeViewController {
    
    /// Draw the view's contents using OpenGL ES.
    ///
    /// - Parameters:
    ///   - view: The GLKView object to redraw contents into.
    ///   - rect: Rectangle that describes the area to draw into.
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // Set the color we want to clear the screen with (before drawing) to black.
        glClearColor(_curRed, 0.85, 0.85, 1.0)
        // Clear the contents of the screen (the color buffer) with the black color we just set.
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        
        _cube.draw();
        
//        effect.prepareToDraw()
//        _triangle.render();
    }
    
    //
    // MARK: - Setup The Shader
    //
    
    func prepareEffectWithModelMatrix(modelMatrix:GLKMatrix4, viewMatrix:GLKMatrix4, projectionMatrix:GLKMatrix4) {
        effect.transform.modelviewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
        effect.transform.projectionMatrix = projectionMatrix;
        effect.prepareToDraw()
    }
}
