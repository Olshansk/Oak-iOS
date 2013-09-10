//
//  CourseListObject.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-05.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseListObject : NSObject

@property (nonatomic, strong) NSMutableArray *previousArray;
@property (nonatomic, strong) NSMutableArray *availableArray;

-(void)loadCourseList;
-(void)joinCourse:(NSString*)course withPassword:(NSString*)password;
-(void)addCourse:(NSString*)course withPassword:(NSString*)password;

extern NSString* CouseListObjectNetworkConnectionError;
extern NSString* DidFinishJoiningCourseNotification;
extern NSString* DidFinishAddingCourseNotification;
extern NSString* DidFinishLoadingCoursesNotification;

@end
