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

NSString *const defaultEndPoint = @"https://logic.mb.api.cloud.nifty.com";
NSString *const apiVersion = @"2015-09-01";
NSString *const servicePath = @"script";

@implementation NCMBScriptService

- (instancetype)init {
    self = [super init];
    self.endpoint = defaultEndPoint;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    _session = [NSURLSession sessionWithConfiguration:config
                                             delegate:nil
                                        delegateQueue:[NSOperationQueue mainQueue]];
    return self;
}

- (instancetype)initWithEndpoint:(NSString *)endpoint {
    self = [self init];
    self.endpoint = endpoint;
    return self;
}

- (NSData *)executeScript:(NSData*)data error:(NSError**)error {
    return nil;
}

- (void)executeScript:(NSString *)name
               method:(NCMBScriptRequestMethod)method
                param:(NSData *)param
           queryParam:(NSDictionary *)queryParam
            withBlock:(NCMBScriptExecuteCallback)callback
{
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@", _endpoint, apiVersion, servicePath, name];
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    if(queryParam != nil && [queryParam count] > 0) {
        NSMutableArray *queryArray = [NSMutableArray array];
        for (NSString *key in [queryParam allKeys]) {
            NSError *convertError = nil;
            NSData *json = [NSJSONSerialization dataWithJSONObject:[queryParam objectForKey:key]
                                                           options:kNilOptions
                                                             error:&convertError];
            NSString *valueStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            NSString *encodedStr = [NCMBRequest returnEncodedString:valueStr];
            [queryArray addObject:[NSURLQueryItem queryItemWithName:key value:encodedStr]];
        }
        components.queryItems = queryArray;
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?%@", components.query]];
    }
    NSString *methodStr = nil;
    switch (method) {
        case NCMBSCRIPT_GET:
            methodStr = @"GET";
            break;
        case NCMBSCRIPT_POST:
            methodStr = @"POST";
            break;
        case NCMBSCRIPT_PUT:
            methodStr = @"PUT";
            break;
        case NCMBSCRIPT_DELETE:
            methodStr = @"DELETE";
            break;
        default:
            break;
    }
    _request = [NCMBRequest requestWithURL:[NSURL URLWithString:url]
                                  method:methodStr
                                  HTTPBody:param];
    [[_session dataTaskWithRequest:_request
                completionHandler:^(NSData * _Nullable data,
                                    NSURLResponse * _Nullable response,
                                    NSError * _Nullable error)
     {
         NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)response;
         if (httpRes.statusCode != 200 && httpRes.statusCode != 201) {
             NSError *jsonError = nil;
             if (data != nil) {
                 NSDictionary *errorRes = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:NSJSONReadingAllowFragments
                                                                            error:&jsonError];
                 if (jsonError) {
                     error = jsonError;
                 } else {
                     error = [NSError errorWithDomain:@"NCMBErrorDomain"
                                                 code:httpRes.statusCode
                                             userInfo:@{NSLocalizedDescriptionKey:[errorRes objectForKey:@"error"]}];
                     
                 }
             }
             if (callback != nil) {
                callback(nil, error);
             }

         } else {
             if (callback != nil) {
                callback(data, error);
             }
         }
     }] resume];
}

@end
