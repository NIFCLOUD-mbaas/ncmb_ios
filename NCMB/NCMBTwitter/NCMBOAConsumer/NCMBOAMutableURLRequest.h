//
//  NCMBOAMutableURLRequest.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NCMBOAConsumer.h"
#import "NCMBOAToken.h"
#import "NCMBOASignatureProviding.h"
#import "NCMBOAHMAC_SHA1SignatureProvider.h"
#import "NCMBOASignatureProviding.h"
#import "NSMutableURLRequestParameters.h"
#import "NSURLBase.h"

@interface NCMBOAMutableURLRequest : NSMutableURLRequest {
@protected
    NCMBOAConsumer *consumer;
    NCMBOAToken *token;
    id<NCMBOASignatureProviding> signatureProvider;
    NSString *realm;
    NSString *signature;
    NSString *nonce;
    NSString *timestamp;
}
@property(readonly) NSString *signature;
@property(readonly) NSString *nonce;

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(NCMBOAConsumer *)aConsumer
			token:(NCMBOAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<NCMBOASignatureProviding>)aProvider;

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(NCMBOAConsumer *)aConsumer
			token:(NCMBOAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<NCMBOASignatureProviding>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp;


- (void)prepare;

@end
