//
//  CourseListObject.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-05.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import "CourseListObject.h"
#import "CourseObject.h"
#import "QuestionObject.h"

#import "NSURL+Parameters.h"

#define SERVER_ROOT @"http://oak-server.amandeep.ca/"

#define GENERAL_PASSWORD_PARAMETER @"password"
#define GENERAL_PASSWORD @"EngSci"

#define COURSE_LIST  @"CourseList"
#define ADD_COURSE @"AddCourse"
#define JOIN_COURSE @"VerifyCoursePassword"

#define COURSE_CODE_PARAMETER @"courseCode"
#define COURSE_PASSWORD_PARAMETER @"coursePassword"

#define CANCEL_TITLE NSLocalizedString(@"OK",@"OK")

#define ADD_COURSE_TITLE NSLocalizedString(@"New Course", @"New Course")
#define ADDED_COURSE_SUCCESS_TEXT NSLocalizedString(@"\"%@\" was added successfully.", @"\"%@\" was added successfully.")
#define ADDED_COURSE_ERROR_TEXT NSLocalizedString(@"There was an error while trying to add %@.", @"There was an error while trying to add %@.")

#define JOIN_COURSE_TITLE NSLocalizedString(@"Join Course", @"Join Course")
#define JOIN_COURSE_SUCCESS_TEXT NSLocalizedString(@"\"%@\" was joined successfully.", @"\"%@\" was joined successfully.")
#define JOIN_COURSE_ERROR_TEXT NSLocalizedString(@"There was an error while trying to join %@.", @"There was an error while trying to join %@.")

#define PREVIOUS_ARRAY_KEY @"keyForPreviousArray"
#define AVAILABLE_ARRAY_KEY @"keyForAvailableArray"


@implementation CourseListObject

-(id) init
{   
    self = [super init];
    if (self) {
        [self retrieveCourseList];
    }
    return self;
}

-(void)retrieveCourseList
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *previousArrayEncoded = [prefs objectForKey:PREVIOUS_ARRAY_KEY];
    if (previousArrayEncoded != nil) {
        NSArray *oldPreviousArray = [NSKeyedUnarchiver unarchiveObjectWithData:previousArrayEncoded];
        if (oldPreviousArray != nil)
            _previousArray = [[NSMutableArray alloc] initWithArray:oldPreviousArray];
        else
            _previousArray = [[NSMutableArray alloc] init];
    } else {
        _previousArray = [[NSMutableArray alloc] init];
    }

    NSData *availableArrayEncoded = [prefs objectForKey:AVAILABLE_ARRAY_KEY];
    if (availableArrayEncoded != nil)
    {
        NSArray *oldAvailableArray = [NSKeyedUnarchiver unarchiveObjectWithData:availableArrayEncoded];
        if (oldAvailableArray != nil)
            _availableArray = [[NSMutableArray alloc] initWithArray:oldAvailableArray];
        else
            _availableArray = [[NSMutableArray alloc] init];
    } else {
        _availableArray = [[NSMutableArray alloc] init];
    }
}

-(void)saveCourseList
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:_previousArray] forKey:PREVIOUS_ARRAY_KEY];
    [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:_availableArray] forKey:AVAILABLE_ARRAY_KEY];
    
    [prefs synchronize];
}


-(NSUInteger)indexOfCourseObjectWithCourseCode:(NSString*)str inArray:(NSArray*)arr
{
    NSUInteger index = [arr indexOfObjectPassingTest:^(id element, NSUInteger idx, BOOL * stop){
        CourseObject *obj = (CourseObject*)element;
        if ([obj.courseCode isEqualToString:str]) {
            return YES;
        } else {
            return NO;
        }
    }];
    return index;
    
}

-(void)loadCourseList
{
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD};
    NSURL *url  = [NSURL URLWithRoot:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,COURSE_LIST] withParameters:params];
    NSURLRequest *request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            NSError *jsonError;
            NSDictionary * courses= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            if (courses) {
                if (![[courses allKeys] containsObject:ERROR_KEY]) {
                    
                    NSArray *prevCopy = [[NSArray alloc] initWithArray:_previousArray];
                    NSArray *avaiCopy = [[NSArray alloc] initWithArray:_availableArray];
                    
                    [_previousArray removeAllObjects];
                    [_availableArray removeAllObjects];
                    
                    for (NSString *str in [courses objectForKey:@"courses"]) {
                        
                        NSUInteger found1 = [self indexOfCourseObjectWithCourseCode:str inArray:prevCopy];
                        NSUInteger found2 = [self indexOfCourseObjectWithCourseCode:str inArray:avaiCopy];
                        
                        if (found1 == NSNotFound && found2 == NSNotFound) {
                            CourseObject *obj = [[CourseObject alloc] init];
                            [obj setCourseCode:str];
                            [obj setNumOfPeopleInRoom:8];
                            [_availableArray addObject:obj];
                        } else if (found1 != NSNotFound && found2 == NSNotFound) {
                            [_previousArray addObject:[prevCopy objectAtIndex:found1]];
                        } else if (found1 == NSNotFound && found2 != NSNotFound) {
                            [_availableArray addObject:[avaiCopy objectAtIndex:found2]];
                        } else {
                            NSLog(@"Something is wrong...");
                        }
                    }
                    NSLog(@"LOADED COURSE LIST SUCCESSFULLY");
                    
                } else {
                    NSLog(@"%@", [courses objectForKey:ERROR_KEY]);
                }
            }
            else {
                NSLog(@"%@", jsonError);
            }
            [self saveCourseList];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishLoadingCoursesNotification object:self];
        }
        
    }];
}

