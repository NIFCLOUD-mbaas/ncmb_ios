//
//  NCMBOAMutableURLRequest.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


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

	//	NSLog(@"Normalized: %@", normalizedRequestParameters);
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
