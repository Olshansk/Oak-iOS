//
//  CourseObject.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-30.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "CourseObject.h"
#import "QuestionObject.h"
#import "NSURL+Parameters.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"

#define SERVER_ROOT @"http://oak-server.amandeep.ca/"

#define GENERAL_PASSWORD_PARAMETER @"password"
#define GENERAL_PASSWORD @"EngSci"

#define QUESTION_LIST @"QuestionList"

#define UNDERSTANDING_STATUS @"UnderstandingStatus"

#define ADD_QUESTION @"AddQuestion"
#define ADD_QUESTION_PARAMETER @"question"

#define VOTE @"VoteCourse"
#define VOTE_VOTE_PARAMETER @"vote"

#define COURSE_CODE_PARAMETER @"courseCode"
#define COURSE_PASSWORD_PARAMETER @"coursePassword"
#define UDID_PARAMETER @"deviceId"

#define ERROR_TITLE NSLocalizedString(@"Network Error", @"Network Error")
#define CANCEL_BUTTON_TITLE NSLocalizedString(@"OK",@"OK")
#define SUBMIT_QUESTION_ERROR_MESSAGE NSLocalizedString(@"There was an error while trying submit your question.",@"There was an error while trying submit your question.")


@implementation CourseObject

-(id) init
{
    self = [super init];
    if (self) {
        _topQuestions = [[NSMutableArray alloc] init];
        _otherQuestions = [[NSMutableArray alloc] init];
        _plotData = [[NSMutableArray alloc] init];
        _courseCode = @"NO COURSE CODE";
        _coursePassword = @"NO COURSE PASSWORD";
        _numOfPeopleInRoom = 0;
        _timeLastVoted = @"0";
        _lastVoteValue = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        _topQuestions = [[NSMutableArray alloc] init];
        _otherQuestions = [[NSMutableArray alloc] init];
        _plotData = [[NSMutableArray alloc] init];
        _courseCode = [decoder decodeObjectForKey:@"courseCode"];
        _coursePassword = [decoder decodeObjectForKey:@"coursePassword"];
        _numOfPeopleInRoom = [decoder decodeIntegerForKey:@"numOfPeopleInRoom"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_courseCode forKey:@"courseCode"];
    [encoder encodeObject:_coursePassword forKey:@"coursePassword"];
    [encoder encodeInteger:_numOfPeopleInRoom forKey:@"numOfPeopleInRoom"];
}

-(void)retrieveQuestionList
{
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : _courseCode, COURSE_PASSWORD_PARAMETER : _coursePassword, UDID_PARAMETER : [[UIDevice currentDevice] uniqueDeviceIdentifier]};
    NSURL *url  = [NSURL URLWithRoot:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,QUESTION_LIST] withParameters:params];
    NSURLRequest *request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            NSError *jsonError;
            NSDictionary *userInfo;
            NSDictionary *questions = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            if (questions) {
                if (![[questions allKeys] containsObject:ERROR_KEY]) {
                    userInfo = @{};

                    [_otherQuestions removeAllObjects];
                    [_topQuestions removeAllObjects];
                    
                    for (NSDictionary *question in [questions objectForKey:@"topVotedQuestion"]) {
                        [_topQuestions addObject:[self getQuestionObjectFromDictionary:question]];
                    }
                    for (NSDictionary *question in [questions objectForKey:@"questions"]) {
                        [_otherQuestions addObject:[self getQuestionObjectFromDictionary:question]];
                    }
                    
                    NSLog(@"QUESTION LIST RETRIEVED SUCCESSFULLY");
                } else {
                    userInfo = @{ERROR_KEY: @"DATA Error"};
                    NSLog(@"%@", [questions objectForKey:ERROR_KEY]);
                }
                
                
            }
            else {
                userInfo = @{ERROR_KEY: @"JSON Error"};
                NSLog(@"%@", jsonError);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishUpdatingQuestionListNotification object:self userInfo:userInfo];
        }
    }];
}

-(void)updatePlotData
{
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : _courseCode, COURSE_PASSWORD_PARAMETER : _coursePassword, UDID_PARAMETER : [[UIDevice currentDevice] uniqueDeviceIdentifier]};
    NSURL *url  = [NSURL URLWithRoot:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,UNDERSTANDING_STATUS] withParameters:params];
    NSURLRequest *request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
