//
//  NCMBOAServiceTicket.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NCMBOAMutableURLRequest.h"


@interface NCMBOAServiceTicket : NSObject {
@private
    NCMBOAMutableURLRequest *request;
    NSURLResponse *response;
	NSData *data;
    BOOL didSucceed;
}
@property(readonly) NCMBOAMutableURLRequest *request;
@property(readonly) NSURLResponse *response;
@property(readonly) NSData *data;
@property(readonly) BOOL didSucceed;
@property(readonly) NSString *body;

- (id)initWithRequest:(NCMBOAMutableURLRequest *)aRequest response:(NSURLResponse *)aResponse data:(NSData *)aData didSucceed:(BOOL)success;

@end
