/*
 Copyright 2017-2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import <Foundation/Foundation.h>

#import "NCMBRequest.h"

/**
 スクリプトを実行するリクエストメソッド
*/
typedef NS_ENUM(NSUInteger, NCMBScriptRequestMethod) {
    /// GETメソッドでのスクリプト実行
    NCMBExecuteWithGetMethod,
    /// POSTメソッドでのスクリプト実行
    NCMBExecuteWithPostMethod,
    /// PUTメソッドでのスクリプト実行
    NCMBExecuteWithPutMethod,
    /// DELETEメソッドでのスクリプト実行
    NCMBExecuteWithDeleteMethod
};

extern NSString *const NCMBScriptServiceDefaultEndPoint;
extern NSString *const NCMBScriptServiceApiVersion;
extern NSString *const NCMBScriptServicePath;

typedef void (^NCMBScriptExecuteCallback) (NSData *data, NSError *error);

@interface NCMBScriptService : NSObject

@property NSString *endpoint;

@property NCMBRequest *request;

@property NSURLSession *session;

- (instancetype)initWithEndpoint:(NSString *)endpoint;

- (NSData *)executeScript:(NSString *)name
               method:(NCMBScriptRequestMethod)method
               header:(NSDictionary *)header
                 body:(NSDictionary *)body
                query:(NSDictionary *)query
                error:(NSError **)error;

- (void)executeScript:(NSString *)name
               method:(NCMBScriptRequestMethod)method
               header:(NSDictionary *)header
                 body:(NSDictionary *)body
                query:(NSDictionary *)query
            withBlock:(NCMBScriptExecuteCallback)callback;

@end
