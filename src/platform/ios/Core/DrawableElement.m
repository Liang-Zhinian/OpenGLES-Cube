//
//  DrawableElement.m
//  airhockey
//
//  Created by sprite on 2018/12/5.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

#import "DrawableElement.h"

@implementation DrawableElement
@synthesize _userScale,_modelViewMatrix,_projectionMatrix;

-(id)init{
    if(self=[super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name: UIApplicationDidReceiveMemoryWarningNotification object:nil];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            isRetina = YES;
        } else {
            isRetina = NO;
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            isIpad = YES;
        }else{
            isIpad = NO;
        }
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
}

-(void)draw{
    
}

-(void)update:(float)timeInterval{
    
}

- (void) handleMemoryWarning:(NSNotification *)notification{
    [self didReceiveMemoryWarning];
}

-(void)didReceiveMemoryWarning{
    
}


@end
