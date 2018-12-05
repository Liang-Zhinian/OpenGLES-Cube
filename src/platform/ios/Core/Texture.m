//
//  Texture.m
//  airhockey
//
//  Created by sprite on 2018/12/4.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import "Texture.h"

@interface Texture() {
    GLKTextureInfo * _textureInfo;
    GLKEffectPropertyTexture * _effectPropertyTexture;
}

@end

@implementation Texture

@synthesize textureInfo = _textureInfo;
@synthesize effectPropertyTexture = _effectPropertyTexture;

- (id) initWithPathForResource:(NSString *) relativePath ofType:(NSString *) type {
    if(self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:relativePath ofType:type];
        
        NSError *error;
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                            forKey:GLKTextureLoaderOriginBottomLeft];
        
        
        _textureInfo = [GLKTextureLoader textureWithContentsOfFile:path
                                                                options:options error:&error];
        if (self.textureInfo == nil)
            NSLog(@"Error loading texture: %@", [error localizedDescription]);
        
        _effectPropertyTexture = [[GLKEffectPropertyTexture alloc] init];
        _effectPropertyTexture.enabled = YES;
        _effectPropertyTexture.envMode = GLKTextureEnvModeDecal;
        _effectPropertyTexture.name = _textureInfo.name;
    }
    
    return self;
}

@end
