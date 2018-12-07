//
//  Texture.m
//  airhockey
//
//  Created by sprite on 2018/12/4.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import "TextureLoader.h"
#import <GLKit/GLKit.h>

@interface TextureLoader() {
    GLuint _texture;
}
@end

@implementation TextureLoader
@synthesize texture = _texture;

-(instancetype)init {
    self = [super init];
    if (self) {
        _texture = 0;
    }
    return self;
}


-(void)generateTexture {
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    [self setTextParameters];
}



-(void)setTextParameters{
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

-(void)generateTextureOfSize:(CGSize)textureSize{
    
    [self generateTexture];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, 0);
}

-(void)renderFramebufferToTexture:(GLuint)framebuffer{
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    
}

-(BOOL)generateTexture:(NSString *)texturePath {
    NSError* error = nil;
    BOOL _generated = YES;
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:nil error:&error];
    if (!error) {
        // set texture name to current texture
        _texture = textureInfo.name;
    } else {
        _generated = NO;
    }
    return _generated;
}

+ (GLKTextureInfo*) generateTexture:(NSString *) relativePath ofType:(NSString *) type {
    NSString *path = [[NSBundle mainBundle] pathForResource:relativePath ofType:type];
    
    NSError *error;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                        forKey:GLKTextureLoaderOriginBottomLeft];
    
    
    GLKTextureInfo* _textureInfo = [GLKTextureLoader textureWithContentsOfFile:path
                                                                       options:options error:&error];
    if (_textureInfo == nil)
        NSLog(@"Error loading texture: %@", [error localizedDescription]);
    
    GLKEffectPropertyTexture* _effectPropertyTexture = [[GLKEffectPropertyTexture alloc] init];
    _effectPropertyTexture.enabled = YES;
    _effectPropertyTexture.envMode = GLKTextureEnvModeDecal;
    _effectPropertyTexture.name = _textureInfo.name;
    
    return _textureInfo;
}

-(void)activeTexture:(short)textureUnit {
    glActiveTexture(GL_TEXTURE0 + textureUnit);
    glBindTexture(GL_TEXTURE_2D, _texture);
}


-(void)uploadData:(UploadData)uploadData
{
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, uploadData.textureFormat, uploadData.textureSize.width, uploadData.textureSize.height, 0, uploadData.textureFormat, GL_UNSIGNED_BYTE, uploadData.data);
    [self setTextParameters];
}

-(void)deleteTexture {
    glDeleteTextures(1, &_texture);
    _texture = 0;
}

-(void)dealloc {
    [self deleteTexture];
}

@end
