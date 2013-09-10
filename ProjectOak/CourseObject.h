//
//  CourseObject.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-30.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseObject : NSObject

@property (nonatomic, strong) NSMutableArray *plotData;

@property (nonatomic, strong) NSMutableArray *topQuestions;
@property (nonatomic, strong) NSMutableArray *otherQuestions;

@property (nonatomic, strong) NSString* courseCode;
@property (nonatomic, strong) NSString* coursePassword;
@property (nonatomic, assign) NSInteger numOfPeopleInRoom;

@property (nonatomic, strong) NSString *timeLastVoted;
@property (nonatomic, assign) NSInteger lastVoteValue;

-(void)retrieveQuestionList;
-(void)updatePlotData;
-(void)submitQuestion:(NSString*)question;
-(void)voteCourse:(NSInteger)vote;
-(void)clearPlotData;

@end

extern NSString* CourseObjectNetworkConnectionError;
extern NSString* DidFinishUpdatingQuestionListNotification;
extern NSString* DidFinishLoadingPlotDataNotification;
extern NSString* DidFinishVotingForCourse;
extern NSString* DidFinishSubmittingQuestion;