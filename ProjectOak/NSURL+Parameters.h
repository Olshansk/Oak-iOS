//
//  NSURL+Parameters.h
//  ProjectOak
//
//  Created by Daniel Olshansky on 2013-01-05.
//  Copyright (c) 2013 Daniel Olshansky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Parameters)

+ (id)URLWithRoot:(NSString *)root withParameters:(NSDictionary*)params;
+ (NSString*)PostDataWithParameters:(NSDictionary*)params;

@end
