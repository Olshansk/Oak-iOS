//
//  UIView+SwipeTransitionLeftRight.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-28.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "UIView+SwipeTransitionLeftRight.h"
#import "UIView+ScreenShot.h"

@implementation UIView (SwipeTransitionLeftRight)

+ (void)swipeFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptionSwipe)options completion:(void (^)(BOOL finished))completion
{
    CGRect toViewFinalRect;
    CGRect fromViewFinalRect;
    
    UIImageView *tempToView = [[UIImageView alloc] initWithImage:[UIView getScreenShotOfView:toView]];
    [tempToView setBackgroundColor:[UIColor redColor]];
    [fromView addSubview:tempToView];
    
    toViewFinalRect = fromView.frame;
    if (options == UIViewAnimationOptionSwipeLeft) {
        [tempToView setFrame:CGRectMake(fromView.frame.size.width, 0, tempToView.frame.size.width, tempToView.frame.size.height)];
        fromViewFinalRect = CGRectOffset(fromView.frame, -1.0f * fromView.frame.size.width, 0);
    } else {
        [tempToView setFrame:CGRectMake(-1.0f * fromView.frame.size.width, 0, tempToView.frame.size.width, tempToView.frame.size.height)];
        fromViewFinalRect = CGRectOffset(fromView.frame, fromView.frame.size.width, 0);
    }
    
    [UIView animateWithDuration:duration animations:^{
        [fromView setFrame:fromViewFinalRect];
    } completion:completion];
}

@end
