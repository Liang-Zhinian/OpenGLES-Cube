//
//  Cube.c
//  airhockey
//
//  Created by Sprite on 2018/12/1.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#include "Cube.h"
#include "buffer.h"
#include "platform_gl.h"
#include "program.h"
#include "linmath.h"
#include <math.h>


void draw_cube(const GLvoid* cube, const ColorProgram* color_program, mat4x4 m) {
        glUseProgram(color_program->program);

        glUniformMatrix4fv(color_program->u_mvp_matrix_location, 1, GL_FALSE, (GLfloat*)m);
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
        glBindBuffer(GL_ARRAY_BUFFER, 0);
}
