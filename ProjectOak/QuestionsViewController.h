//
//  QuestionsViewController.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardAccessoryTextView.h"

@class CourseObject;

@interface QuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, KeyboardAccessoryTextViewDelegate>

@property (nonatomic, strong) CourseObject *course;

-(void)prepareForUseWithCourse:(CourseObject*)course;
-(void)stopCourseUse;

@end
