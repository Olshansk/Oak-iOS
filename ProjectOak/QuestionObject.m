//
//  QuestionObject.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "QuestionObject.h"
#import "CourseObject.h"
#import "NSURL+Parameters.h"
#import "UIDevice+IdentifierAddition.h"

#define SERVER_ROOT @"http://oak-server.amandeep.ca/"

#define GENERAL_PASSWORD_PARAMETER @"password"
#define GENERAL_PASSWORD @"EngSci"

#define UP_DOWN_VOTE @"VoteQuestion"
#define UP_DOWN_VOTE_VOTE_PARMETER @"vote"
#define UP_DOWN_VOTE_QUESTION_ID_PARMETER @"questionId"

#define RESOLVE @"ResolveQuestion"
#define RESOLVE_PARMETER @"resolveVote"
#define RESOLVE_QUESTION_ID_PARMETER @"questionId"

#define COURSE_CODE_PARAMETER @"courseCode"
#define COURSE_PASSWORD_PARAMETER @"coursePassword"
#define UDID_PARAMETER @"deviceId"

#define ERROR_TITLE NSLocalizedString(@"Network Error", @"Network Error")
#define CANCEL_BUTTON_TITLE NSLocalizedString(@"OK",@"OK")
#define VOTE_ERROR_MESSAGE NSLocalizedString(@"There was an error while trying to up or down vote this question.",@"There was an error while trying to up or down vote this question.")
#define RESOLVE_ERROR_MESSAGE NSLocalizedString(@"There was an error while trying to mark this question as resolved.",@"There was an error while trying to mark this question as resolved.")


@implementation QuestionObject

-(id) init
{
    self = [super init];
    if (self) {
        _didUpVote = NO;
        _didDownVote = NO;
        _didMarkAsResolved = NO;
        _numOfUpVotes = 0;
        _numOfPoints = 0;
        _timeCreated = 0;
        _numOfResolvedVotes = 0;
        _questionText = @"NO QUESTION LOADED";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        _didUpVote = [decoder decodeBoolForKey:@"upVote"];
        _didDownVote = [decoder decodeBoolForKey:@"downVote"];
        _didMarkAsResolved = [decoder decodeBoolForKey:@"markAsResolved"];
        _numOfUpVotes = [decoder decodeIntegerForKey:@"numOfUpVotes"];
        _numOfPoints = [decoder decodeIntegerForKey:@"numOfPoints"];
        _timeCreated = [decoder decodeObjectForKey:@"timeCreated"];
        _questionID = [decoder decodeObjectForKey:@"questionID"];
        _numOfResolvedVotes = [decoder decodeIntegerForKey:@"numOfResolvedVotes"];
        _questionText = [decoder decodeObjectForKey:@"questionText"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:_didUpVote forKey:@"upVote"];
    [encoder encodeBool:_didDownVote forKey:@"downVote"];
    [encoder encodeBool:_didMarkAsResolved forKey:@"markAsResolved"];
    [encoder encodeInteger:_numOfUpVotes forKey:@"numOfUpVotes"];
    [encoder encodeInteger:_numOfPoints forKey:@"numOfPoints"];
    [encoder encodeObject:_timeCreated forKey:@"timeCreated"];
    [encoder encodeObject:_questionID forKey:@"questionID"];
    [encoder encodeInteger:_numOfResolvedVotes forKey:@"numOfResolvedVotes"];
    [encoder encodeObject:_questionText forKey:@"questionText"];
    
}

-(void)upOrDownVoteRequest
{
    NSInteger vote = _didUpVote ? 1 : (_didDownVote ? - 1: 0);
    NSString* upDownVote = [NSString stringWithFormat:@"%d", vote];
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : [_course courseCode], COURSE_PASSWORD_PARAMETER : [_course coursePassword], UDID_PARAMETER : [[UIDevice currentDevice] uniqueDeviceIdentifier], UP_DOWN_VOTE_VOTE_PARMETER : upDownVote, UP_DOWN_VOTE_QUESTION_ID_PARMETER : _questionID};
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,UP_DOWN_VOTE]];
    NSString *body = [NSURL PostDataWithParameters:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:QuestionObjectNetworkConnectionError object:self];
        }  else {
            NSDictionary *userInfo;
            NSError *jsonError;
            NSDictionary * result= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            if (result) {
                if (![[result allKeys] containsObject:ERROR_KEY]) {
                    NSLog(@"VOTE SENT SUCCESSFULLY");
                } else {
                    userInfo = @{ERROR_KEY: @"DATA error"};
                    NSLog(@"%@", [result objectForKey:ERROR_KEY]);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:VOTE_ERROR_MESSAGE delegate:nil cancelButtonTitle:CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [alertView show];
                }
            }
            else {
                userInfo = @{ERROR_KEY: @"JSON error"};
                NSLog(@"%@", jsonError);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishSendingQuestionVoteNotification object:self userInfo:userInfo];
        }
    }];
}

-(void)resolveQuestionRequest
{
    NSInteger resolve = _didMarkAsResolved ? 1 : 0;
    NSString* resolveVote = [NSString stringWithFormat:@"%d", resolve];
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : [_course courseCode], COURSE_PASSWORD_PARAMETER : [_course coursePassword], UDID_PARAMETER : [[UIDevice currentDevice] uniqueDeviceIdentifier], RESOLVE_PARMETER : resolveVote, RESOLVE_QUESTION_ID_PARMETER : _questionID};
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,RESOLVE]];
    NSString *body = [NSURL PostDataWithParameters:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:QuestionObjectNetworkConnectionError object:self];
            
        }   else {
            NSError *jsonError;
            NSDictionary *userInfo;
            NSDictionary * result= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            if (result) {
                if (![[result allKeys] containsObject:ERROR_KEY]) {
                    NSLog(@"QUESTION RESOLVE SENT SUCCESSFULLY");
                } else {
                    userInfo = @{ERROR_KEY: @"DATA error"};
                    NSLog(@"%@", [result objectForKey:ERROR_KEY]);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE message:RESOLVE_ERROR_MESSAGE delegate:nil cancelButtonTitle:CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                    [alertView show];
                }
            }
            else {
                userInfo = @{ERROR_KEY: @"JSON error"};
                NSLog(@"%@", jsonError);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishSendingQuestionResolveNotification object:self];
        }
    }];
}

@end

NSString* QuestionObjectNetworkConnectionError = @"QuestionObjectNetworkConnectionError";
NSString* DidFinishSendingQuestionResolveNotification = @"DidFinishSendingQuestionResolveNotification";
NSString* DidFinishSendingQuestionVoteNotification = @"DidFinishSendingQuestionVoteNotification";