-(void)joinCourse:(NSString*)course withPassword:(NSString*)password
{
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : course, COURSE_PASSWORD_PARAMETER : password};
    NSURL *url = [NSURL URLWithRoot:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,JOIN_COURSE] withParameters:params];
    NSURLRequest *request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_INTERVAL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            NSDictionary *userInfo;
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            UIAlertView *alert;
            if ([result isEqualToString: @"1"]) {
                userInfo = @{};
//                alert = [[UIAlertView alloc] initWithTitle:JOIN_COURSE_TITLE message:[NSString stringWithFormat:JOIN_COURSE_SUCCESS_TEXT,course] delegate:nil cancelButtonTitle:CANCEL_TITLE otherButtonTitles:nil];
                
                NSUInteger index = [self indexOfCourseObjectWithCourseCode:course inArray:_availableArray];
                
                CourseObject *obj = [_availableArray objectAtIndex:index];
                [obj setCourseCode:course];
                [obj setCoursePassword:password];
                
                [_availableArray removeObjectAtIndex:index];
                [_previousArray addObject:obj];
                
                [self saveCourseList];
                
                NSLog(@"JOINED COURSE SUCCESSFULLY");
    
            } else {
                 userInfo = @{ERROR_KEY: @"DATA Error"};
//                alert = [[UIAlertView alloc] initWithTitle:JOIN_COURSE_TITLE message:[NSString stringWithFormat:JOIN_COURSE_ERROR_TEXT,course] delegate:nil cancelButtonTitle:CANCEL_TITLE otherButtonTitles:nil];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishJoiningCourseNotification object:self userInfo:userInfo];
//            [alert show];
        }
    }];
}

-(void)addCourse:(NSString*)course withPassword:(NSString*)password
{
    NSDictionary *params = @{GENERAL_PASSWORD_PARAMETER : GENERAL_PASSWORD, COURSE_CODE_PARAMETER : course, COURSE_PASSWORD_PARAMETER : password};
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_ROOT,ADD_COURSE]];
    NSString *body = [NSURL PostDataWithParameters:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if (!response) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:CourseObjectNetworkConnectionError object:self];
        } else {
            NSDictionary *userInfo;
            NSError *jsonError;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            if (result) {
//                UIAlertView *alert;
                if (![[result allKeys] containsObject:ERROR_KEY]) {
                    userInfo = @{};
//                    alert = [[UIAlertView alloc] initWithTitle:ADD_COURSE_TITLE message:[NSString stringWithFormat:ADDED_COURSE_SUCCESS_TEXT,course] delegate:nil cancelButtonTitle:CANCEL_TITLE otherButtonTitles:nil];
                    
                    CourseObject *obj = [[CourseObject alloc] init];
                    [obj setCourseCode:course];
                    [obj setCoursePassword:password];
                    [_previousArray addObject:obj];
                    
                    [self saveCourseList];
                    
                } else {
                    NSLog(@"%@", [result objectForKey:ERROR_KEY]);
                    userInfo = @{ERROR_KEY: @"DATA Error"};
//                    alert = [[UIAlertView alloc] initWithTitle:ADD_COURSE_TITLE message:[NSString stringWithFormat:ADDED_COURSE_ERROR_TEXT,course] delegate:nil cancelButtonTitle:CANCEL_TITLE otherButtonTitles:nil];
                }
                
                NSLog(@"ADDED COURSE SUCCESSFULLY");
                
//                [alert show];
            }
            else {
                NSLog(@"%@", jsonError);
                userInfo = @{ERROR_KEY: @"JSON Error"};
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishAddingCourseNotification object:self userInfo:userInfo];
        }
    }];
}

@end

NSString* CouseListObjectNetworkConnectionError = @"CouseListObjectNetworkConnectionError";
NSString* DidFinishJoiningCourseNotification = @"DidFinishJoiningCourseNotification";
NSString* DidFinishAddingCourseNotification = @"DidFinishAddingCourseNotification";
NSString* DidFinishLoadingCoursesNotification = @"DidFinishLoadingCoursesNotification";
