//
//  UIView+SwipeTransitionLeftRight.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-28.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    UIViewAnimationOptionSwipeLeft      = 0,
    UIViewAnimationOptionSwipeRight     = 1,
};

typedef NSUInteger UIViewAnimationOptionSwipe;


@interface UIView (SwipeTransitionLeftRight)

+ (void)swipeFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptionSwipe)options completion:(void (^)(BOOL finished))completion;

@end
