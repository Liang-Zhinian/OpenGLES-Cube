//
//  GLRect.swift
//  airhockey
//
//  Created by sprite on 2018/12/11.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

import Foundation

class GLRect : NSObject {
    var Id:String = "missing Id";
    var vertices:[Vertex] = []
    var indices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    init(_ id:String) {
        super.init()
        
        Id = id
    }
    
    func appendVertice(_ vertice:Vertex) {
        let newVertice = Vertex(Position: (x: vertice.Position.x, y: vertice.Position.y, z: vertice.Position.z),
                               Color: (r: vertice.Color.r, g: vertice.Color.g, b: vertice.Color.b, a: vertice.Color.a),
                               TexCoord: (x: vertice.TexCoord.x, y: vertice.TexCoord.y),
                               Normal: (x: vertice.Normal.x, y: vertice.Normal.y, z: vertice.Normal.z))
        self.vertices.append(newVertice)
    }
    
    func appendIndice(_ indice:[GLubyte]) {
        
        self.indices.append(contentsOf: indice)
    }
}
