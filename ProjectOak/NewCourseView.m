//
//  NewCourseView.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-04.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "NewCourseView.h"

#import "UIColor+HexToRGB.h"

#define PASSWORD_TEXT NSLocalizedString(@"Password", @"Password")
#define COURSE_CODE_TEXT NSLocalizedString(@"Course Code", @"Course Code")
#define ADD_COURSE_BUTTON_TEXT NSLocalizedString(@"Add", @"Add")
#define JOIN_BUTTON_TEXT NSLocalizedString(@"Join", @"Join")
#define CANCEL_BUTTON_TEXT NSLocalizedString(@"Cancel", @"Cancel")

#define COURSE_CODE_LABEL_Y_POSITION 50.0f

#define HORIZONTAL_MARGINS 10.0f
#define VERTICAL_MARGINS 10.0f
#define VERTICAL_SIZE 30.0f

#define BUTTON_HEIGHT 30.0f

#define FONT_SIZE 15.0f

#define CORNER_RADIUS 8.0f
#define BORDER_WIDTH 3.0f

#define BACKGROUND_ALPHA 0.5f

#define KEYBOARD_HEIGHT 216

#define BUTTON_SHADOW_OFFSET CGSizeMake(0.0f, 0.0f)
#define BUTTON_SHADOW_OPACITY 0.8f
#define BUTTON_SHADOW_CORNER_RADIUS 8.0f
#define BUTTON_SHADOW_BORDER_WDITH 1.0f


@implementation NewCourseView
{
    BOOL isCreatingNewCourse;
    
    UIButton *addCourseButton;
    UIButton *cancelButton;
    
    UITextField *passwordField;
    UITextField *nameField;
    UILabel *nameLabel;
    
    UIView *backgroundView;
}

-(void)setFrame:(CGRect)frame
{
    CGFloat height = VERTICAL_MARGINS * 4 + VERTICAL_SIZE * 2 + BUTTON_HEIGHT;
    
    [super setFrame: CGRectMake(HORIZONTAL_MARGINS, (_superView.frame.size.height - KEYBOARD_HEIGHT) / 2.0f - height / 2.0f, _superView.frame.size.width - HORIZONTAL_MARGINS * 2, height)];
    
    [backgroundView setFrame:frame];
    [nameField setFrame:CGRectMake(HORIZONTAL_MARGINS, VERTICAL_MARGINS, self.frame.size.width - HORIZONTAL_MARGINS * 2, VERTICAL_SIZE)];
    [nameLabel setFrame:nameField.frame];
    [passwordField setFrame:CGRectMake(HORIZONTAL_MARGINS, nameField.frame.origin.y + nameField.frame.size.height + VERTICAL_MARGINS, self.frame.size.width - HORIZONTAL_MARGINS * 2, VERTICAL_SIZE)];
    [addCourseButton setFrame:CGRectMake(HORIZONTAL_MARGINS, passwordField.frame.origin.y + passwordField.frame.size.height + VERTICAL_MARGINS, self.frame.size.width / 2.0f - HORIZONTAL_MARGINS * 2, BUTTON_HEIGHT)];
    [cancelButton setFrame:CGRectMake(addCourseButton.frame.origin.x + addCourseButton.frame.size.width + HORIZONTAL_MARGINS * 2, passwordField.frame.origin.y + passwordField.frame.size.height + VERTICAL_MARGINS, self.frame.size.width / 2.0f - HORIZONTAL_MARGINS * 2, BUTTON_HEIGHT)];
}

