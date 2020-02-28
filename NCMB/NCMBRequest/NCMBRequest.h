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
#import <UIKit/UIKit.h>

@interface NCMBRequest : NSMutableURLRequest

@property (nonatomic)NSString *signature;
@property (nonatomic)NSString *applicationKey;
@property (nonatomic)NSString *clientKey;

-(instancetype)initWithURLString:(NSString *)urlString
                    method:(NSString *)method
                    header:(NSDictionary *)headers
                      body:(NSDictionary *)body;

-(instancetype)initWithURLStringForUser:(NSString *)urlString
                    method:(NSString *)method
                    header:(NSDictionary *)headers
                      body:(NSDictionary *)body;

-(instancetype)initWithURL:(NSURL *)url
                    method:(NSString *)method
                    header:(NSDictionary *)headers
                  bodyData:(NSData *)bodyData;

+(NSString *)returnTimeStamp;

+(NSString *)returnSessionToken;

-(NSString *)returnSignature:(NSURL *)url method:(NSString *)method timestamp:(NSString *)timestamp;

+(NSString *)returnEncodedString:(NSString *)originalString;

+(NSString *)encodingSigneture:(NSString *)strForSignature  method:(NCMBRequest *)request;
@end
