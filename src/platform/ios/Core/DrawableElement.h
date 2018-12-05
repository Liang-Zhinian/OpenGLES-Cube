//
//  DrawableElement.h
//  airhockey
//
//  Created by sprite on 2018/12/5.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawableElement : NSObject{
    bool        isRetina;
    bool        isIpad;
    GLKMatrix4    _modelViewMatrix;
    GLKMatrix4    _projectionMatrix;
    float        _userScale;
}
@property     GLKMatrix4    _modelViewMatrix;
@property     GLKMatrix4    _projectionMatrix;
@property     float        _userScale;

-(void)draw;
-(void)update:(float)timeInterval;
-(void)didReceiveMemoryWarning;

@end

NS_ASSUME_NONNULL_END
