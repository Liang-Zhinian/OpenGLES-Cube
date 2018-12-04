//
//  Texture.h
//  airhockey
//
//  Created by sprite on 2018/12/4.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface Texture : NSObject

- (id) initWithPathForResource:(NSString *) path ofType:(NSString *) type;

@property (nonatomic) GLKTextureInfo * textureInfo;
@property (nonatomic) GLKEffectPropertyTexture * effectPropertyTexture;

@end

NS_ASSUME_NONNULL_END
