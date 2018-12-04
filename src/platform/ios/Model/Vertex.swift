/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import GLKit

//
// MARK: - Vertex
//

struct Vertex {
    var Position: (x:Float, y:Float, z:Float)
    var Color:  (r:Float, g:Float, b:Float, a:Float)
    var TexCoord: (x:Float, y:Float)
    var Normal:  (x:Float, y:Float, z:Float)
}

struct Position {
    var x:Float
    var y:Float
    var z:Float
}

struct Color{
    var r:Float
    var g:Float
    var b:Float
    var a:Float
}

struct TexCoord {
    var x:Float
    var y:Float
}

struct Normal {
    var x:Float
    var y:Float
    var z:Float
}


let NORMAL:[String:(x:Float, y:Float, z:Float)] = [
    "Y" : F3(x:0,1,0),
    "-Y" : F3(x:0,-1,0),
    "X" : F3(x:1,0,0),
    "-X" : F3(x:-1,0,0),
    "Z" : F3(x:0,0,1),
    "-Z" : F3(x:0,0,-1)
]

struct VertexGenerator {
    
    static func genOneCubeVertices(position:GLKVector3, color:(r:Float, g:Float, b:Float, a:Float)) -> [Vertex]{
        
        let x = position.x
        let y = position.y
        let z = position.z
        let unit:Float = 1
        
        return [
            /*
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
            
            */
 
 Vertex(Position: F3(x:x+unit, y-unit, z+unit), Color: color, TexCoord: (x:0, y:1), Normal:NORMAL["Z"]! ), //0
 Vertex(Position: F3(x:x+unit, y+unit, z+unit), Color: color, TexCoord: (0, 2.0/3.0), Normal:NORMAL["Z"]! ), //1
 Vertex(Position: F3(x:x-unit, y+unit, z+unit), Color: color, TexCoord: (1.0/3.0, 2.0/3.0), Normal:NORMAL["Z"]! ), //2
 Vertex(Position: F3(x:x-unit, y-unit, z+unit), Color: color, TexCoord: (1.0/3.0, 1), Normal:NORMAL["Z"]! ), //3
 
 Vertex(Position: F3(x:x+unit, y+unit, z-unit), Color: color, TexCoord: (1.0/3.0, 1), Normal:NORMAL["-Z"]! ), //4
 Vertex(Position: F3(x:x-unit, y-unit, z-unit), Color: color, TexCoord: (1.0/3.0, 2.0/3.0), Normal:NORMAL["-Z"]! ), //5
 Vertex(Position: F3(x:x+unit, y-unit, z-unit), Color: color, TexCoord: (2.0/3.0, 2.0/3.0), Normal:NORMAL["-Z"]! ), //6
 Vertex(Position: F3(x:x-unit, y+unit, z-unit), Color: color, TexCoord: (2.0/3.0, 1), Normal:NORMAL["-Z"]! ), //7
 
 Vertex(Position: F3(x:x-unit, y-unit, z+unit), Color: color, TexCoord: (2.0/3.0, 1), Normal:NORMAL["-X"]! ), //8
 Vertex(Position: F3(x:x-unit, y+unit, z+unit), Color: color, TexCoord: (2.0/3.0, 2.0/3.0), Normal:NORMAL["-X"]! ), //9
 Vertex(Position: F3(x:x-unit, y+unit, z-unit), Color: color, TexCoord: (1, 2.0/3.0), Normal:NORMAL["-X"]! ), //10
 Vertex(Position: F3(x:x-unit, y-unit, z-unit), Color: color, TexCoord: (1, 1), Normal:NORMAL["-X"]! ), //11
 
 Vertex(Position: F3(x:x+unit, y-unit, z-unit), Color: color, TexCoord: (0, 2.0/3.0), Normal:NORMAL["X"]! ), // 12
 Vertex(Position: F3(x:x+unit, y+unit, z-unit), Color: color, TexCoord: (0, 1.0/3.0), Normal:NORMAL["X"]! ), //13
 Vertex(Position: F3(x:x+unit, y+unit, z+unit), Color: color, TexCoord: (1.0/3.0, 1.0/3.0), Normal:NORMAL["X"]! ), //14
 Vertex(Position: F3(x:x+unit, y-unit, z+unit), Color: color, TexCoord: (1.0/3.0, 2.0/3.0), Normal:NORMAL["X"]! ), //15
 
 Vertex(Position: F3(x:x+unit, y+unit, z+unit), Color: color, TexCoord: (1.0/3.0, 2.0/3.0), Normal:NORMAL["Y"]!), //16
 Vertex(Position: F3(x:x+unit, y+unit, z-unit), Color: color, TexCoord: (1.0/3.0, 1.0/3.0), Normal:NORMAL["Y"]! ), //17
 Vertex(Position: F3(x:x-unit, y+unit, z-unit), Color: color, TexCoord: (2.0/3.0, 1.0/3.0), Normal:NORMAL["Y"]! ), // 18
 Vertex(Position: F3(x:x-unit, y+unit, z+unit), Color: color, TexCoord: (2.0/3.0, 2.0/3.0), Normal:NORMAL["Y"]! ), //19
 
 Vertex(Position: F3(x:x+unit, y-unit, z-unit), Color: color, TexCoord: (2.0/3.0, 2.0/3.0), Normal:NORMAL["-Y"]! ), //20
 Vertex(Position: F3(x:x+unit, y-unit, z+unit), Color: color, TexCoord: (2.0/3.0, 1.0/3.0), Normal:NORMAL["-Y"]! ), //21
 Vertex(Position: F3(x:x-unit, y-unit, z+unit), Color: color, TexCoord: (1, 1.0/3.0), Normal:NORMAL["-Y"]! ), //22
 Vertex(Position: F3(x:x-unit, y-unit, z-unit), Color: color, TexCoord: (1, 2.0/3.0), Normal:NORMAL["-Y"]! ) //23
 
        ]
    }
    
    static func genOneCubeIndices(index:Int) -> [GLubyte]{
        
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
