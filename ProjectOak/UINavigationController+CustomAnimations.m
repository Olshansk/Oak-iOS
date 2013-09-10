//
//  UINavigationController+CustomAnimations.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-05.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UINavigationController+CustomAnimations.h"

@implementation UINavigationController (CustomAnimations)

- (void)pushViewController:(UIViewController *)viewController withAnimationType:(NSString*)type andAnimationSubtype:(NSString*)subtype andDuration:(CFTimeInterval)duration
{
    CATransition* transition = [CATransition animation];
    [transition setDuration:duration];
    [transition setType:type];
    [transition setSubtype:subtype];
    [[[self view] layer] addAnimation:transition forKey:kCATransition];
    
    [self pushViewController:viewController animated:NO];
}

- (void)popViewControllerWithAnimationType:(NSString*)type andAnimationSubtype:(NSString*)subtype andDuration:(CFTimeInterval)duration
{
    CATransition* transition = [CATransition animation];
    [transition setDuration:duration];
    [transition setType:type];
    [transition setSubtype:subtype];
    [[[self view] layer] addAnimation:transition forKey:kCATransition];
    
    [self popViewControllerAnimated:NO];
}


@end


//    [transition setType:kCATransitionMoveIn];
//    [transition setSubtype: kCATransitionFromTop];0.4f