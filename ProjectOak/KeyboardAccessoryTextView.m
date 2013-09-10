//
//  KeyboardAccessoryTextView.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-01.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "KeyboardAccessoryTextView.h"
#import "UIColor+HexToRGB.h"

//#define HORIZONTAL_MARGIN 2.0f
//#define VERTICAL_MARGIN 3.0f
//#define TEXT_VIEW_CORNER_RADIUS 4.0f

//#define BUTTON_WIDTH 40.0f

#define SEND_TEXT NSLocalizedString(@"Send", @"Send")
#define BUTTON_WIDTH 69.0f

#define FONT_SIZE 15.0f
#define BUTTON_FONT_SIZE 18.0f

@implementation KeyboardAccessoryTextView
{
    UIView *toolBarView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        toolBarView = [[UIView alloc] initWithFrame:frame];
        
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
        _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 6;
        _textView.returnKeyType = UIReturnKeyGo; //just as an example
        _textView.font = [UIFont systemFontOfSize:FONT_SIZE];
        _textView.delegate = self;
        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        _textView.backgroundColor = [UIColor whiteColor];
        
        UIImage *entryBackground = [[UIImage imageNamed:@"MessageEntryInputField.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(5, 0, 248, frame.size.height);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *background = [[UIImage imageNamed:@"MessageEntryBackground.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(frame.size.width - BUTTON_WIDTH, 8, BUTTON_WIDTH, 27);
        doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [doneBtn setTitle:SEND_TEXT forState:UIControlStateNormal];
        
        [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
        
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(sendQuestion:) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        
        toolBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        [toolBarView addSubview:imageView];
        [toolBarView addSubview:_textView];
        [toolBarView addSubview:entryImageView];
        [toolBarView addSubview:doneBtn];
        
        [self addSubview:toolBarView];
    }
    return self;
}

#pragma mark  HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = toolBarView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	toolBarView.frame = r;
}

#pragma mark Button and Text Field Actions

-(void)sendQuestion:(id)sender
{
    NSString *str = [_textView text];
    
    [_textView setText:@""];
    [_textView resignFirstResponder];
    
    [_delegate didSubmitQuestion:str];
    
}

@end
