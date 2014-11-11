//
//  NSStringURLEncoding.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSStringOAURLEncodingAdditions : NSObject

+ (NSString *)encodedURLStringWithString:(NSString*)string;
+ (NSString *)encodedURLParameterStringWithString:(NSString*)string;
+ (NSString *)decodedURLStringWithString:(NSString*)string;
+ (NSString *)removeQuotesWithString:(NSString*)string;

@end
