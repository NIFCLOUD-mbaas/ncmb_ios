/*******
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
 **********/


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
