//
//  NSURLBase.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NSURLBase.h"

@implementation NSURLOABaseAdditions

+ (NSString *)URLStringWithoutQueryWithURL:(NSURL*)url {
    NSArray *parts = [[url absoluteString] componentsSeparatedByString:@"?"];
    return [parts objectAtIndex:0];
}

@end
