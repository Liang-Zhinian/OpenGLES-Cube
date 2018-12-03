

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

//helper extensions to pass arguments to GL land
extension Int32 {
    func __conversion() -> GLenum {
        return GLuint(self)
    }
    
    func __conversion() -> GLboolean {
        return GLboolean(UInt8(self))
    }
}

extension Int {
    func __conversion() -> Int32 {
        return Int32(self)
    }
    
    func __conversion() -> GLubyte {
        return GLubyte(self)
    }
    
}

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
}

//
// MARK: - View Controller
//

/// Our subclass of GLKViewController to perform drawing, and logic updates using OpenGL ES.
final class CubeViewController: GLKViewController {
    
    /// Vertices array that stores 4 Vertex objects used to draw and color a square on screen.
    //    var Vertices:[Vertex] = VerticesCube
    
    /// Array used to store the indices in the order we want to draw the triangles of our square.
    //  var Indices:[GLuint] = IndicesTrianglesCube
    
    //
    // MARK: - Variables And Properties
    //
    
    /// Reference to provide easy access to our EAGLContext.
    var context: EAGLContext?
    
    /// Effect to facilitate having to write shaders in order to achieve shading and lighting.
    var effect = GLKBaseEffect()
    
    /// Used to store and determine the rotation value of our drawn geometry.
    var rotation: Float = 0.0
    
    /// Element buffer object. Stores the indices that tell OpenGL what vertices to draw.
    var ebo = GLuint()
    
    /// Vertex buffer object. Stores our vertex information within the GPU's memory.
    var vbo = GLuint()
    
    /// Vertex array object. Stores vertex attribute calls that facilitate future drawing. Instead of having to bind/unbind
    /// several buffers constantly to perform drawn, you can simply bind your VAO, make the vertex attribute cals you would
    /// to draw elements on screen, and then whenever you want to draw you simply bind your VAO and it stores those other
    /// vertex attribute calls.
    var vao = GLuint()
    
    
    var Vertices  = VerticesCube
    var Indices = IndicesTrianglesCube
    var indexBufferSize:Int = 36 * 4 * 1024 * 8
    var vertexBufferSize:Int = 24 * 40 * 1024 * 8
    var appendIndex:Int = 0
    
