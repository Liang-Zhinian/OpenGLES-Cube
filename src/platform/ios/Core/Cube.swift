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

class Cube : NSObject {
    var VerticesCube:[Vertex] = [
        // Front
        Vertex(Position: (1, -1, 1),    Color: (1, 0, 0, 1), Normal: (0, 0, 1)),
        Vertex(Position: (1, 1, 1),     Color: (0, 1, 0, 1), Normal: (0, 0, 1)),
        Vertex(Position: (-1, 1, 1),    Color: (0, 0, 1, 1), Normal: (0, 0, 1)),
        Vertex(Position: (-1, -1, 1),   Color: (0, 0, 0, 1), Normal: (0, 0, 1)),
        // Back
        Vertex(Position: (1, 1, -1),    Color: (1, 0, 0, 1), Normal: (0, 0, -1)),
        Vertex(Position: (1, -1, -1),   Color: (0, 0, 1, 1), Normal: (0, 0, -1)),
        Vertex(Position: (-1, -1, -1),  Color: (0, 1, 0, 1), Normal: (0, 0, -1)),
        Vertex(Position: (-1, 1, -1),   Color: (0, 0, 0, 1), Normal: (0, 0, -1)),
        // Left
        Vertex(Position: (-1, -1, 1),   Color: (1, 0, 0, 1), Normal: (-1, 0, 0)),
        Vertex(Position: (-1, 1, 1),    Color: (0, 1, 0, 1), Normal: (-1, 0, 0)),
        Vertex(Position: (-1, 1, -1),   Color: (0, 0, 1, 1), Normal: (-1, 0, 0)),
        Vertex(Position: (-1, -1, -1),  Color: (0, 0, 0, 1), Normal: (-1, 0, 0)),
        // Right
        Vertex(Position: (1, -1, -1),   Color: (1, 0, 0, 1), Normal: (1, 0, 0)),
        Vertex(Position: (1, 1, -1),    Color: (0, 1, 0, 1), Normal: (1, 0, 0)),
        Vertex(Position: (1, 1, 1),     Color: (0, 0, 1, 1), Normal: (1, 0, 0)),
        Vertex(Position: (1, -1, 1),    Color: (0, 0, 0, 1), Normal: (1, 0, 0)),
        // Top
        Vertex(Position: (1, 1, 1),     Color: (1, 0, 0, 1), Normal: (0, 1, 0)),
        Vertex(Position: (1, 1, -1),    Color: (0, 1, 0, 1), Normal: (0, 1, 0)),
        Vertex(Position: (-1, 1, -1),   Color: (0, 0, 1, 1), Normal: (0, 1, 0)),
        Vertex(Position: (-1, 1, 1),    Color: (0, 0, 0, 1), Normal: (0, 1, 0)),
        // Bottom
        Vertex(Position: (1, -1, -1),   Color: (1, 0, 0, 1), Normal: (0, -1, 0)),
        Vertex(Position: (1, -1, 1),    Color: (0, 1, 0, 1), Normal: (0, -1, 0)),
        Vertex(Position: (-1, -1, 1),   Color: (0, 0, 1, 1), Normal: (0, -1, 0)),
        Vertex(Position: (-1, -1, -1),  Color: (0, 0, 0, 1), Normal: (0, -1, 0))
        
    ]
    
    var IndicesTrianglesCube:[GLubyte] = [
        // Front
        0, 1, 2,
        2, 3, 0,
        // Back
        4, 6, 5,
        4, 6, 7,
        // Left
        8, 9, 10,
        10, 11, 8,
        // Right
        12, 13, 14,
        14, 15, 12,
        // Top
        16, 17, 18,
        18, 19, 16,
        // Bottom
        20, 21, 22,
        22, 23, 20
    ]
    
    override init() {
        
    }
    
    func render() {
//        glUseProgram(color_program->program);
//
//        glUniformMatrix4fv(color_program->u_mvp_matrix_location, 1, GL_FALSE, (GLfloat*)m);
//        glUniform4fv(color_program->u_color_location, 1, puck->color);
//
//        glBindBuffer(GL_ARRAY_BUFFER, puck->buffer);
//        glVertexAttribPointer(color_program->a_position_location, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
//        glEnableVertexAttribArray(color_program->a_position_location);
//
//        int circle_vertex_count = size_of_circle_in_vertices(puck->num_points);
//        int cylinder_vertex_count = size_of_open_cylinder_in_vertices(puck->num_points);
//
//        glDrawArrays(GL_TRIANGLE_FAN, 0, circle_vertex_count);
//        glDrawArrays(GL_TRIANGLE_STRIP, circle_vertex_count, cylinder_vertex_count);
//        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        
    }
}
