//
//  QuestionObject.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CourseObject;

@interface QuestionObject : NSObject

@property (nonatomic, assign) NSInteger numOfUpVotes;
@property (nonatomic, strong) NSString *questionText;
@property (nonatomic, assign) NSInteger numOfPoints;
@property (nonatomic, strong) NSString *timeCreated;
@property (nonatomic, assign) BOOL didUpVote;
@property (nonatomic, assign) BOOL didDownVote;
@property (nonatomic, assign) BOOL didMarkAsResolved;
@property (nonatomic, assign) BOOL isResolved;
@property (nonatomic, strong) NSString *questionID;
@property (nonatomic, assign) NSInteger numOfResolvedVotes;
@property (nonatomic, strong) CourseObject *course;

-(void)upOrDownVoteRequest;
-(void)resolveQuestionRequest;

extern NSString* QuestionObjectNetworkConnectionError;
extern NSString* DidFinishSendingQuestionResolveNotification;
extern NSString* DidFinishSendingQuestionVoteNotification;

@end
