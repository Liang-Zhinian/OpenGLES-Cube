//
//  ShaderManager.h
//  airhockey
//
//  Created by sprite on 2018/12/5.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Shader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShaderManager : NSObject{
    
}
+(Shader*)getShaderWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
