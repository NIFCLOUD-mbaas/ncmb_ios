/*
 Copyright 2016 NIFTY Corporation All Rights Reserved.
 
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

#import "NCMBScriptService.h"

@implementation NCMBScriptService

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithScriptName:(NSString*)name method:(NCMBScriptRequestMethod)method {
    self = [super init];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    _session = [NSURLSession sessionWithConfiguration:config
                                             delegate:nil
                                        delegateQueue:[NSOperationQueue mainQueue]];
    
    return self;
}

- (NSURL *)createUrl{
    return [NSURL URLWithString:@""];
}

- (NSData *)executeScript:(NSData*)data error:(NSError**)error {
    return nil;
}

- (void)executeScript:(NSData *)data withBlock:(NCMBScriptExecuteCallback)block {
    NSURL *url = [self createUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5.0];
    [[_session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data,
                                    NSURLResponse * _Nullable response,
                                    NSError * _Nullable error)
     {
         NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)response;
         if (httpRes.statusCode != 200 && httpRes.statusCode != 201) {
             NSError *jsonError = nil;
             NSDictionary *errorRes = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&jsonError];
             if (jsonError) {
                 error = jsonError;
             } else {
                 error = [NSError errorWithDomain:@"NCMBErrorDomain"
                                             code:httpRes.statusCode
                                         userInfo:@{NSLocalizedDescriptionKey:[errorRes objectForKey:@"error"]}];
                 block(nil, error);
             }
         } else {
             block(data, error);
         }
     }] resume];
    
}

@end
