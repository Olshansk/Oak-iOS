//
//  KeyboardAccessoryTextView.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-01.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import "HPGrowingTextView.h"
#import <UIKit/UIKit.h>

@protocol KeyboardAccessoryTextViewDelegate

-(void) didSubmitQuestion:(NSString*)question;

@end

@interface KeyboardAccessoryTextView : UIView <HPGrowingTextViewDelegate>

@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) id <KeyboardAccessoryTextViewDelegate> delegate;

@end
