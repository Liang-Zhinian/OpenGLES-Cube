//
//  Cube.h
//  airhockey
//
//  Created by Sprite on 2018/12/1.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#ifndef Cube_h
#define Cube_h

#include <stdio.h>
#include "platform_gl.h"
#include "program.h"
#include "linmath.h"

void draw_cube(const GLvoid* cube, const ColorProgram* color_program, mat4x4 m);

#endif /* Cube_h */
