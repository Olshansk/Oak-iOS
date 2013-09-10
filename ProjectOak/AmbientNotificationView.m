//
//  AmbientNotificationView.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-17.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "AmbientNotificationView.h"

#import "UIColor+HexToRGB.h"

#define ANIMATION_DURATION 0.4f
#define DELAY_DURATION 2.0f

#define HORIZONTAL_MARGIN 10.0f

#define NOTIFICATION_OPACITY 0.9f

#define FONT_SIZE 16.0f

#define SHADOW_OFFSET CGSizeMake(1.0f, 1.0f)
#define SHADOW_OPACITY 0.8f
#define SHADOW_CORNER_RADIUS 1.0f

#define DARK_YELLOW @"DDCA34"

@implementation AmbientNotificationView
{
    UIActivityIndicatorView *activityIndicator;
    UILabel *label;
}
- (id)init
{
    self = [super init];
    if (self) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        
        [label.layer setShadowOpacity:SHADOW_OPACITY];
        [label.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [label.layer setShadowRadius:SHADOW_CORNER_RADIUS];
        [label.layer setShadowOffset:SHADOW_OFFSET];
        
        [self addSubview:label];
        [self addSubview:activityIndicator];
    }
    return self;
}

-(void)showAmbientNotificationofType:(AmbientNotificationType)type WithMessage:(NSString*)msg inView:(UIView*)view andHideAfterwards:(BOOL)hide
{
    [self.layer setOpacity:0.0f];
    
    if ([self superview] != nil) {
        if (![[self superview] isEqual:view]) {
            [self removeFromSuperview];
            [view addSubview:self];
        }
    } else {
        [view addSubview:self];
    }
    
    if (type == AmbientNotificationNetworkError) {
        [self setFrame:CGRectMake(0, view.frame.size.height - HEADER_VIEW_HEIGHT, view.frame.size.width, HEADER_VIEW_HEIGHT)];
    } else {
        [self setFrame:CGRectMake(0, 0, view.frame.size.width, HEADER_VIEW_HEIGHT)];
    }
    
    if (type == AmbientNotificationSuccess) {
            [self setBackgroundColor:[UIColor greenColor]];
    }
    else if (type == AmbientNotificationProcessing) {
            [self setBackgroundColor:[UIColor colorWithHexString:DARK_YELLOW]];
    }
    else {
            [self setBackgroundColor:[UIColor redColor]];
    }

    [label setText:msg];
    [label setFrame:self.bounds];
    [activityIndicator setFrame:CGRectMake(label.frame.origin.x + label.frame.size.width + HORIZONTAL_MARGIN, HEADER_VIEW_HEIGHT / 2.0f - activityIndicator.frame.size.height / 2.0f, activityIndicator.frame.size.width, activityIndicator.frame.size.height)];
    
    
    if (type == AmbientNotificationProcessing) {
        [activityIndicator startAnimating];
    } else {
        [activityIndicator stopAnimating];
    }
    
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.layer setOpacity:NOTIFICATION_OPACITY];
            
        } completion:^(BOOL finished) {
            if(hide) {
                [self performSelector:@selector(hideAmbientNotification) withObject:nil afterDelay:DELAY_DURATION];
            }
        }];
}

-(void)hideAmbientNotification
{
    [UIView animateWithDuration:ANIMATION_DURATION * 2 animations:^{
        [self.layer setOpacity:0.0f];
        
    } completion:^(BOOL finished) {
        [activityIndicator stopAnimating];
        [_delegate ambientNotificationDidDissapear];
        [self removeFromSuperview];
        
    }];
}


@end
