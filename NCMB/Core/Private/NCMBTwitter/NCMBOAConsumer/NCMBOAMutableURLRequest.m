/*
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
 */

//
//  OAMutableURLRequest.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



#import "NCMBOAMutableURLRequest.h"

@implementation NCMBOAMutableURLRequest
@synthesize signature, nonce;

#pragma mark init

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(NCMBOAConsumer *)aConsumer
			token:(NCMBOAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<NCMBOASignatureProviding>)aProvider {
    if ((self = [super initWithURL:aUrl
                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                   timeoutInterval:10.0])) {
        
		consumer = aConsumer;
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil) {
			token = [[NCMBOAToken alloc] init];
		} else {
			token = aToken;
		}
		
		if (aRealm == nil) {
			realm = @"";
		} else {
			realm = [aRealm copy];
		}
        
		// default to HMAC-SHA1
		if (aProvider == nil) {
			signatureProvider = [[NCMBOAHMAC_SHA1SignatureProvider alloc] init];
		} else {
			signatureProvider = aProvider;
		}
		
		[self _generateTimestamp];
		[self _generateNonce];
	}
    
    return self;
}

// Setting a timestamp and nonce to known
// values can be helpful for testing
- (id)initWithURL:(NSURL *)aUrl
		 consumer:(NCMBOAConsumer *)aConsumer
			token:(NCMBOAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<NCMBOASignatureProviding>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp {
    if ((self = [self initWithURL:aUrl consumer:aConsumer token:aToken realm:aRealm signatureProvider:aProvider])) {
        nonce = [aNonce copy];
        timestamp = [aTimestamp copy];
    }
    
    return self;
}

- (NSString *)encodedURLParameterString:(NSString*)str{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
                                                                           CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                           kCFStringEncodingUTF8));

	return result;
}

- (void)prepare {
    // sign
    signature = [signatureProvider signClearText:[self _signatureBaseString]
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
                                                  consumer.secret,
                                                  token.secret ? token.secret : @""]];
    
    // set OAuth headers
	NSMutableArray *chunks = [[NSMutableArray alloc] init];
	[chunks addObject:[NSString stringWithFormat:@"realm=\"%@\"", [self encodedURLParameterString:realm]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"", [self encodedURLParameterString:consumer.key]]];
    
	NSDictionary *tokenParameters = [token parameters];
	for (NSString *k in tokenParameters) {
		[chunks addObject:[NSString stringWithFormat:@"%@=\"%@\"", k, [self encodedURLParameterString:[tokenParameters objectForKey:k]]]];
	}
    
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"", [self encodedURLParameterString:[signatureProvider name]]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"", [self encodedURLParameterString:signature]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"", timestamp]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"", nonce]];
	[chunks	addObject:@"oauth_version=\"1.0\""];
	
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth %@", [chunks componentsJoinedByString:@", "]];
    
    [self setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}

- (void)_generateTimestamp {
    timestamp = [[NSString alloc]initWithFormat:@"%d", (int)time(NULL)];
}

- (void)_generateNonce {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);//CFUUIDはARC管理対象外のため使用後リファレンスカウンタを減らす
    if (nonce) {
		CFRelease((__bridge CFTypeRef)(nonce));
	}
    nonce = (NSString *)uuidString;
}

NSInteger _normalize(id obj1, id obj2, void *context)
{
    NSArray *nameAndValue1 = [obj1 componentsSeparatedByString:@"="];
    NSArray *nameAndValue2 = [obj2 componentsSeparatedByString:@"="];
    
    NSString *name1 = [nameAndValue1 objectAtIndex:0];
    NSString *name2 = [nameAndValue2 objectAtIndex:0];
    
    NSComparisonResult comparisonResult = [name1 compare:name2];
    if (comparisonResult == NSOrderedSame) {
        NSString *value1 = [nameAndValue1 objectAtIndex:1];
        NSString *value2 = [nameAndValue2 objectAtIndex:1];
        
        comparisonResult = [value1 compare:value2];
    }
    
    return comparisonResult;
}


- (NSString *)_signatureBaseString {
    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
	NSDictionary *tokenParameters = [token parameters];
	// 6 being the number of OAuth params in the Signature Base String
	NSArray *parameters = [NSMutableURLRequestOAParameterAdditions parametersWithRequest:self];
	NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity:(5 + [parameters count] + [tokenParameters count])];
    
	NCMBOARequestParameter *parameter;
	parameter = [[NCMBOARequestParameter alloc] initWithName:@"oauth_consumer_key" value:consumer.key];
	
    [parameterPairs addObject:[parameter URLEncodedNameValuePair]];
	parameter = [[NCMBOARequestParameter alloc] initWithName:@"oauth_signature_method" value:[signatureProvider name]];
    [parameterPairs addObject:[parameter URLEncodedNameValuePair]];
	parameter = [[NCMBOARequestParameter alloc] initWithName:@"oauth_timestamp" value:timestamp];
    [parameterPairs addObject:[parameter URLEncodedNameValuePair]];
	parameter = [[NCMBOARequestParameter alloc] initWithName:@"oauth_nonce" value:nonce];
    [parameterPairs addObject:[parameter URLEncodedNameValuePair]];
	parameter = [[NCMBOARequestParameter alloc] initWithName:@"oauth_version" value:@"1.0"] ;
    [parameterPairs addObject:[parameter URLEncodedNameValuePair]];
	
	for(NSString *k in tokenParameters) {
		[parameterPairs addObject:[[NCMBOARequestParameter requestParameter:k value:[tokenParameters objectForKey:k]] URLEncodedNameValuePair]];
	}
    
	if (![[self valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"multipart/form-data"]) {
		for (NCMBOARequestParameter *param in parameters) {
			[parameterPairs addObject:[param URLEncodedNameValuePair]];
		}
	}
    
    // Oauth Spec, Section 3.4.1.3.2 "Parameters Normalization
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingFunction:_normalize context:NULL];
    
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];

    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    return [NSString stringWithFormat:@"%@&%@&%@",
            [self HTTPMethod],
            [NSStringOAURLEncodingAdditions encodedURLParameterStringWithString:[NSURLOABaseAdditions URLStringWithoutQueryWithURL:[self URL]]],
            [NSStringOAURLEncodingAdditions encodedURLStringWithString:normalizedRequestParameters]];
}

/*
- (void) dealloc
{

	if (nonce) {
		CFRelease(nonce);
	}
}
*/

@end
