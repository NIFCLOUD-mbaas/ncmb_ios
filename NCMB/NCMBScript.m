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

#import "NCMBScript.h"

@implementation NCMBScript

- (instancetype)initWithName:(NSString*)name method:(NCMBScriptRequestMethod)method endpoint:(NSString *)endpoint{
    if (endpoint != nil) {
        _service = [[NCMBScriptService alloc] initWithEndpoint:endpoint];
    } else {
        _service = [[NCMBScriptService alloc] init];
    }
    self = [super init];
    _scriptName = name;
    _method = method;
    return self;
}

+ (instancetype)scriptWithName:(NSString * __nonnull)name method:(NCMBScriptRequestMethod)method{
    return [self scriptWithName:name method:method endpoint:nil];
}

+ (instancetype)scriptWithName:(NSString *)name
                        method:(NCMBScriptRequestMethod)method
                      endpoint:(NSString *)endpoint
{
    if (name == nil){
        [NSException raise:NSInvalidArgumentException format:@"script name must not be nil."];
    }
    if (method != NCMBExecuteWithGetMethod &&
        method != NCMBExecuteWithPostMethod &&
        method != NCMBExecuteWithPutMethod &&
        method != NCMBExecuteWithDeleteMethod) {
        [NSException raise:NSInvalidArgumentException format:@"invalid request method."];
    }
    return [[NCMBScript alloc] initWithName:name method:method endpoint:endpoint];
}

- (NSData *)execute:(NSDictionary *)data
            headers:(NSDictionary *)headers
            queries:(NSDictionary *)queries
              error:(NSError **)error{
    return [_service executeScript:_scriptName
                     method:_method
                     header:headers
                       body:data
                      query:queries
                      error:error];
    
}

- (void)execute:(NSDictionary *)data
        headers:(NSDictionary *)headers
        queries:(NSDictionary *)queries
      withBlock:(NCMBScriptExecuteCallback)block {
    [_service executeScript:_scriptName
                     method:_method
                     header:headers
                       body:data
                      query:queries
                  withBlock:block];
}

@end