//            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            
            NSError *jsonError;
            NSDictionary *pData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            NSDictionary *userInfo;
            if (pData) {
                if (![[pData allKeys] containsObject:ERROR_KEY]) {
                    userInfo = @{};
                    [_plotData addObject:@{@"x":[NSString stringWithFormat:@"%d",[_plotData count]], @"y":[pData objectForKey:@"understanding"]}];
                    _timeLastVoted = [pData objectForKey:@"timeLastVoted"];
                    _lastVoteValue = [pData objectForKey:@"deviceVote"] == [NSNull null] ? 50 : [[pData objectForKey:@"deviceVote"] integerValue];
                    
                    NSLog(@"UPDATED PLOT SUCCESSFULLY");
                } else {
                    userInfo = @{ERROR_KEY: @"DATA Error"};
                    NSLog(@"%@", [pData objectForKey:ERROR_KEY]);
                }
            }
            else {
                userInfo = @{ERROR_KEY: @"JSON Error"};
                NSLog(@"%@", jsonError);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishLoadingPlotDataNotification object:self userInfo:userInfo];
        }
    }];
}

-(void)submitQuestion:(NSString*)question
{
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : _courseCode,COURSE_PASSWORD_PARAMETER : _coursePassword, ADD_QUESTION_PARAMETER : question, UDID_PARAMETER : [[UIDevice currentDevice] uniqueDeviceIdentifier]};
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,ADD_QUESTION]];
    NSString *body = [NSURL PostDataWithParameters:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            NSError *jsonError;
            NSDictionary *userInfo;
            NSDictionary *response= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (response) {
                if (![[response allKeys] containsObject:ERROR_KEY]) {
                    userInfo = @{};
                    [self retrieveQuestionList];
                    NSLog(@"QUESTION SENT SUCCESFULLY");
                } else {
                    userInfo = @{ERROR_KEY: @"DATA Error"};
                    NSLog(@"%@", [response objectForKey:ERROR_KEY]);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:SUBMIT_QUESTION_ERROR_MESSAGE delegate:nil cancelButtonTitle:CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [alertView show];
                }
                
                NSLog(@"SUBMITED QUESTION SUCCESSFULLY");
            }
            else {
                userInfo = @{ERROR_KEY: @"JSON Error"};
                NSLog(@"%@", jsonError);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishSubmittingQuestion object:self userInfo:userInfo];
        }
    }];
}

-(void)voteCourse:(NSInteger)vote
{
    NSString* sVote = [NSString stringWithFormat:@"%d", vote];
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : _courseCode, COURSE_PASSWORD_PARAMETER : _coursePassword, UDID_PARAMETER : [[UIDevice currentDevice] uniqueDeviceIdentifier], VOTE_VOTE_PARAMETER : sVote};
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,VOTE]];
    NSString *body = [NSURL PostDataWithParameters:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            NSError *jsonError;
            NSDictionary *userInfo;
            NSDictionary *response= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (response) {
                if (![[response allKeys] containsObject:ERROR_KEY]) {
                    userInfo = @{};
                    NSLog(@"VOTE CAST SUCCESSFULLY");
                } else {
                    userInfo = @{ERROR_KEY: @"DATA Error"};
                    NSLog(@"%@", [response objectForKey:ERROR_KEY]);
                }
            }
            else {
                userInfo = @{ERROR_KEY: @"JSON Error"};
                NSLog(@"%@", jsonError);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishVotingForCourse object:self userInfo:userInfo];
        }
    }];

    
}

-(void)clearPlotData
{
    [_plotData removeAllObjects];
}

-(QuestionObject*)getQuestionObjectFromDictionary:(NSDictionary*)question
{
    QuestionObject *questionObj = [[QuestionObject alloc] init];
    
    [questionObj setDidMarkAsResolved:[[question objectForKey:@"deviceResolveVote"] integerValue] == 1 ? YES : NO];
    [questionObj setDidUpVote:[[question objectForKey:@"deviceVote"] integerValue] == 1 ? YES : NO];
    [questionObj setDidDownVote:[[question objectForKey:@"deviceVote"] integerValue] == -1 ? YES : NO];
    [questionObj setQuestionID:[question objectForKey:@"id"]];
    [questionObj setQuestionText:[question objectForKey:@"question"]];
    long long val =[[question objectForKey:@"timeCreated"] longLongValue];
    [questionObj setTimeCreated:[NSString stringWithFormat:@"%llu",val]];
    [questionObj setNumOfResolvedVotes:[[question objectForKey:@"resolveVotes"] integerValue]];
    [questionObj setNumOfUpVotes:[[question objectForKey:@"vote"] integerValue]];
    [questionObj setCourse:self];
    
    return questionObj;
}

@end

NSString* CourseObjectNetworkConnectionError = @"CourseObjectNetworkConnectionError";
NSString* DidFinishUpdatingQuestionListNotification = @"DidFinishUpdatingQuestionListNotification";
NSString* DidFinishLoadingPlotDataNotification = @"DidFinishLoadingPlotDataNotification";
NSString* DidFinishVotingForCourse = @"DidFinishVotingForCourse";
NSString* DidFinishSubmittingQuestion = @"DidFinishSubmittingQuestion";