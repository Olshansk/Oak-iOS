//
//  UINavigationController+CustomAnimations.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-05.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (CustomAnimations)

// Look at CATransition for animation type and subtype
- (void)pushViewController:(UIViewController *)viewController withAnimationType:(NSString*)type andAnimationSubtype:(NSString*)subtype andDuration:(CFTimeInterval)duration;
- (void)popViewControllerWithAnimationType:(NSString*)type andAnimationSubtype:(NSString*)subtype andDuration:(CFTimeInterval)duration;

@end
