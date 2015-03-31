/*
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
 */

//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "NCMBOADataFetcher.h"


@implementation NCMBOADataFetcher

- (id)init {
	if ((self = [super init])) {
		responseData = [[NSMutableData alloc] init];
	}
	return self;
}


/* Protocol for async URL loading */
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
	response = aResponse;
	[responseData setLength:0];
}
	
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	NCMBOAServiceTicket *ticket = [[NCMBOAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:responseData
															didSucceed:NO];

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[delegate performSelector:didFailSelector withObject:ticket withObject:error];
    #pragma clang diagnostic pop
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NCMBOAServiceTicket *ticket = [[NCMBOAServiceTicket alloc] initWithRequest:request
															  response:response
																  data:responseData
															didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[delegate performSelector:didFinishSelector withObject:ticket withObject:responseData];
    #pragma clang diagnostic pop
}

- (void)fetchDataWithRequest:(NCMBOAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;

    [request prepare];
	connection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
}

@end
