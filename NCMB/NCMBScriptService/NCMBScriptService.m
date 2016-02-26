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

NSString *const NCMBScriptServiceDefaultEndPoint = @"https://script.mb.api.cloud.nifty.com";
NSString *const NCMBScriptServiceApiVersion = @"2015-09-01";
NSString *const NCMBScriptServicePath = @"script";

@implementation NCMBScriptService

- (instancetype)init {
    self = [super init];
    self.endpoint = NCMBScriptServiceDefaultEndPoint;
    
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

- (NSURL *)createUrlFromScriptName:(NSString *)scriptName query:(NSDictionary *)queryDic {
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@",
                     _endpoint,
                     NCMBScriptServiceApiVersion,
                     NCMBScriptServicePath,
                     scriptName];
    if(queryDic != nil && [queryDic count] > 0) {
        url = [url stringByAppendingString:@"?"];
        for (NSString *key in [[queryDic allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            NSString *encodedStr = nil;
            if ([[queryDic objectForKey:key] isKindOfClass:[NSDictionary class]] ||
                [[queryDic objectForKey:key] isKindOfClass:[NSArray class]])
            {
                NSError *error = nil;
                NSData *json = [NSJSONSerialization dataWithJSONObject:[queryDic objectForKey:key]
                                                               options:kNilOptions
                                                                 error:&error];
                if (!error) {
                    NSString *jsonStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                    encodedStr = [NCMBRequest returnEncodedString:jsonStr];
                }
            } else {
                encodedStr = [NCMBRequest returnEncodedString:[NSString stringWithFormat:@"%@",[queryDic objectForKey:key]]];
            }
            if (encodedStr) {
                url = [url stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, encodedStr]];
            }
            
        }
        url = [url stringByReplacingOccurrencesOfString:@"&$"
                                             withString:@""
                                                options:NSRegularExpressionSearch
                                                  range:NSMakeRange(0, url.length)];
    }
    return [NSURL URLWithString:url];
}

- (NCMBRequest *)createRequest:(NSURL *)url
                        method:(NCMBScriptRequestMethod)method
                        header:(NSDictionary *)headerDic
                          body:(NSDictionary *)body
{
    
    NSString *methodStr = nil;
    switch (method) {
        case NCMBExecuteWithGetMethod:
            methodStr = @"GET";
            break;
        case NCMBExecuteWithPostMethod:
            methodStr = @"POST";
            break;
        case NCMBExecuteWithPutMethod:
            methodStr = @"PUT";
            break;
        case NCMBExecuteWithDeleteMethod:
            methodStr = @"DELETE";
            break;
        default:
            break;
    }
    
    return [NCMBRequest requestWithURL:url
                                method:methodStr
                                header:headerDic
                                  body:body];
}

- (NSData *)executeScript:(NSString *)name
                   method:(NCMBScriptRequestMethod)method
                   header:(NSDictionary *)header
                     body:(NSDictionary *)body
                    query:(NSDictionary *)query
                    error:(NSError **)error {
    _request = [self createRequest:[self createUrlFromScriptName:name query:query]
                            method:method
                            header:header
                              body:body];
    
    __block NSData *result = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = ^void (NSData *data, NSURLResponse *response, NSError *responseError) {
        NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)response;
        if (httpRes.statusCode != 200 && httpRes.statusCode != 201) {
            NSError *jsonError = nil;
            if (data != nil) {
                NSDictionary *errorRes = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&jsonError];
                if (jsonError) {
                    responseError = jsonError;
                } else {
                    responseError = [NSError errorWithDomain:@"NCMBErrorDomain"
                                                code:httpRes.statusCode
                                            userInfo:@{NSLocalizedDescriptionKey:[errorRes objectForKey:@"error"]}];
                    
                }
            }
            if (error != nil) {
                *error = responseError;
                result = nil;
            }
            
        } else {
            result = data;
        }
        dispatch_semaphore_signal(semaphore);
        
    };
    if (method == NCMBExecuteWithGetMethod || method == NCMBExecuteWithDeleteMethod) {
        _request.HTTPBody = nil;
        [[_session dataTaskWithRequest:_request
                     completionHandler:completionHandler] resume];
    } else {
        [[_session uploadTaskWithRequest:_request
                                fromData:_request.HTTPBody
                       completionHandler:completionHandler] resume];
        
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

- (void)executeScript:(NSString *)name
               method:(NCMBScriptRequestMethod)method
               header:(NSDictionary *)header
                 body:(NSDictionary *)body
                query:(NSDictionary *)query
            withBlock:(NCMBScriptExecuteCallback)callback
{
    _request = [self createRequest:[self createUrlFromScriptName:name query:query]
                            method:method
                            header:header
                              body:body];
    void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = ^void (NSData *data, NSURLResponse *response, NSError *error) {
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
    };
    if (method == NCMBExecuteWithGetMethod || method == NCMBExecuteWithDeleteMethod) {
        _request.HTTPBody = nil;
        [[_session dataTaskWithRequest:_request
                     completionHandler:completionHandler] resume];
    } else {
        [[_session uploadTaskWithRequest:_request
                                fromData:_request.HTTPBody
                       completionHandler:completionHandler] resume];
        
    }
}

@end
