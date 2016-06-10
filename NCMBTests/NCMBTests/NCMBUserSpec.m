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

#import "Specta.h"
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <NCMB/NCMB.h>

SpecBegin(NCMBUser)

describe(@"NCMBUser", ^{
    
    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";
    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });
    
    beforeEach(^{
        
    });
    
    it(@"should link with google token", ^{
        
        NSDictionary *googleInfo = [NSMutableDictionary dictionary];
        [googleInfo setValue:@"googleId" forKey:@"id"];
        [googleInfo setValue:@"googlgAccessToken" forKey:@"access_token"];
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock signUpInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithGoogleToken:googleInfo withBlock:^(NSError *error) {
            expect(error).beNil();
        }];
        
    });
    
    it(@"should is linked google token with user", ^{
        
        NSMutableDictionary *googleInfo = [NSMutableDictionary dictionary];
        [googleInfo setValue:@"googleId" forKey:@"id"];
        [googleInfo setValue:@"googlgAccessToken" forKey:@"access_token"];
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        expect([user isLinkedWith:@"google"]).to.beTruthy();
        
    });
    
    it(@"should is not linked google token with user", ^{
        
        NSMutableDictionary *googleInfo = [NSMutableDictionary dictionary];
        [googleInfo setValue:@"googleId" forKey:@"id"];
        [googleInfo setValue:@"googlgAccessToken" forKey:@"access_token"];
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        expect([user isLinkedWith:@"twitter"]).to.beFalsy();
        
    });
    
    it(@"should unlink google token with user", ^{
        
        NSMutableDictionary *googleInfo = [NSMutableDictionary dictionary];
        [googleInfo setValue:@"googleId" forKey:@"id"];
        [googleInfo setValue:@"googlgAccessToken" forKey:@"access_token"];
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            if(block){
                block(nil);
            }
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock unlink:@"google" withBlock:^(NSError *error) {
            expect(error).beNil();
        }];
    });
    
    it(@"should unlink google token with user 'other token type error' ", ^{
        
        NSMutableDictionary *googleInfo = [NSMutableDictionary dictionary];
        [googleInfo setValue:@"googleId" forKey:@"id"];
        [googleInfo setValue:@"googlgAccessToken" forKey:@"access_token"];
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            if(block){
                block(nil);
            }
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock unlink:@"twitter" withBlock:^(NSError *error) {
            
            NSError *tokenError = [NSError errorWithDomain:ERRORDOMAIN
                                                      code:404003
                                                  userInfo:@{NSLocalizedDescriptionKey:@"other token type"}];
            
            expect(error).to.equal(tokenError);
        }];
    });
    
    it(@"should unlink google token with user 'token not found error' ", ^{
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            if(block){
                block(nil);
            }
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock unlink:@"google" withBlock:^(NSError *error) {
            
            NSError *tokenError = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:404003
                                             userInfo:@{NSLocalizedDescriptionKey:@"token not found"}];
            
            expect(error).to.equal(tokenError);
        }];
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd