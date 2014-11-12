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
