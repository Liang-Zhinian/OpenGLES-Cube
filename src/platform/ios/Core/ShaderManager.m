//
//  ShaderManager.m
//  airhockey
//
//  Created by sprite on 2018/12/5.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import "ShaderManager.h"
#import "Shader.h"

ShaderManager* shaderManagerSingleton = nil;

@interface ShaderManager() {
    NSMutableDictionary* shaderCache;
}

@end
@implementation ShaderManager

-(id)init{
    if (self=[super init]){
        shaderCache = [[NSMutableDictionary alloc] initWithCapacity:50];
    }
    return self;
}
-(void)dealloc{
    [shaderCache removeAllObjects];
//    [shaderCache release];
//    [super dealloc];
}

-(void)loadShader{
}

-(Shader*)_getShaderWithName:(NSString*)name{
    Shader* _simpleShader = [shaderCache objectForKey:name];
    if (_simpleShader==nil){
        _simpleShader = [[Shader alloc] init];
        
        if ([name isEqualToString:@"PointsMilkyWay"]){
            [_simpleShader addUniform:        @"projectionMatrix"];
            [_simpleShader addUniform:        @"modelViewMatrix"];
            [_simpleShader addUniform:        @"UserScale"];
            [_simpleShader addUniform:        @"pointSizePreMultiply"];
            [_simpleShader addUniform:        @"Sampler"];
            [_simpleShader addUniform:        @"SamplerDust"];
            [_simpleShader addAttribute:    @"Position"];
            [_simpleShader addAttribute:    @"PointSize"];
            [_simpleShader addAttribute:    @"Color"];
            [_simpleShader addAttribute:    @"texCoordIn"];
        }
        if ([name isEqualToString:@"PointsMilkyWayToTexture"]){
            [_simpleShader addUniform:        @"modelViewMatrix"];
            [_simpleShader addUniform:        @"SamplerDust"];
            [_simpleShader addUniform:        @"cameraPosition"];
            [_simpleShader addAttribute:    @"texCoordIn"];
            [_simpleShader addAttribute:    @"Position"];
        }
        if ([name isEqualToString:@"QuadMilkyWay"]){
            [_simpleShader addUniform:        @"projectionMatrix"];
            [_simpleShader addUniform:        @"modelViewMatrix"];
            [_simpleShader addUniform:        @"Sampler"];
            [_simpleShader addUniform:        @"Opacity"];
            [_simpleShader addAttribute:    @"Position"];
            [_simpleShader addAttribute:    @"TextureCoord"];
        }
        if ([name isEqualToString:@"/assets/shaders/cube_shader"]){
            [_simpleShader addUniform:        @"u_ProjectionMatrix"];
            [_simpleShader addUniform:        @"u_MvMatrix"];
//            [_simpleShader addUniform:        @"u_LightPos"];
            [_simpleShader addAttribute:    @"a_Position"];
            [_simpleShader addAttribute:    @"a_Color"];
//            [_simpleShader addAttribute:    @"a_Normal"];
//            [_simpleShader addAttribute:    @"a_TextureCoord"];
        }
        [_simpleShader loadShaders:name];
        [shaderCache setObject:_simpleShader forKey:name];
//        [_simpleShader release];
    }
    return _simpleShader;
}


+(Shader*)getShaderWithName:(NSString*)name{
    if (shaderManagerSingleton==nil){
        shaderManagerSingleton = [[ShaderManager alloc] init];
    }
    return [shaderManagerSingleton _getShaderWithName:name];
}

@end
