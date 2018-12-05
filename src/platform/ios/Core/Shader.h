//
//  Shader.h
//  airhockey
//
//  Created by Sprite on 2018/12/2.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Shader : NSObject {
    GLuint _program;
}
@property (readonly)  GLuint program;

- (BOOL)loadShaders:(NSString*)filename;

- (void)addAttribute:(NSString*)_attrib;
- (void)addUniform:(NSString*)_uniform;
- (int)getAttribute:(NSString*)_attrib;
- (int)getUniform:(NSString*)_uniform;

@end

