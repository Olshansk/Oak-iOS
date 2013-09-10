//
//  UIView+ScreenShot.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-28.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIView+ScreenShot.h"

@implementation UIView (ScreenShot)

+(UIImage*)getScreenShotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(320,480));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  screenShot;
}

@end
