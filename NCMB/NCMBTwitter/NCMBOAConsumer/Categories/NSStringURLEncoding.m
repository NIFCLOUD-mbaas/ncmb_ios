//
//  NSStringURLEncoding.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NSStringURLEncoding.h"

@implementation NSStringOAURLEncodingAdditions

+ (NSString *)encodedURLStringWithString:(NSString*)string{
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)string,
                                                                           NULL,                   // characters to leave unescaped (NULL = all escaped sequences are replaced)
                                                                           CFSTR("?=&+"),          // legal URL characters to be escaped (NULL = all legal characters are replaced)
                                                                           kCFStringEncodingUTF8)); // encoding
	return result;
}

+ (NSString *)encodedURLParameterStringWithString:(NSString*)string{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)string,
                                                                           NULL,
                                                                           CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                           kCFStringEncodingUTF8));
	return result;
}

+ (NSString *)decodedURLStringWithString:(NSString*)string{
	NSString *result = (NSString*)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						  (CFStringRef)string,
																						  CFSTR(""),
																						  kCFStringEncodingUTF8));
	
	return result;
	
}

+(NSString *)removeQuotesWithString:(NSString*)string{
	NSUInteger length = [string length];
	NSString *ret = string;
	if ([string characterAtIndex:0] == '"') {
		ret = [ret substringFromIndex:1];
	}
	if ([string characterAtIndex:length - 1] == '"') {
		ret = [ret substringToIndex:length - 2];
	}
	return ret;
}

@end
