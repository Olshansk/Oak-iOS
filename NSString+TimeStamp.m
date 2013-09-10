//
//  NSString+TimeStamp.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-01.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import "NSString+TimeStamp.h"

#define NO_TIME_TEXT NSLocalizedString(@"None", @"None")

@implementation NSString (TimeStamp)

+(NSString *)generateTimeStamp:(NSString *)original
{
    if ([original isEqual: [NSNull null]]) {
        return @"-1s";
    }
    
    long long timePassed = [[NSDate date] timeIntervalSince1970];
    
    long long timeOriginal = [original longLongValue] / 1000;
    
    NSTimeInterval timeSinceNow = timeOriginal - timePassed;
    
    if(timeSinceNow < -86400)
    {
        int days = abs(timeSinceNow/86400);
        return [NSString stringWithFormat:@"%dd",days];
    }
    else if(timeSinceNow < -3600)
    {
        int hours = abs(timeSinceNow / 3600);
        return [NSString stringWithFormat:@"%dh",hours];
    }
    else if(timeSinceNow < -60)
    {
        int minutes = abs(timeSinceNow / 60);
        return [NSString stringWithFormat:@"%dm", minutes];
    }
    else
    {
        return @"0m";
//        return [NSString stringWithFormat:@"%ds", (int)floorf(abs(timeSinceNow))];
    }
}


@end
