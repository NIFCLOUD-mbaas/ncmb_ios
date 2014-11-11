//
//  NSMutableURLRequestParameters.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import "NSMutableURLRequestParameters.h"

static NSString *Boundary = @"-----------------------------------0xCoCoaouTHeBouNDaRy"; 

@implementation NSMutableURLRequestOAParameterAdditions

+ (BOOL)isMultipartWithURLRequest:(NSMutableURLRequest*)request {
	return [[request valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"multipart/form-data"];
}

+ (NSArray *)parametersWithRequest:(NSMutableURLRequest*)request{
    NSString *encodedParameters = nil;
    
	if (![self isMultipartWithURLRequest:request]) {
		if ([[request HTTPMethod] isEqualToString:@"GET"] || [[request HTTPMethod] isEqualToString:@"DELETE"]) {
			encodedParameters = [[request URL] query];
		} else {
			encodedParameters = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSASCIIStringEncoding];
		}
	}
    
    if (encodedParameters == nil || [encodedParameters isEqualToString:@""]) {
        return nil;
    }

    NSArray *encodedParameterPairs = [encodedParameters componentsSeparatedByString:@"&"];
    NSMutableArray *requestParameters = [NSMutableArray arrayWithCapacity:[encodedParameterPairs count]];
    
    for (NSString *encodedPair in encodedParameterPairs) {
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
        NCMBOARequestParameter *parameter = [[NCMBOARequestParameter alloc] initWithName:[[encodedPairElements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                           value:[[encodedPairElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [requestParameters addObject:parameter];
    }
    
    return requestParameters;
}

+ (void)setWithURLRequest:(NSMutableURLRequest*)request parameters:(NSArray *)parameters
{
	NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:[parameters count]];
	for (NCMBOARequestParameter *requestParameter in parameters) {
		[pairs addObject:[requestParameter URLEncodedNameValuePair]];
	}
	
	NSString *encodedParameterPairs = [pairs componentsJoinedByString:@"&"];
    
	if ([[request HTTPMethod] isEqualToString:@"GET"] || [[request HTTPMethod] isEqualToString:@"DELETE"]) {
		[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [NSURLOABaseAdditions URLStringWithoutQueryWithURL:[request URL]], encodedParameterPairs]]];
	} else {
		// POST, PUT
		[self setHTTPBodyWithURLRequest:request string:encodedParameterPairs];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
}

+ (void)setHTTPBodyWithURLRequest:(NSMutableURLRequest*)request string:(NSString *)body {
	NSData *bodyData = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:bodyData];
}

+ (void)attachFileWithURLRequest:(NSMutableURLRequest*)request name:(NSString *)name filename:(NSString*)filename contentType:(NSString *)contentType data:(NSData*)data {

	NSArray *parameters = [self parametersWithRequest:request];
	[request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:Boundary] forHTTPHeaderField:@"Content-type"];
	
	NSMutableData *bodyData = [NSMutableData new];
	for (NCMBOARequestParameter *parameter in parameters) {
		NSString *param = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
						   Boundary, [parameter URLEncodedName], [parameter value]];

		[bodyData appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
	}

	NSString *filePrefix = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n",
		Boundary, name, filename, contentType];
	[bodyData appendData:[filePrefix dataUsingEncoding:NSUTF8StringEncoding]];
	[bodyData appendData:data];
	
	[bodyData appendData:[[[@"\r\n--" stringByAppendingString:Boundary] stringByAppendingString:@"--"] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:bodyData];
}

@end
