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

#import "NCMB.h"
#import "NCMBRequest.h"
#import "NCMBUser+Private.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString *const appKeyField       = @"X-NCMB-Application-Key";
static NSString *const timestampField    = @"X-NCMB-Timestamp";
static NSString *const signatureField    = @"X-NCMB-Signature";
static NSString *const sessionTokenField = @"X-NCMB-Apps-Session-Token";
static NSString *const signatureMethod   = @"SignatureMethod=HmacSHA256";
static NSString *const signatureVersion   = @"SignatureVersion=2";

@implementation NCMBRequest

+(instancetype)requestWithURL:(NSURL *)url
                       method:(NSString *)method
                       header:(NSDictionary *)headers
                         body:(NSDictionary *)body
{
    NCMBRequest *request = [NCMBRequest requestWithURL:url
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:10.0];
    request.HTTPMethod = method;
    [request addValue:[NCMB getApplicationKey] forHTTPHeaderField:appKeyField];
    NSString *timestampStr = [self returnTimeStamp];
    [request addValue:timestampStr forHTTPHeaderField:timestampField];
    [request addValue:[self returnSessionToken] forHTTPHeaderField:sessionTokenField];
    [request addValue:[self returnSignature:url
                                     method:method
                                  timestamp:timestampStr]
   forHTTPHeaderField:signatureField];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (headers != nil && [headers count] > 0) {
        for (NSString *key in [headers allKeys]) {
            if ([key isEqualToString:@"Content-Type"]) {
                continue;
            }
            [request addValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    if (body != nil && [body count] > 0) {
        NSError *error = nil;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body
                                                           options:kNilOptions
                                                             error:&error];
        if (!error) {
            request.HTTPBody = bodyData;
        } else {
            [NSException raise:NSInvalidArgumentException format:@"body data is invalid json format."];
        }
    }
    return request;
}

+(NSString *)returnTimeStamp{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    //和暦表示と12時間表示対策
    NSCalendar *calendar = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    } else {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    [df setCalendar:calendar];
    [df setLocale:[NSLocale systemLocale]];
    return [df stringFromDate:[NSDate date]];
}

+(NSString *)returnSessionToken {
    return [NCMBUser getCurrentSessionToken];
}

+(NSString *)returnEncodedString:(NSString *)originalString {
    CFStringRef escapedStrRef = CFURLCreateStringByAddingPercentEscapes(
                                                                        NULL,
                                                                        (__bridge CFStringRef)originalString,
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8 );
    NSString *escapedStr = CFBridgingRelease(escapedStrRef);
    return escapedStr;
}

+ (NSString *)returnSignature:(NSURL *)url method:(NSString *)method timestamp:(NSString *)timestamp {
    if ([NCMB getClientKey] == nil || [NCMB getApplicationKey] == nil){
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Application key or Client key must not be nil." userInfo:nil] raise];
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString *strForSignature = [NSString stringWithFormat:@"%@\n%@\n%@\n%@&%@&%@&%@",
                                   method,
                                   components.host,
                                   components.path,
                                   signatureMethod,
                                   signatureVersion,
                                   [NSString stringWithFormat:@"%@=%@", appKeyField, [NCMB getApplicationKey]],
                                   [NSString stringWithFormat:@"%@=%@", timestampField, timestamp]];
    if (components.percentEncodedQuery != nil) {
        strForSignature = [strForSignature stringByAppendingString:[NSString stringWithFormat:@"&%@", components.percentEncodedQuery]];
    }
    
    const char *cKey = [[NCMB getClientKey] cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [strForSignature cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *signature = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0){
        signature = [HMAC base64EncodedStringWithOptions:kNilOptions];
    }
    return signature;
}

@end
