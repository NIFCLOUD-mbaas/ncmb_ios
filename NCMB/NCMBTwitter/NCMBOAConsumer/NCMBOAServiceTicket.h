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
