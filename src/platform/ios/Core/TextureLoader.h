//
//  Texture.h
//  airhockey
//
//  Created by sprite on 2018/12/4.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    /// vertex coordinate
    float position[3];
    /// texture coordinate
    float uv[2];
} GLVertexData_t;

typedef struct{
    unsigned char* data;
    CGSize textureSize;
    GLenum textureFormat;
    const int textureUnit;
}UploadData;
/*!
 @class          TextureRenderer
 @discussion     Provides functionality to generate and render texture. Texture data can be uploaded
 per render cycle or it can be uploaded from file while generating. Methods of this
 class must be called from main thread.
 */
@interface TextureLoader : NSObject


@property (nonatomic, readonly) GLuint texture;

/*!
 @method         generateTexture
 @discussion     Generate a GL texture
 */
-(void)generateTexture;
/*!
 @method            generateTextureOfSize
 @param            textureSize
 predefined size of texture
 @discussion        generate texture with required size.This texture can be used for offscreen rendering.
 */
-(void)generateTextureOfSize:(CGSize)textureSize;
/*!
 @method         generateTexture:
 @param          texturePath
 Absolute path to texture file. It must be a valid path and texture must be readable.
 @discussion     Generate a GL texture and upload data into the texture from texturePath.
 */
-(BOOL)generateTexture:(NSString*)texturePath;

+ (GLKTextureInfo*) generateTexture:(NSString *) relativePath ofType:(NSString *) type;

/*!
 @method         renderFramebufferToTexture:
 @param          framebuffer
 This provided framebuffer will be rendered into texture
 @discussion     Render the provided framebuffer into texture. It should be called after all the
 rendering on the framebuffer is done. If it is called before rendering, only the
 last rendered object will be rendered into the texture
 */
-(void)renderFramebufferToTexture:(GLuint)framebuffer;

/*!
 @method         activeTexture
 @param          textureUnit
 Texture unit the texture will be activated to. It must be from 0 to number of availe
 texture of the device.
 @discussion     Activate a texture for rendering. It should be called from render method.
 */

-(void)activeTexture:(short)textureUnit;



/*!
 @method         deleteTexture
 @discussion     Delete GL texture. Texture must be generated again to be activated for rendering
 */
-(void)deleteTexture;

-(void)uploadData:(UploadData)uploadData;
@end

NS_ASSUME_NONNULL_END
