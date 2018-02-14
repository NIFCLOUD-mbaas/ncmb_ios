/*
 Copyright 2017-2018 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMB.h"
#import "NCMBRequest.h"
#import "NCMBUser+Private.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NCMBDateFormat.h"

static NSString *const kEndPoint            = @"https://mb.api.cloud.nifty.com";
static NSString *const kAPIVersion          = @"2013-09-01";
static NSString *const appKeyField       = @"X-NCMB-Application-Key";
static NSString *const timestampField    = @"X-NCMB-Timestamp";
static NSString *const signatureField    = @"X-NCMB-Signature";
static NSString *const sessionTokenField = @"X-NCMB-Apps-Session-Token";
static NSString *const signatureMethod   = @"SignatureMethod=HmacSHA256";
static NSString *const signatureVersion   = @"SignatureVersion=2";

@implementation NCMBRequest

-(instancetype)initWithURL:(NSURL *)url
                    method:(NSString *)method
                    header:(NSDictionary *)headers
                  bodyData:(NSData *)bodyData
{
    self = [NCMBRequest requestWithURL:url
                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                       timeoutInterval:10.0];
    
    // カスタムヘッダー設定
    if (headers != nil && [headers count] > 0) {
        for (NSString *key in [headers allKeys]) {
            [self setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // 必須項目の設定
    self.HTTPMethod = method;
    [self setValue:[NCMB getApplicationKey] forHTTPHeaderField:appKeyField];
    NSString *timestampStr = [NCMBRequest returnTimeStamp];
    [self setValue:timestampStr forHTTPHeaderField:timestampField];
    [self setValue:[NCMBRequest returnSessionToken] forHTTPHeaderField:sessionTokenField];
    [self setValue:[self returnSignature:url
                                  method:method
                               timestamp:timestampStr] forHTTPHeaderField:signatureField];
    
    NSRange range = [url.description rangeOfString:@"script.mb.api.cloud.nifty.com"];
    if(![headers objectForKey:@"Content-Type"] || range.location != NSNotFound){
        [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    // ボディデータ設定
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
        self.HTTPBody = bodyData;
    }
    return self;
}

-(instancetype)initWithURLString:(NSString *)urlString
                          method:(NSString *)method
                          header:(NSDictionary *)headers
                            body:(NSDictionary *)body
{
    NSString *path = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"#[]@!()*+,;\"<>\\%^`{|} \b\t\n\a\r"] invertedSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",kEndPoint,kAPIVersion,path]];
    NSData *bodyData = nil;
    if (body != nil) {
        NSError *error = nil;
        bodyData = [NSJSONSerialization dataWithJSONObject:body
                                                   options:kNilOptions
                                                     error:&error];
        if (error) {
            [NSException raise:NSInvalidArgumentException format:@"body data is invalid json format."];
        }
    }
    return [self initWithURL:url method:method header:headers bodyData:bodyData];
}

+(NSString *)returnTimeStamp{
    return [[NCMBDateFormat getIso8601DateFormat] stringFromDate:[NSDate date]];
}

+(NSString *)returnSessionToken {
    return [NCMBUser getCurrentSessionToken];
}

+(NSString *)returnEncodedString:(NSString *)originalString {
    
    NSString *escapedStr = [originalString stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@":/?#[]@!$&'()*+,;=\"<>\\%^`{|} \b\t\n\a\r"] invertedSet]];
    return escapedStr;
}

-(NSString *)returnSignature:(NSURL *)url method:(NSString *)method timestamp:(NSString *)timestamp {
    if ([NCMB getClientKey] == nil || [NCMB getApplicationKey] == nil){
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Application key or Client key must not be nil." userInfo:nil] raise];
    }
    self.applicationKey =[NCMB getApplicationKey];
    self.clientKey =[NCMB getClientKey];
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    // components.pathはデコードされた値が返却されるのでエンコードする(POST時のファイル名が日本語の場合などに必要)
    NSString *path = [components.path stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"#[]@!()*+,;\"<>\\%^`{|} \b\t\n\a\r"] invertedSet]];
    self.signature = [NSString stringWithFormat:@"%@\n%@\n%@\n%@&%@&%@&%@",
                      method,
                      components.host,
                      path,
                      signatureMethod,
                      signatureVersion,
                      [NSString stringWithFormat:@"%@=%@", appKeyField, self.applicationKey],
                      [NSString stringWithFormat:@"%@=%@", timestampField, timestamp]];
    if (components.percentEncodedQuery != nil && components.percentEncodedQuery.length > 0) {
        if ([@"GET" isEqualToString:method]) {
            self.signature = [self.signature stringByAppendingString:[NSString stringWithFormat:@"&%@", components.percentEncodedQuery]];
        }
    }
    
    return [NCMBRequest encodingSigneture:self.signature method:self];
}

/**
 署名用文字列を元にシグネチャに変換
 @param strForSignature 署名用文字列
 @return NSString型シグネチャ
 */
+(NSString *)encodingSigneture:(NSString *)strForSignature  method:(NCMBRequest *)request{
    
    if (request.clientKey == nil || request.applicationKey == nil){
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Application key or Client key must not be nil." userInfo:nil] raise];
    }
    const char *cKey = [request.clientKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [strForSignature cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *signature = [HMAC base64EncodedStringWithOptions:kNilOptions];

    return signature;
}

@end
