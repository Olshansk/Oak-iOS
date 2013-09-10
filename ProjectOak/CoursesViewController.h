//
//  CoursesViewController.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewCourseView.h"

@class CourseListObject;

@interface CoursesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NewCourseViewDelegate>

@property (nonatomic, strong) CourseListObject *courses;

@end
