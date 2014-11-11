//
//  NCMBOAServiceTicket.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import "NCMBOAServiceTicket.h"


@implementation NCMBOAServiceTicket
@synthesize request, response, data, didSucceed;

- (id)initWithRequest:(NCMBOAMutableURLRequest *)aRequest response:(NSURLResponse *)aResponse data:(NSData *)aData didSucceed:(BOOL)success {
    if ((self = [super init])) {
		request = aRequest;
		response = aResponse;
		data = aData;
		didSucceed = success;
	}
    return self;
}

- (NSString *)body
{
	if (!data) {
		return nil;
	}
	
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
