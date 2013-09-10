//
//  TriangleView.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-30.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "TriangleView.h"
#import "UIColor+HexToRGB.h"

#define SELECTED_COLOR @"108DF8"
#define SELECTED_PRESSED_COLOR @"0D60CC"
#define NOT_SELECTED_PRESSED_COLOR @"2B2B2C"

@implementation TriangleView

- (id)initWithFrame:(CGRect)frame withTriangleDirection:(UIViewTriangleDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _direction = direction;
        _state = UIViewTriangleStateNotSelected;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    if (_direction == UIViewTrianglePointUp) {
        CGContextMoveToPoint   (ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));  // mid bottom
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // top right
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // top left
    } else {
        CGContextMoveToPoint   (ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));  // mid top
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // bottom right
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // bottom left
    }
    
    CGContextClosePath(ctx);
    
    if (_state == UIViewTriangleStateNotSelected)
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithHexString:GRAY_TEXT_COLOR] CGColor]);
    else if(_state == UIViewTriangleStateNotSelectedPressed)
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithHexString:NOT_SELECTED_PRESSED_COLOR] CGColor]);
    else if(_state == UIViewTriangleStateSelected)
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithHexString:SELECTED_COLOR] CGColor]);
    else if(_state == UIViewTriangleStateSelectedPressed)
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithHexString:SELECTED_PRESSED_COLOR] CGColor]);

    
    CGContextFillPath(ctx);
}

@end
