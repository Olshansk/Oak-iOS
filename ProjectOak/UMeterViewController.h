//
//  UMeterViewController.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourseObject;

@interface UMeterViewController : UIViewController

@property (nonatomic, strong) CourseObject *course;

-(void)prepareForUseWithCourse:(CourseObject*)course;
-(void)stopCourseUse;

@end
