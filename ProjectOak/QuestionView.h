//
//  QuestionView.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuestionObject;

@interface QuestionView : UIView

@property (nonatomic, strong) QuestionObject *questionObject;

- (id)initWithFrame:(CGRect)frame andQuestionObject:(QuestionObject*)questionObject;

@end
