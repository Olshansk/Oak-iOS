//
//  NewCourseView.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-04.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewCourseViewDelegate
    -(void) didJoinCourse:(NSString*)course withPassword:(NSString*)password;
    -(void) didAddCourse:(NSString*)course withPassword:(NSString*)password;
@end

@interface NewCourseView : UIView

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) id <NewCourseViewDelegate> delegate;

- (id)initWithSuperView:(UIView*)superView;

-(void)showNewCourseView;
-(void)showNewCourseViewForCourse:(NSString*)course;

@end
