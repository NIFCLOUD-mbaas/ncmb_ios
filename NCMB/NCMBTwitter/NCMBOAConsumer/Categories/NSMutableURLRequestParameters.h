//
//  NSMutableURLRequestParameters.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCMBOARequestParameter.h"
#import "NSURLBase.h"


@interface NSMutableURLRequestOAParameterAdditions : NSObject

+ (void)setHTTPBodyWithURLRequest:(NSMutableURLRequest*)request string:(NSString *)body;
+ (void)attachFileWithURLRequest:(NSMutableURLRequest*)request name:(NSString *)name filename:(NSString*)filename contentType:(NSString *)contentType data:(NSData*)data;
+ (void)setWithURLRequest:(NSMutableURLRequest*)request parameters:(NSArray *)parameters;
+ (NSArray *)parametersWithRequest:(NSMutableURLRequest*)request;

@end
