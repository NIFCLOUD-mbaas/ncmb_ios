//
//  NCMBOADataFetcher.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NCMBOAMutableURLRequest.h"
#import "NCMBOAServiceTicket.h"


@interface NCMBOADataFetcher : NSObject {
@private
    NCMBOAMutableURLRequest *request;
    NSURLResponse *response;
    NSURLConnection *connection;
    NSMutableData *responseData;
    id delegate;
    SEL didFinishSelector;
    SEL didFailSelector;
}

- (void)fetchDataWithRequest:(NCMBOAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

@end