    var _anchor_position:GLKVector3!
    var _current_position:GLKVector3!
    var _beta:Float!
    var _garma:Float!
    var camera:SphereCamera!
    var PI = Float(M_PI)
    let NORMAL:[String:(x:Float, y:Float, z:Float)] = [
        "Y" : F3(x:0,1,0),
        "-Y" : F3(x:0,-1,0),
        "X" : F3(x:1,0,0),
        "-X" : F3(x:-1,0,0),
        "Z" : F3(x:0,0,1),
        "-Z" : F3(x:0,0,-1)
    ]
    
    
    var modelMatrix:GLKMatrix4! // transformations of the model
    var _modelViewProjectionMatrix:GLKMatrix4!;
    var _normalMatrix:GLKMatrix3!;
//    var viewMatrix:GLKMatrix4! // camera position and orientation
//    var projectionMatrix:GLKMatrix4! // view frustum (near plane, far plane)
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
    var _program:GLuint = 0
    var _program2:GLuint = 0
    var _shader:Shader!
    
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
//        _program = build_program_from_assets("shaders/color_shader.vsh", "shaders/color_shader.fsh")
//        _program2 = build_program_from_assets("shaders/color_shader.vsh", "shaders/color_shader.fsh")
        
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
        self.effect.colorMaterialEnabled = GLboolean(GL_TRUE)
        configureDefaultLight()
    }
    
    func configureDefaultLight(){
        self.effect.light0.enabled = GLboolean(GL_TRUE)
        self.effect.light0.position = GLKVector4Make(2, 5, 10, 1.0);
        self.effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1.0);
        self.effect.light0.ambientColor = GLKVector4Make(1, 0, 1, 1);
        self.effect.light0.specularColor = GLKVector4Make(1, 1, 0, 1);
    }
    
    func setupRenderBuffer() {
        
    }
    
    func setupDepthBuffer() {
        
    }
    
    func setupFrameBuffer() {
    }
    
    func setupVAOs() {
        
        // Generate and bind a vertex array object.
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
    }
    
    func createVertexBuffers() {
        // VBO
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
        // Generatea a buffer for our vertex buffer object.
        glGenBuffers(1, &vbo)
        // Bind the vertex buffer object we just generated (created).
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        // Pass data for our vertices to the vertex buffer object.
        //        let vertexBufferSize = Vertices.count * vertexSize
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexBufferSize, Vertices, GLenum(GL_DYNAMIC_DRAW))
        
        // EBO
        // Generatea a buffer for our element buffer object.
        glGenBuffers(1, &ebo)
        // Bind the element buffer object we just generated (created).
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        // Pass data for our element indices to the element buffer object.
        //        indexBufferSize = Indices.size()
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBufferSize, &Indices, GLenum(GL_DYNAMIC_DRAW))
    }
    
    private func setupGL() {
        
        _shader = Shader()
        _shader.loadShaders()
        
        let ves = genOneCubeVertices(position: GLKVector3Make(0, 0, 0), color: (1,0.5,0,1))
        let ins = genOneCubeIndices(index: 0)
        Vertices = []
        Indices = []
        Vertices.append(contentsOf: ves)
        Indices.append(contentsOf: ins)
        
        
        // init GL stuff here
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_DEPTH_TEST));
        glDepthFunc(GLenum(GL_LEQUAL));
        // Enable Transparency
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        configureVertexArrayObject()
    }
    
    func configureVertexArrayObject() {
        
        // Helper variables to identify the position and color attributes for OpenGL calls.
        let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
        let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
        let vertexAttribNormal = GLuint(GLKVertexAttrib.normal.rawValue)
        
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
        // The byte offset, in memory, of our color information within a Vertex object.
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        // Swift pointer object that stores the offset of the color information within our Vertex structure.
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        let normalOffset = MemoryLayout<GLfloat>.stride * 7
        let normalOffsetPointer = UnsafePointer<Int>(bitPattern: normalOffset)
        
        // VAO
        setupVAOs()
        
        // VBO & EBO
        createVertexBuffers()
        
        // Enable the position vertex attribute to then specify information about how the position of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribPosition)
        glVertexAttribPointer(vertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), nil)
        
        // Enable the colors vertex attribute to then specify information about how the color of a vertex is stored.
        glEnableVertexAttribArray(vertexAttribColor)
        glVertexAttribPointer(vertexAttribColor, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), colorOffsetPointer)
        
        glEnableVertexAttribArray(vertexAttribNormal)
        glVertexAttribPointer(vertexAttribNormal, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(vertexSize), normalOffsetPointer)
        
        // Unbind all buffers and objects.
        
        // Unbind the vertex buffer and the vertex array object.
        // Bind back to the default state.
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
        _rotMatrix = GLKMatrix4Identity;
        _quat = GLKQuaternionMake(0, 0, 0, 1);
        _quatStart = GLKQuaternionMake(0, 0, 0, 1);
        
        let dtRec:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CubeViewController.doubleTap(tap:)))
        dtRec.numberOfTapsRequired = 2;
        self.view.addGestureRecognizer(dtRec);
    }
    
    func resize() {
        
        self.camera = SphereCamera(width: view.bounds.width,
                                   height: view.bounds.height)
//        self.effect.transform.projectionMatrix = self.camera.projection
    }
    
    
    /// Perform cleanup, and delete buffers and memory.
    private func tearDownGL() {
        // Set the current EAGLContext to our context. This ensures we are deleting buffers against it and potentially not a
        // different context.
        EAGLContext.setCurrent(context)
        
        // Delete the vertex array object, the element buffer object, and the vertex buffer object.
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        
        // Set the current EAGLContext to nil.
        EAGLContext.setCurrent(nil)
        
        // Then nil out or variable that references our EAGLContext.
        context = nil
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
            let location = touch.location(in: view)
            _anchor_position = GLKVector3Make(Float(location.x), Float(location.y), 0)
            _current_position = _anchor_position
            
            _quatStart = _quat;
            
            _beta = self.camera.beta
            _garma = self.camera.garma
            pick(x: Float(_anchor_position.x), y: Float(_anchor_position.y))
            
            let previousIndex = appendIndex
            for _ in (0 ..< 10) {
//                let ves = genOneCubeVertices(position: GLKVector3Make(Float(appendIndex % 10), Float(appendIndex%100 / 10), Float(appendIndex/100)), color: (Float(appendIndex % 10) / Float(10), Float(appendIndex % 100) / Float(100), Float(appendIndex)/1000, 1))
//                let ins = genOneCubeIndices(index: appendIndex)
//                Vertices.append(contentsOf:ves)
//                Indices.append(contentsOf:ins)
//                appendIndex += 1
            }
            
            
            pushVertexBuffer(cubeIndex: previousIndex, number: 10)
            pushIndexBuffer(cubeIndex: previousIndex, number: 10)
            
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
    
    func pushVertexBuffer(cubeIndex:Int, number:Int){
        let sizeVertex = sizeofVertex()
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), GLintptr(cubeIndex * 24 * sizeVertex), GLsizeiptr(number * 24 * sizeVertex), &Vertices + cubeIndex * 24 * sizeVertex)
    }
    
    func pushIndexBuffer(cubeIndex:Int, number:Int){
        let sizeOfGLuint = MemoryLayout<GLuint>.stride
        glBufferSubData(GLenum(GL_ELEMENT_ARRAY_BUFFER), cubeIndex * 36 * sizeOfGLuint, number * 36 * sizeOfGLuint, &Indices + cubeIndex * 36 * sizeOfGLuint)
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
    
    ///
    func intersectsTriangle(near:GLKVector3, far:GLKVector3, a: GLKVector3, b: GLKVector3, c: GLKVector3, normal:GLKVector3) -> (intersect:Bool, result:GLKVector3?){
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
    
    func pick(x:Float, y:Float){
        
        //follow http://schabby.de/picking-opengl-ray-tracing/
        let viewVector3 = GLKVector3Normalize(GLKVector3Subtract(self.camera.target, self.camera.position))
        var hVector3 = GLKVector3Normalize(GLKVector3CrossProduct(viewVector3, self.camera.up))
        var vVector3 = GLKVector3Normalize(GLKVector3CrossProduct(hVector3, viewVector3))
        
        let width = Float(self.camera.width)
        let height = Float(self.camera.height)
        
        // convert fovy to radians
        let rad = self.camera.fov * PI / 180
        let vLength = tan( rad / 2 ) * self.camera.near
        let hLength = vLength * (width / height)
        
        vVector3 = GLKVector3MultiplyScalar(vVector3, vLength)
        hVector3 = GLKVector3MultiplyScalar(hVector3, hLength)
        
        // translate mouse coordinates so that the origin lies in the center
        // of the view port
        var xPoint = x - width / 2
        var yPoint = y - height / 2
        xPoint = xPoint/width * 2
        yPoint = -yPoint/height * 2
        
        // compute direction of picking ray by subtracting intersection point
        
        var direction = GLKVector3Add(GLKVector3MultiplyScalar(viewVector3, self.camera.near), GLKVector3MultiplyScalar(hVector3, xPoint))
        direction = GLKVector3Add(direction, GLKVector3MultiplyScalar(vVector3, yPoint))
        
        // linear combination to compute intersection of picking ray with
        // view port plane
        let near = GLKVector3Add(self.camera.position, direction)
        let far = GLKVector3Add(self.camera.position, GLKVector3MultiplyScalar(direction, self.camera.far / self.camera.near))
        
        /*
        // debug
        let normalizedPoint:CGPoint = getNormalizedCGPoint(in: self.view, locationInView: CGPoint(x:CGFloat(x),y:CGFloat(y)))
        let ray = convert_normalized_2D_point_to_ray(normalized_x: Float(normalizedPoint.x), normalized_y: Float(normalizedPoint.y));
        let near_point = GLKVector3Make(ray.0.x, ray.0.y, ray.0.z)
        let far_point = GLKVector3Make(ray.1.x, ray.1.y, ray.1.z)
        print("near_point : " + String(near_point.x) + " " + String(near_point.y) + " " + String(near_point.z))
        print("far_point : " + String(far_point.x) + " " + String(far_point.y) + " " + String(far_point.z))
        */
        
        print("near : " + String(near.x) + " " + String(near.y) + " " + String(near.z))
        print("far : " + String(far.x) + " " + String(far.y) + " " + String(far.z))
 
        xPoint = x * Float(UIScreen.main.scale)
        yPoint = y * Float(UIScreen.main.scale)

        var testResult:Bool=false;

        var viewport:[GLint]=[0,0,0,0];
        glGetIntegerv(GLenum(GL_VIEWPORT), &viewport);

        let uiKitOffset:Int = 113; //Need to factor in the height of the nav bar + the height of the tab bar at the bottom in the storyboard.
        let nearPt:GLKVector3 = GLKMathUnproject(GLKVector3Make(xPoint,
                                                                (yPoint-Float(viewport[3]+uiKitOffset)) * -1,
                                                                0.0),
                                                 effect.transform.modelviewMatrix,
                                                 effect.transform.projectionMatrix,
                                                 &viewport[0] ,
                                                 &testResult);

        var farPt:GLKVector3 = GLKMathUnproject(GLKVector3Make(xPoint,
                                                               (yPoint-Float(viewport[3]+uiKitOffset)) * -1,
                                                               1.0),
                                                effect.transform.modelviewMatrix,
                                                effect.transform.projectionMatrix,
                                                &viewport[0] ,
                                                &testResult);

        farPt = GLKVector3Subtract(farPt, nearPt);
        
        print("nearPt : " + String(nearPt.x) + " " + String(nearPt.y) + " " + String(nearPt.z))
        print("farPt : " + String(farPt.x) + " " + String(farPt.y) + " " + String(farPt.z))
        
        for index in (1 ..< (Indices.count+1)) {
            if index != 1 && index % 3 == 0{
                let aa = Vertices[Int(Indices[index-3])].Position
                let bb = Vertices[Int(Indices[index-2])].Position
                let cc = Vertices[Int(Indices[index-1])].Position
                let nn = Vertices[Int(Indices[index-1])].Normal
                let a = GLKVector3Make(aa.x, aa.y, aa.z)
                let b = GLKVector3Make(bb.x, bb.y, bb.z)
                let c = GLKVector3Make(cc.x, cc.y, cc.z)
                let n = GLKVector3Make(Float(nn.x), Float(nn.y), Float(nn.z))
                let data = intersectsTriangle(near: nearPt, far:farPt,  a: a, b: b, c: c, normal:n)
                if data.intersect {
                    print("intersect point: " + String( data.result!.x) + " " + String( data.result!.y) + " " + String( data.result!.z) + " " + String(index / 3))
                    
                    drawPickedTriangle(a:a, b:b, c:c)
                }
            }
        }
        
        
    }
    
    func getNormalizedCGPoint(in view: UIView?, locationInView:CGPoint) -> CGPoint
    {
        let normalizedX:CGFloat = ((locationInView.x / (view?.bounds.size.width)!) * 2 - 1);
        let normalizedY:CGFloat = (-((locationInView.y / (view?.bounds.size.height)!) * 2 - 1));
        return CGPoint(x: normalizedX, y: normalizedY);
    }
    
    func convert_normalized_2D_point_to_ray(normalized_x:Float, normalized_y:Float) -> ((x:Float,y:Float,z:Float),(x:Float,y:Float,z:Float)) {
        // We'll convert these normalized device coordinates into world-space
        // coordinates. We'll pick a point on the near and far planes, and draw a
        // line between them. To do this transform, we need to first multiply by
        // the inverse matrix, and then we need to undo the perspective divide.
        let near_point_ndc:GLKVector4 = GLKVector4Make(normalized_x, normalized_y, -1, 1);
        let far_point_ndc:GLKVector4 = GLKVector4Make(normalized_x, normalized_y,  1, 1);
        
        var near_point_world:GLKVector4, far_point_world:GLKVector4;
        let _modelViewProjectionMatrix = GLKMatrix4Multiply(effect.transform.modelviewMatrix, effect.transform.projectionMatrix);
        let inverted_view_projection_matrix:GLKMatrix4 = GLKMatrix4Invert(_modelViewProjectionMatrix, nil);
        near_point_world = GLKMatrix4MultiplyVector4(inverted_view_projection_matrix, near_point_ndc);
        far_point_world = GLKMatrix4MultiplyVector4(inverted_view_projection_matrix, far_point_ndc);
        
        // Why are we dividing by W? We multiplied our vector by an inverse
        // matrix, so the W value that we end up is actually the *inverse* of
        // what the projection matrix would create. By dividing all 3 components
        // by W, we effectively undo the hardware perspective divide.
        near_point_world.x /= near_point_world.w;
        near_point_world.y /= near_point_world.w;
        near_point_world.z /= near_point_world.w;
        
        far_point_world.x /= far_point_world.w;
        far_point_world.y /= far_point_world.w;
        far_point_world.z /= far_point_world.w;
        
        // We don't care about the W value anymore, because our points are now
        // in world coordinates.
        let near_point_ray:GLKVector3 = GLKVector3Make(near_point_world.x, near_point_world.y, near_point_world.z);
        let far_point_ray:GLKVector3 = GLKVector3Make(far_point_world.x, far_point_world.y, far_point_world.z)
        var vector_between:GLKVector3;
        vector_between = GLKVector3Add(far_point_ray, near_point_ray);
        return (
            (near_point_ray[0], near_point_ray[1], near_point_ray[2]),
            (vector_between[0], vector_between[1], vector_between[2]));
    }
    
    /**
     * 渲染选中的三角形
     */
    
    var triangleVertices:[Vertex] = [
//        Vertex(Position: (1, -1, 1),    Color: (0, 0, 0, 1), Normal: (0, 0, 1)),
//        Vertex(Position: (1, 1, 1),     Color: (0, 0, 0, 1), Normal: (0, 0, 1)),
//        Vertex(Position: (-1, 1, 1),    Color: (0, 0, 0, 1), Normal: (0, 0, 1)),
//        Vertex(Position: (-1, -1, 1),   Color: (0, 0, 0, 1), Normal: (0, 0, 1)),
        ]
    var triangleIndices:[GLubyte] = [
        // Front
        0, 1, 2,
//        2, 3, 0,
        ]
    var triangleVAO:GLuint = 0
    var triangleVBO:GLuint = 0
    
    func drawPickedTriangle(a:GLKVector3, b:GLKVector3, c:GLKVector3) {
        triangleVertices = []
        let vertices:[Vertex] = [
                    Vertex(Position: (a.x, a.y, a.z),    Color: (0, 0, 0, 1), Normal: (0, 0, -1)),
                    Vertex(Position: (b.x, b.y, b.z),    Color: (0, 0, 0, 1), Normal: (0, 0, -1)),
                    Vertex(Position: (c.x, c.y, c.z),    Color: (0, 0, 0, 1), Normal: (0, 0, -1)),
        ]
        triangleVertices.append(contentsOf:vertices)

        glGenVertexArrays(1, &triangleVAO)
//        defer { glDeleteVertexArrays(1, &triangleVAO) }
        // Bind the Vertex Array Object first, then bind and set
        // vertex buffer(s) and attribute pointer(s).
        glBindVertexArray(triangleVAO)
        
        glGenBuffers(1, &triangleVBO)
//        defer { glDeleteBuffers(1, &triangleVBO) }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), triangleVBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), triangleVertices.size(), triangleVertices, GLenum(GL_DYNAMIC_DRAW))
        
        var EBO:GLuint = 0
        // Generatea a buffer for our element buffer object.
        glGenBuffers(1, &EBO)
        // Bind the element buffer object we just generated (created).
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), EBO)
        // Pass data for our element indices to the element buffer object.
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), triangleIndices.size(), &triangleIndices, GLenum(GL_DYNAMIC_DRAW))

        // Helper variables to identify the position and color attributes for OpenGL calls.
        let vertexAttribColor = GLuint(GLKVertexAttrib.color.rawValue)
        let vertexAttribPosition = GLuint(GLKVertexAttrib.position.rawValue)
        let vertexAttribNormal = GLuint(GLKVertexAttrib.normal.rawValue)
        
        // The size, in memory, of a Vertex structure.
        let vertexSize = MemoryLayout<Vertex>.stride
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
        glBindVertexArray(0)
        
    }
    
    func genOneCubeVertices(position:GLKVector3, color:(r:Float, g:Float, b:Float, a:Float)) -> [Vertex]{
        
        let x = position.x
        let y = position.y
        let z = position.z
        let unit:Float = 1
        
        return [
            Vertex(Position: F3(x:x+unit, y-unit, z+unit) ,   Color: color, Normal:NORMAL["Z"]! ), //0
            Vertex(Position: F3(x:x+unit, y+unit, z+unit)  ,  Color: color, Normal:NORMAL["Z"]! ), //1
            Vertex(Position: F3(x:x-unit, y+unit, z+unit) ,   Color: color, Normal:NORMAL["Z"]! ), //2
            Vertex(Position: F3(x:x-unit, y-unit, z+unit),    Color: color, Normal:NORMAL["Z"]! ), //3
            
            Vertex(Position: F3(x:x+unit, y+unit, z-unit) ,   Color: color, Normal:NORMAL["-Z"]! ), //4
            Vertex(Position: F3(x:x-unit, y-unit, z-unit),    Color: color, Normal:NORMAL["-Z"]! ), //5
            Vertex(Position: F3(x:x+unit, y-unit, z-unit) ,   Color: color, Normal:NORMAL["-Z"]! ), //6
            Vertex(Position: F3(x:x-unit, y+unit, z-unit),    Color: color, Normal:NORMAL["-Z"]! ), //7
            
            Vertex(Position: F3(x:x-unit, y-unit, z+unit),    Color: color, Normal:NORMAL["-X"]! ), //8
            Vertex(Position: F3(x:x-unit, y+unit, z+unit)  ,  Color: color, Normal:NORMAL["-X"]! ), //9
            Vertex(Position: F3(x:x-unit, y+unit, z-unit) ,   Color: color, Normal:NORMAL["-X"]! ), //10
            Vertex(Position: F3(x:x-unit, y-unit, z-unit),    Color: color, Normal:NORMAL["-X"]! ), //11
            
            Vertex(Position: F3(x:x+unit, y-unit, z-unit) ,   Color: color, Normal:NORMAL["X"]! ), // 12
            Vertex(Position: F3(x:x+unit, y+unit, z-unit)  ,  Color: color, Normal:NORMAL["X"]! ), //13
            Vertex(Position: F3(x:x+unit, y+unit, z+unit),    Color: color, Normal:NORMAL["X"]! ), //14
            Vertex(Position: F3(x:x+unit, y-unit, z+unit),    Color: color, Normal:NORMAL["X"]! ), //15
            
            Vertex(Position: F3(x:x+unit, y+unit, z+unit),    Color: color, Normal:NORMAL["Y"]!), //16
            Vertex(Position: F3(x:x+unit, y+unit, z-unit) ,   Color: color, Normal:NORMAL["Y"]! ), //17
            Vertex(Position: F3(x:x-unit, y+unit, z-unit),    Color: color, Normal:NORMAL["Y"]! ), // 18
            Vertex(Position: F3(x:x-unit, y+unit, z+unit),    Color: color, Normal:NORMAL["Y"]! ), //19
            
            Vertex(Position: F3(x:x+unit, y-unit, z-unit) ,   Color: color, Normal:NORMAL["-Y"]! ), //20
            Vertex(Position: F3(x:x+unit, y-unit, z+unit) ,   Color: color, Normal:NORMAL["-Y"]! ), //21
            Vertex(Position: F3(x:x-unit, y-unit, z+unit),    Color: color, Normal:NORMAL["-Y"]! ), //22
            Vertex(Position: F3(x:x-unit, y-unit, z-unit),    Color: color, Normal:NORMAL["-Y"]! ) //23
        ]
    }
    
    func genOneCubeIndices(index:Int) -> [GLubyte]{
        
        let vertexCount = GLubyte(index * 24)
        return [
            vertexCount, vertexCount+1, vertexCount+2,
            vertexCount+2, vertexCount+3, vertexCount,
            
            vertexCount+4, vertexCount+6, vertexCount+5,
            vertexCount+4, vertexCount+5, vertexCount+7,
            
            vertexCount+8, vertexCount+9, vertexCount+10,
            vertexCount+10, vertexCount+11, vertexCount+8,
            
            vertexCount+12, vertexCount+13, vertexCount+14,
            vertexCount+14, vertexCount+15, vertexCount+12,
            
            vertexCount+16, vertexCount+17, vertexCount+18,
            vertexCount+18, vertexCount+19, vertexCount+16,
            
            vertexCount+20, vertexCount+21, vertexCount+22,
            vertexCount+22, vertexCount+23, vertexCount+20
        ]
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
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, scaleMatrix);

        self.effect.transform.modelviewMatrix = modelViewMatrix

        // Compute the model view matrix for the object rendered with ES2
        modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, rotationMatrix);
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, scaleMatrix);

        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil);

        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
 
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
        
        drawTheCube()
        
        drawTheTriangle()
    }
    
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
    
    func drawTheCube() {
        glBindVertexArrayOES(vao);
//        glBindVertexArrayOES(vbo);
        
        // Render the object again with ES2
//        glUseProgram(_shader.program);
        effect.prepareToDraw()
        
        // update the attribute color
        let vertexColorLocation:GLuint = GLuint(glGetAttribLocation(_shader.program, "a_Color"));
        // Pass in the color info
        glVertexAttribPointer(
            vertexColorLocation,
            CubeViewController.COLOR_DATA_SIZE,
            GLenum(GL_FLOAT),
            GLboolean(GL_FALSE),
            0,
            CubeViewController.CUBE_COLOR_DATA
        );
//        glEnableVertexAttribArray(vertexColorLocation);
        
//        withUnsafePointer(to: &_modelViewProjectionMatrix, {
//            $0.withMemoryRebound(to: Float.self, capacity: 16, {
//                glUniformMatrix4fv(_shader.uniformModelViewProjectionMatrix, 1, 0, $0)
//            })
//        })
//
//        withUnsafePointer(to: &_normalMatrix, {
//            $0.withMemoryRebound(to: Float.self, capacity: 9, {
//                glUniformMatrix3fv(_shader.uniformNormalMatrix, 1, 0, $0)
//            })
//        })
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
    }
    
    func drawTheTriangle(){
        if triangleVAO == 0 {
            return
        }
        
        glBindVertexArrayOES(triangleVAO);
        effect.prepareToDraw()
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(triangleIndices.count), GLenum(GL_UNSIGNED_BYTE), nil)
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
