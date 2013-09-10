//
//  AppDelegate.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-24.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoursesViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CoursesViewController *courses;

@end
