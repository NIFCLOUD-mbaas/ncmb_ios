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
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(NCMBUser)
#define DATA_MAIN_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"]
#define DATA_CURRENTUSER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentUser", DATA_MAIN_PATH]

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
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithGoogleToken:googleInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
            }
        }];
        
    });
    
    it(@"should link with google token if already other token", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *twitterAuth = [NSMutableDictionary dictionary];
        [twitterAuth setObject:twitterInfo forKey:@"twitter"];
        [mock setObject:twitterAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithGoogleToken:googleInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
            }
        }];
    });
    
    it(@"should case of network error are not link with google token and return existing token", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *twitterAuth = [NSMutableDictionary dictionary];
        [twitterAuth setObject:twitterInfo forKey:@"twitter"];
        [mock setObject:twitterAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSError *e = [NSError errorWithDomain:@"NCMBErrorDomain"
                                                 code:-1
                                             userInfo:nil];
            block(e);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithGoogleToken:googleInfo withBlock:^(NSError *error) {
            expect(error).to.beTruthy();
            if(error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.beNil();
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
            }
        }];
    });
    
    it(@"should link with google token update for private documents device currentUser files", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *twitterAuth = [NSMutableDictionary dictionary];
        [twitterAuth setObject:twitterInfo forKey:@"twitter"];
        [mock setObject:twitterAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithGoogleToken:googleInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                NCMBUser *currentUser = [NCMBUser currentUser];
                expect([[currentUser objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
                expect([[currentUser objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
            }
        }];
    });
    
    
    
    it(@"should link with twitter token", ^{
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithTwitterToken:twitterInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
            }
        }];
        
    });
    
    it(@"should link with twitter token if already other token", ^{
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };

        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *facebookAuth = [NSMutableDictionary dictionary];
        [facebookAuth setObject:facebookInfo forKey:@"facebook"];
        [mock setObject:facebookAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithTwitterToken:twitterInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
            }
        }];
    });
    
    it(@"should case of network error are not link with twitter token and return existing token", ^{
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *facebookAuth = [NSMutableDictionary dictionary];
        [facebookAuth setObject:facebookInfo forKey:@"facebook"];
        [mock setObject:facebookAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSError *e = [NSError errorWithDomain:@"NCMBErrorDomain"
                                             code:-1
                                         userInfo:nil];
            block(e);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithTwitterToken:twitterInfo withBlock:^(NSError *error) {
            expect(error).to.beTruthy();
            if(error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.beNil();
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
            }
        }];
    });
    
    
    
    
    it(@"should link with facebook token", ^{
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithFacebookToken:facebookInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
            }
        }];
        
    });
    
    it(@"should link with facebook token if already other token", ^{
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *googleAuth = [NSMutableDictionary dictionary];
        [googleAuth setObject:googleInfo forKey:@"google"];
        [mock setObject:googleAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            block(nil);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithFacebookToken:facebookInfo withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
            }
        }];
    });
    
    it(@"should case of network error are not link with facebook token and return existing token", ^{
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NCMBUser *user = [NCMBUser user];
        id mock = OCMPartialMock(user);
        
        NSMutableDictionary *googleAuth = [NSMutableDictionary dictionary];
        [googleAuth setObject:googleInfo forKey:@"google"];
        [mock setObject:googleAuth forKey:@"authData"];
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSError *e = [NSError errorWithDomain:@"NCMBErrorDomain"
                                             code:-1
                                         userInfo:nil];
            block(e);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [mock linkWithFacebookToken:facebookInfo withBlock:^(NSError *error) {
            expect(error).to.beTruthy();
            if(error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.beNil();
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
            }
        }];
    });

    
    
    it(@"should is linked google token with user", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        expect([user isLinkedWith:@"google"]).to.beTruthy();
        
    });
    
    it(@"should is not linked google token with user", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        expect([user isLinkedWith:@"twitter"]).to.beFalsy();
        
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
    
    it(@"should unlink google token with user", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        [userAuthData setObject:twitterInfo forKey:@"twitter"];
        
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
        
        expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
        expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
        
        [mock unlink:@"google" withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.beNil();
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
            }
        }];
    });
    
    it(@"should case of network error are not unlink with google token and return existing token", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:googleInfo forKey:@"google"];
        [userAuthData setObject:twitterInfo forKey:@"twitter"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSError *e = [NSError errorWithDomain:@"NCMBErrorDomain"
                                             code:-1
                                         userInfo:nil];
            block(e);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
        expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
        
        [mock unlink:@"google" withBlock:^(NSError *error) {
            expect(error).to.beTruthy();
            if(error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
            }
        }];
    });
    
    it(@"should unlink twitter token with user", ^{
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:twitterInfo forKey:@"twitter"];
        [userAuthData setObject:facebookInfo forKey:@"facebook"];
        
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
        
        expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
        expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
        
        [mock unlink:@"twitter" withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.beNil();
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
            }
        }];
    });
    
    it(@"should case of network error are not unlink with twitter token and return existing token", ^{
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:twitterInfo forKey:@"twitter"];
        [userAuthData setObject:facebookInfo forKey:@"facebook"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSError *e = [NSError errorWithDomain:@"NCMBErrorDomain"
                                             code:-1
                                         userInfo:nil];
            block(e);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
        expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
        
        [mock unlink:@"twitter" withBlock:^(NSError *error) {
            expect(error).to.beTruthy();
            if(error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"twitter"]).to.equal(twitterInfo);
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
            }
        }];
    });
        
    it(@"should unlink facebook token with user", ^{
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:facebookInfo forKey:@"facebook"];
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
        
        expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
        expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
        
        [mock unlink:@"facebook" withBlock:^(NSError *error) {
            expect(error).beNil();
            if(!error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.beNil();
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
            }
        }];
    });
    
    it(@"should case of network error are not unlink with facebook token and return existing token", ^{
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
        [userAuthData setObject:facebookInfo forKey:@"facebook"];
        [userAuthData setObject:googleInfo forKey:@"google"];
        
        NCMBUser *user = [NCMBUser user];
        [user setObject:userAuthData forKey:@"authData"];
        
        id mock = OCMPartialMock(user);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSError *e = [NSError errorWithDomain:@"NCMBErrorDomain"
                                             code:-1
                                         userInfo:nil];
            block(e);
        };
        
        OCMStub([mock saveInBackgroundWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
        expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
        
        [mock unlink:@"facebook" withBlock:^(NSError *error) {
            expect(error).to.beTruthy();
            if(error) {
                expect([[mock objectForKey:@"authData"]objectForKey:@"facebook"]).to.equal(facebookInfo);
                expect([[mock objectForKey:@"authData"]objectForKey:@"google"]).to.equal(googleInfo);
            }
        }];
    });
    
    it(@"should return YES when mail address confirm is setting YES", ^{
        
        NCMBUser *user = [NCMBUser user];
        
        [user setObject:[NSNumber numberWithBool:YES] forKey:@"mailAddressConfirm"];
        
        expect([user isMailAddressConfirm]).to.beTruthy();
        
    });
    
    it(@"should return NO when mail address confirm is setting invalid params", ^{
        
        NCMBUser *user = [NCMBUser user];
        
        [user setObject:[NSNumber numberWithBool:NO] forKey:@"mailAddressConfirm"];
        expect([user isMailAddressConfirm]).toNot.beTruthy();
        
        [user setObject:@"" forKey:@"mailAddressConfirm"];
        expect([user isMailAddressConfirm]).toNot.beTruthy();
        
        [user setObject:@"aaa" forKey:@"mailAddressConfirm"];
        expect([user isMailAddressConfirm]).toNot.beTruthy();
        
        [user setObject:[NSNull null] forKey:@"mailAddressConfirm"];
        expect([user isMailAddressConfirm]).toNot.beTruthy();
        
    });
    
    it(@"should signUp with google token", ^{
        
        NSDictionary *googleInfo = @{@"id" : @"googleId",
                                     @"access_token" : @"googleAccessToken"
                                     };
        
        NCMBUser *user = [NCMBUser user];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
           
            NSMutableDictionary *responseDic = [@{
                                                  @"createDate" : @"2017-01-31T04:13:03.065Z",
                                                  @"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"kBv218vmi0"
                                                  } mutableCopy];
            
            NSMutableDictionary *authData = [NSMutableDictionary dictionary];
            [authData setObject:googleInfo forKey:@"google"];
            [responseDic setObject:authData forKey:@"authData"];
            
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            [user signUpWithGoogleToken:googleInfo withBlock:^(NSError *error) {
                expect(error).beNil();
                if(!error) {
                    NCMBUser *currentUser = [NCMBUser currentUser];
                    expect(currentUser.sessionToken).beTruthy();
                    done();
                }
            }];
        });
    });
    
    it(@"should signUp with twitter token", ^{
        
        NSDictionary *twitterInfo = @{@"consumer_secret" : @"twitterSecret",
                                      @"id" : @"twitterId",
                                      @"oauth_consumer_key" : @"twitterConsumuerKey",
                                      @"oauth_token" : @"twitterOauthToken",
                                      @"oauth_token_secret" : @"twitterOauthTokenSecret",
                                      @"screen_name" : @"NCMBSupport"
                                      };
        
        NCMBUser *user = [NCMBUser user];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSMutableDictionary *responseDic = [@{
                                                  @"createDate" : @"2017-01-31T04:13:03.065Z",
                                                  @"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"kBv218vmi0"
                                                  } mutableCopy];
            
            NSMutableDictionary *authData = [NSMutableDictionary dictionary];
            [authData setObject:twitterInfo forKey:@"twitter"];
            [responseDic setObject:authData forKey:@"authData"];
            
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            [user signUpWithTwitterToken:twitterInfo withBlock:^(NSError *error) {
                expect(error).beNil();
                if(!error) {
                    NCMBUser *currentUser = [NCMBUser currentUser];
                    expect(currentUser.sessionToken).beTruthy();
                    done();
                }
            }];
        });
    });

    it(@"should signUp with facebook token", ^{
        
        NSDictionary *facebookInfo = @{@"id" : @"facebookId",
                                       @"access_token" : @"facebookToken",
                                       @"expiration_date":@{@"__type" : @"Date",@"iso" : @"2016-09-06T05:41:33.466Z"}
                                       };
        
        NCMBUser *user = [NCMBUser user];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSMutableDictionary *responseDic = [@{
                                                  @"createDate" : @"2017-01-31T04:13:03.065Z",
                                                  @"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"kBv218vmi0"
                                                  } mutableCopy];
            
            NSMutableDictionary *authData = [NSMutableDictionary dictionary];
            [authData setObject:facebookInfo forKey:@"facebook"];
            [responseDic setObject:authData forKey:@"authData"];
            
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            [user signUpWithFacebookToken:facebookInfo withBlock:^(NSError *error) {
                expect(error).beNil();
                if(!error) {
                    NCMBUser *currentUser = [NCMBUser currentUser];
                    expect(currentUser.sessionToken).beTruthy();
                    done();
                }
            }];
        });
    });
    
    it(@"after logged in should not change current user when update another user", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSMutableDictionary *responseDic = [@{@"createDate" : @"2017-01-31T04:13:03.065Z",
                                                  @"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"admin"
                                                  } mutableCopy];
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        waitUntil(^(DoneCallback done) {
            // 1.ログインする
            [NCMBUser logInWithUsernameInBackground:@"admin" password:@"123456" block:^(NCMBUser *user, NSError *error) {
                
                expect(error).beNil();
                expect([NCMBUser currentUser]).notTo.beNil();
                
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    
                    NSMutableDictionary *responseDic = [@{@"updateDate" : @"2017-07-10T02:37:54.917Z"
                                                          } mutableCopy];
                    
                    NSError *convertErr = nil;
                    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                           options:0
                                                                             error:&convertErr];
                    
                    return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
                }];
                
                // 2.別のユーザーを変更する
                NCMBUser *updateUser = [[NCMBUser alloc] init];
                updateUser.objectId = @"e4YWYnYtcptTIV23";
                updateUser.userName = @"user001";
                
                [updateUser saveInBackgroundWithBlock:^(NSError *error) {
                    NCMBUser *currentUser = [NCMBUser currentUser];
                    
                    // 3.カレントユーザーは変更したユーザーにならない
                    expect(error).beNil();
                    expect(currentUser).notTo.beNil();
                    expect(currentUser).notTo.equal(updateUser);
                    
                    done();
                }];
            }];
        });
    });
    
    it(@"even not logged in should not become current user when update any user", ^{
        // 1.念のためログアウトする
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSData *responseData = [[NSData alloc]init];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        [NCMBUser logOut];
        
        // 2.新規ユーザー登録
        NCMBUser *updateUser = [[NCMBUser alloc] init];
        updateUser.objectId = @"e4YWYnYtcptTIV23";
        updateUser.userName = @"user001";
        
        waitUntil(^(DoneCallback done) {
            [updateUser saveInBackgroundWithBlock:^(NSError *error) {
                NCMBUser *currentUser = [NCMBUser currentUser];
                
                // 3.ログインしていなくても変更したユーザーにならない
                expect(error).beNil();
                expect(currentUser).beNil();
                
                done();
            }];
        });
    });
    
    it(@"should become current user when regist new user", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSMutableDictionary *responseDic = [@{@"createDate" : @"2017-01-31T04:13:03.065Z",
                                                  @"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"user1"
                                                  } mutableCopy];
            
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        // 1.新規ユーザー登録
        NCMBUser *user = [NCMBUser user];
        
        user.userName = @"user1";
        user.password = @"password1";
        
        waitUntil(^(DoneCallback done) {
            [user signUpInBackgroundWithBlock:^(NSError *error) {
                NCMBUser *currentUser = [NCMBUser currentUser];
                // 2.登録したユーザーがカレントユーザーになります
                expect(error).beNil();
                expect(currentUser).notTo.beNil();
                expect(currentUser).equal(user);
                
                done();
            }];
        });
    });
    
    it(@"after logged in should change to current user when regist new user", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSMutableDictionary *responseDic = [@{@"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"admin"
                                                  } mutableCopy];
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        waitUntil(^(DoneCallback done) {
            // 1.ログインする
            [NCMBUser logInWithUsernameInBackground:@"admin" password:@"123456" block:^(NCMBUser *user, NSError *error) {
                
                expect(error).beNil();
                expect([NCMBUser currentUser]).notTo.beNil();
                
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    
                    NSMutableDictionary *responseDic = [@{@"createDate" : @"2017-01-31T04:13:03.065Z",
                                                          @"objectId" : @"e4YWYnYtcptTIV23",
                                                          @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                          @"userName" : @"user1"
                                                          } mutableCopy];
                    
                    NSError *convertErr = nil;
                    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                           options:0
                                                                             error:&convertErr];
                    
                    return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
                }];
                
                // 2.新規ユーザー登録
                NCMBUser *regisUser = [NCMBUser user];
                
                regisUser.userName = @"user1";
                regisUser.password = @"password1";
                
                [regisUser signUpInBackgroundWithBlock:^(NSError *error) {
                    
                    NCMBUser *currentUser = [NCMBUser currentUser];
                    // 3.登録したユーザーがカレントユーザーになります
                    expect(error).beNil();
                    expect(currentUser).equal(regisUser);
                    
                    done();
                }];
                
            }];
        });
    });
    
    it(@"should update data local when update current user", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSMutableDictionary *responseDic = [@{@"createDate" : @"2017-01-31T04:13:03.065Z",
                                                  @"objectId" : @"e4YWYnYtcptTIV23",
                                                  @"sessionToken" : @"yDCY0ggL8hZghFQ70aiutHtJL",
                                                  @"userName" : @"admin"
                                                  } mutableCopy];
            
            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];
        
        waitUntil(^(DoneCallback done) {
            // 1.ログインする
            [NCMBUser logInWithUsernameInBackground:@"admin" password:@"123456" block:^(NCMBUser *user, NSError *error) {
                
                expect(error).beNil();
                NCMBUser *currentUser = [NCMBUser currentUser];
                expect(currentUser).notTo.beNil();
                
                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.host isEqualToString:@"mb.api.cloud.nifty.com"];
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    
                    NSMutableDictionary *responseDic = [@{
                                                          @"updateDate" : @"2017-07-10T02:37:54.917Z",
                                                          } mutableCopy];
                    NSError *convertErr = nil;
                    NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                           options:0
                                                                             error:&convertErr];
                    
                    return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
                }];
                
                currentUser.userName = @"updateUserName";
                // 2.カレントユーザーが変更する
                [currentUser saveInBackgroundWithBlock:^(NSError *error) {
                    
                    NSError *error1 = nil;
                    NSString *str = [[NSString alloc] initWithContentsOfFile:DATA_CURRENTUSER_PATH encoding:NSUTF8StringEncoding error:&error];
                    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                    NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
                    
                    if ([data isKindOfClass:[NSData class]] && [data length] != 0){
                        dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error1];
                    }
                    // 3.変更したデータをローカルに保存があります
                    expect([dicData objectForKey:@"userName"]).equal(currentUser.userName);
                    
                    done();
                }];
            }];
        });
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
