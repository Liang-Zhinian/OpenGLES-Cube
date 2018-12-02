//
//  Shader.h
//  airhockey
//
//  Created by Sprite on 2018/12/2.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Shader : NSObject

- (BOOL)loadShaders;

@property (nonatomic, assign)  GLuint program;
@property (nonatomic, assign)  GLint uniformModelViewProjectionMatrix;
@property (nonatomic, assign)  GLint uniformNormalMatrix;

@end