- (id)initWithSuperView:(UIView*)superView;
{
    _superView = superView;
    
    CGFloat height = VERTICAL_MARGINS * 4 + VERTICAL_SIZE * 2 + BUTTON_HEIGHT;
    self = [super initWithFrame:CGRectMake(HORIZONTAL_MARGINS, _superView.frame.size.height - KEYBOARD_HEIGHT - height - VERTICAL_MARGINS, _superView.frame.size.width - HORIZONTAL_MARGINS * 2, height)];
    
    if (self) {
        
        isCreatingNewCourse = YES;
        
        [self setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        [self.layer setCornerRadius:CORNER_RADIUS];
        [self.layer setBorderWidth:BORDER_WIDTH];
        [self.layer setBorderColor:[[UIColor colorWithHexString:GRAY_TEXT_COLOR] CGColor]];
        [self setAlpha:0.0f];
        
        backgroundView = [[UIView alloc] initWithFrame:superView.frame];
        [backgroundView setBackgroundColor:[UIColor blackColor]];
        [backgroundView setAlpha:0.0];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(HORIZONTAL_MARGINS, VERTICAL_MARGINS, self.frame.size.width - HORIZONTAL_MARGINS * 2, VERTICAL_SIZE)];
        [nameField setBackgroundColor:[UIColor whiteColor]];
        [nameField setBorderStyle:UITextBorderStyleRoundedRect];
        [nameField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [nameField setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [nameField setSecureTextEntry:NO];
        [nameField setPlaceholder:COURSE_CODE_TEXT];
        
        nameLabel = [[UILabel alloc] initWithFrame:nameField.frame];
        [nameLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        [nameLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
        [nameLabel setUserInteractionEnabled:NO];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        
        passwordField = [[UITextField alloc] initWithFrame:CGRectMake(HORIZONTAL_MARGINS, nameField.frame.origin.y + nameField.frame.size.height + VERTICAL_MARGINS, self.frame.size.width - HORIZONTAL_MARGINS * 2, VERTICAL_SIZE)];
        [passwordField setBackgroundColor:[UIColor whiteColor]];
        [passwordField setBorderStyle:UITextBorderStyleRoundedRect];
        [passwordField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [passwordField setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [passwordField setSecureTextEntry:YES];
        [passwordField setPlaceholder:PASSWORD_TEXT];
        
        addCourseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addCourseButton setFrame:CGRectMake(HORIZONTAL_MARGINS, passwordField.frame.origin.y + passwordField.frame.size.height + VERTICAL_MARGINS, self.frame.size.width / 2.0f - HORIZONTAL_MARGINS * 2, BUTTON_HEIGHT)];
        [addCourseButton addTarget:self action:@selector(addNewCourse:) forControlEvents:UIControlEventTouchUpInside];
        [addCourseButton setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        [addCourseButton setTitle:ADD_COURSE_BUTTON_TEXT forState:UIControlStateNormal];
        [addCourseButton setTitleColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR] forState:UIControlStateNormal];
        [addCourseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [addCourseButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [addCourseButton.layer setShadowOffset:BUTTON_SHADOW_OFFSET];
        [addCourseButton.layer setShadowOpacity:BUTTON_SHADOW_OPACITY];
        [addCourseButton.layer setCornerRadius:BUTTON_SHADOW_CORNER_RADIUS];
        [addCourseButton.layer setBorderWidth:BUTTON_SHADOW_BORDER_WDITH];
        [addCourseButton.layer setBorderColor:[[UIColor colorWithHexString:GRAY_TEXT_COLOR] CGColor]];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(addCourseButton.frame.origin.x + addCourseButton.frame.size.width + HORIZONTAL_MARGINS * 2, passwordField.frame.origin.y + passwordField.frame.size.height + VERTICAL_MARGINS, self.frame.size.width / 2.0f - HORIZONTAL_MARGINS * 2, BUTTON_HEIGHT)];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        [cancelButton setTitle:CANCEL_BUTTON_TEXT forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [cancelButton.layer setShadowOffset:BUTTON_SHADOW_OFFSET];
        [cancelButton.layer setShadowOpacity:BUTTON_SHADOW_OPACITY];
        [cancelButton.layer setCornerRadius:BUTTON_SHADOW_CORNER_RADIUS];
        [cancelButton.layer setBorderWidth:BUTTON_SHADOW_BORDER_WDITH];
        [cancelButton.layer setBorderColor:[[UIColor colorWithHexString:GRAY_TEXT_COLOR] CGColor]];
        
        [self addSubview:addCourseButton];
        [self addSubview:cancelButton];
        [self addSubview:nameField];
        [self addSubview:passwordField];

    }
    return self;
}

-(void)resignFirstResponders
{
    if ([nameField isFirstResponder]) {
        [nameField resignFirstResponder];
    }
    else if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
}

#pragma mark Showing and Hiding

-(void)showNewCourseView
{
    isCreatingNewCourse = YES;
    [addCourseButton setTitle:ADD_COURSE_BUTTON_TEXT forState:UIControlStateNormal];
    
    [_superView addSubview:backgroundView];
    [_superView addSubview:self];
    
    [UIView animateWithDuration:0.4f animations:^{
        [backgroundView setAlpha:BACKGROUND_ALPHA];
        [self setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        [nameField becomeFirstResponder];
    }];
}

-(void)showNewCourseViewForCourse:(NSString*)course
{
    isCreatingNewCourse = NO;
    [addCourseButton setTitle:JOIN_BUTTON_TEXT forState:UIControlStateNormal];
    
    [nameField removeFromSuperview];
    [self addSubview:nameLabel];
    [nameLabel setText:course];
    
    [_superView addSubview:backgroundView];
    [_superView addSubview:self];
    
    [UIView animateWithDuration:0.4f animations:^{
        [backgroundView setAlpha:BACKGROUND_ALPHA];
        [self setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        [passwordField becomeFirstResponder];
    }];
}

-(void)hideView
{
    [self resignFirstResponders];
    
    [UIView animateWithDuration:0.4f animations:^{
        [backgroundView setAlpha:0.0f];
        [self setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        if (!isCreatingNewCourse) {
            [nameLabel removeFromSuperview];
            [self addSubview:nameField];
        }
        
        [nameField setText:@""];
        [passwordField setText:@""];
        
        [backgroundView removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}

#pragma mark Responders

-(void)cancel:(id)sender
{
    [self hideView];
}

-(void)addNewCourse:(id)sender
{
    if (!isCreatingNewCourse) {
        [_delegate didJoinCourse:[nameLabel text] withPassword:[passwordField text]];
    } else {
        [_delegate didAddCourse:[nameField text] withPassword:[passwordField text]];
    }
    
    [self hideView];
}

@end