/*******
 Copyright 2014 NIFTY Corporation All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **********/

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
