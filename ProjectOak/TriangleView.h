//
//  TriangleView.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-30.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    UIViewTrianglePointUp       = 0,
    UIViewTrianglePointDown     = 1,
};

typedef NSUInteger UIViewTriangleDirection;

enum {
    UIViewTriangleStateNotSelected          = 0,
    UIViewTriangleStateNotSelectedPressed   = 1,
    UIViewTriangleStateSelected             = 2,
    UIViewTriangleStateSelectedPressed      = 3,
};

typedef NSUInteger UIViewTriangleState;


@interface TriangleView : UIView

@property (nonatomic, assign) NSUInteger direction;
@property (nonatomic, assign) UIViewTriangleState state;

- (id)initWithFrame:(CGRect)frame withTriangleDirection:(UIViewTriangleDirection)direction;

@end
