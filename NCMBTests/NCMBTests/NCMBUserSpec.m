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

#import "Specta.h"
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <NCMB/NCMB.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/NSURLRequest+HTTPBodyTesting.h>

@interface NCMBUser (Private)
-(void)afterSave:(NSDictionary*)response operations:(NSMutableDictionary *)operations;
-(NSMutableDictionary *)beforeConnection;
@end

#define DATA_CURRENTUSER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentUser", DATA_MAIN_PATH]

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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
    
    it(@"should be able to create local currentUser file when afterSave", ^{
        
        // remove currentUserFile
        [[NSFileManager defaultManager] removeItemAtPath:DATA_CURRENTUSER_PATH error:nil];
        
        BOOL isCurrentUserFileExist = [[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTUSER_PATH isDirectory:nil];
        expect(isCurrentUserFileExist).to.beFalsy();
        
        NSDictionary *responseDic = @{
                                      @"authData" : [NSNull null],
                                      @"createDate" : @"2017-06-08T02:14:19.058Z",
                                      @"objectId" : @"VzBhKhtYoDC1Y4X5",
                                      @"sessionToken" : @"oL663jk7H4D4wTsGfhKF8Ktog",
                                      @"userName" : @"user1"
                                      };
        
        NCMBUser *user = [NCMBUser user];
        user.userName = @"user1";
        user.password = @"pass";
        
        NSMutableDictionary *operation = [user beforeConnection];
        
        [user afterSave:responseDic operations:operation];
        
        isCurrentUserFileExist = [[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTUSER_PATH isDirectory:nil];
        expect(isCurrentUserFileExist).to.beTruthy();
        
    });

    it(@"after logged in should not change current user when update another user", ^{

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
                    return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
                    return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
                    return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
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
    
    it(@"should reset operationSetQueue after fetch", ^{

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            NSMutableDictionary *responseDic = [@{@"createDate" : @"2014-06-03T11:28:30.348Z",
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
                NCMBUser *currentUser = NCMBUser.currentUser;
                expect(currentUser).notTo.beNil();

                NSDictionary *responseDic = @{ @"objectId" : @"e4YWYnYtcptTIV23",
                                               @"userName" : @"admin",
                                               @"mailAddress" : @"your.mailaddress@example.com",
                                               @"createDate" : @"2014-06-03T11:28:30.348Z",
                                               @"updateDate" : @"2014-06-03T11:28:30.348Z",
                                               @"acl" : @{@"*":@{@"read":@true,@"write":@true}}} ;

                NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

                [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                    return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
                } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                    return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
                }];

                currentUser = [NCMBUser currentUser];
                // 2. fetchInBackgroundWithBlock
                [currentUser fetchInBackgroundWithBlock:^(NSError *error) {
                    expect(error).beNil();
                    expect(currentUser.objectId).to.equal(@"e4YWYnYtcptTIV23");
                    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                        return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
                    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
                        NSData* body = request.OHHTTPStubs_HTTPBody;
                        NSString* bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                        
                        if (!([request.HTTPMethod isEqualToString:@"PUT"] && [bodyString isEqualToString:@"{\"userName\":\"updateUserName\"}"])) {
                            NSDictionary *responseDicError = @{ @"code" : @"E403001",
                                                           @"error" : @"Wrong body params."} ;
                            NSData *responseDataError = [NSJSONSerialization dataWithJSONObject:responseDicError options:NSJSONWritingPrettyPrinted error:nil];
                            return [OHHTTPStubsResponse responseWithData:responseDataError statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
                        }

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
                    // 3.カレントユーザーが変更する
                    [currentUser saveInBackgroundWithBlock:^(NSError *error) {
                        expect(error).beNil();
                        done();
                    }];
                }];

            }];
        });
    });

    it(@"signUpInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"epaKcaYZqsREdSMY",
                                       @"sessionToken" : @"iXDIelJRY3ULBdms281VTmc5O",
                                       @"userName" : @"NCMBUser",
                                       @"createDate" : @"2013-08-28T11:27:16.446Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBUser *user = [NCMBUser user];
            user.userName = @"NCMBUser";
            user.password = @"password";
            [user setObject:@"value" forKey:@"key"];
            [user signUpInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                NCMBUser *currentUser = NCMBUser.currentUser;
                expect(currentUser.objectId).to.equal(@"epaKcaYZqsREdSMY");
                expect(currentUser.sessionToken).to.equal(@"iXDIelJRY3ULBdms281VTmc5O");
                expect(currentUser.userName).to.equal(@"NCMBUser");
                expect([currentUser objectForKey:@"key"]).to.equal(@"value");
                done();
            }];
        });
    });

    it(@"signUpInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBUser *user = [NCMBUser user];
            user.userName = @"NCMBUser";
            user.password = @"password";
            [user setObject:@"value" forKey:@"key"];
            [user signUpInBackgroundWithBlock:^(NSError *error) {
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"signUp system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"epaKcaYZqsREdSMY",
                                       @"sessionToken" : @"iXDIelJRY3ULBdms281VTmc5O",
                                       @"userName" : @"NCMBUser",
                                       @"createDate" : @"2013-08-28T11:27:16.446Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBUser *user = [NCMBUser user];
        user.userName = @"NCMBUser";
        user.password = @"password";
        [user setObject:@"value" forKey:@"key"];
        NSError *error = nil;
        [user signUp:&error];
        expect(error).beNil();
        NCMBUser *currentUser = NCMBUser.currentUser;
        expect(currentUser.objectId).to.equal(@"epaKcaYZqsREdSMY");
        expect(currentUser.sessionToken).to.equal(@"iXDIelJRY3ULBdms281VTmc5O");
        expect(currentUser.userName).to.equal(@"NCMBUser");
        expect([currentUser objectForKey:@"key"]).to.equal(@"value");
    });

    it(@"signUp error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];


        NCMBUser *user = [NCMBUser user];
        user.userName = @"NCMBUser";
        user.password = @"password";
        [user setObject:@"value" forKey:@"key"];
        NSError *error = nil;
        [user save:&error];
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    it(@"logInWithUsernameInBackground system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"09Mp23m4bEOInUqT",
                                       @"mailAddress" : [NSNull null],
                                       @"mailAddressConfirm" : [NSNull null],
                                       @"sessionToken" : @"iXDIelJRY3ULBdms281VTmc5O",
                                       @"updateDate" : @"2013-08-30T05:32:03.868Z",
                                       @"userName" : @"NCMBUser",
                                       @"key":@"value",
                                       @"createDate" : @"2013-08-28T07:46:09.801Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser logInWithUsernameInBackground:@"NCMBUser" password:@"password" block:^(NCMBUser *user, NSError *error) {
                expect(error).beNil();
                expect(user.objectId).to.equal(@"09Mp23m4bEOInUqT");
                expect(user.sessionToken).to.equal(@"iXDIelJRY3ULBdms281VTmc5O");
                expect(user.userName).to.equal(@"NCMBUser");
                expect([user objectForKey:@"key"]).to.equal(@"value");

                NCMBUser *currentUser = NCMBUser.currentUser;
                expect(currentUser.objectId).to.equal(@"09Mp23m4bEOInUqT");
                expect(currentUser.sessionToken).to.equal(@"iXDIelJRY3ULBdms281VTmc5O");
                expect(currentUser.userName).to.equal(@"NCMBUser");
                expect([currentUser objectForKey:@"key"]).to.equal(@"value");
                done();
            }];
        });
    });

    it(@"logInWithUsernameInBackground error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser logInWithUsernameInBackground:@"NCMBUser" password:@"password" block:^(NCMBUser *user, NSError *error) {
                expect(user).beNil();
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"logInWithUsername system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"09Mp23m4bEOInUqT",
                                       @"mailAddress" : [NSNull null],
                                       @"mailAddressConfirm" : [NSNull null],
                                       @"sessionToken" : @"iXDIelJRY3ULBdms281VTmc5O",
                                       @"updateDate" : @"2013-08-30T05:32:03.868Z",
                                       @"userName" : @"NCMBUser",
                                       @"key" : @"value",
                                       @"createDate" : @"2013-08-28T07:46:09.801Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSError *error = nil;
        NCMBUser *user = [NCMBUser logInWithUsername:@"NCMBUser" password:@"password" error:&error];
        expect(error).beNil();
        expect(user.objectId).to.equal(@"09Mp23m4bEOInUqT");
        expect(user.sessionToken).to.equal(@"iXDIelJRY3ULBdms281VTmc5O");
        expect(user.userName).to.equal(@"NCMBUser");
        expect([user objectForKey:@"key"]).to.equal(@"value");

        NCMBUser *currentUser = NCMBUser.currentUser;
        expect(currentUser.objectId).to.equal(@"09Mp23m4bEOInUqT");
        expect(currentUser.sessionToken).to.equal(@"iXDIelJRY3ULBdms281VTmc5O");
        expect(currentUser.userName).to.equal(@"NCMBUser");
        expect([currentUser objectForKey:@"key"]).to.equal(@"value");

    });

    it(@"logInWithUsername error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSError *error = nil;
        NCMBUser *user = [NCMBUser logInWithUsername:@"NCMBUser" password:@"password" error:&error];
        expect(user).beNil();
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    it(@"logOutInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser logOutInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                NCMBUser *user = NCMBUser.currentUser;
                expect(user.objectId).beNil();
                expect(user.sessionToken).beNil();
                expect(user.userName).beNil();
                done();
            }];
        });
    });

    it(@"logOutInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser logOutInBackgroundWithBlock:^( NSError *error) {
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");

                NCMBUser *user = NCMBUser.currentUser;
                expect(user.objectId).beNil();
                expect(user.sessionToken).beNil();
                expect(user.userName).beNil();
                done();
            }];
        });
    });

    it(@"requestAuthenticationMailInBackground system test", ^{
        NSDictionary *responseDic = @{ @"createDate" : @"2013-09-04T04:31:43.371Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser requestAuthenticationMailInBackground:@"your.mailaddress@example.com" block:^(NSError *error) {
                expect(error).beNil();
                done();
            }];
        });
    });

    it(@"requestAuthenticationMailInBackground error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser requestAuthenticationMailInBackground:@"your.mailaddress@example.com" block:^(NSError *error) {
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"requestAuthenticationMail system test", ^{
        NSDictionary *responseDic = @{ @"createDate" : @"2013-09-04T04:31:43.371Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSError *error = nil;
        [NCMBUser requestAuthenticationMail:@"your.mailaddress@example.com" error:&error];
        expect(error).beNil();
    });

    it(@"requestAuthenticationMail error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSError *error = nil;
        [NCMBUser requestAuthenticationMail:@"your.mailaddress@example.com" error:&error];
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    it(@"requestPasswordResetForEmailInBackground system test", ^{
        NSDictionary *responseDic = @{ @"createDate" : @"2013-09-04T04:31:43.371Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser requestPasswordResetForEmailInBackground:@"your.mailaddress@example.com" block:^(NSError *error) {
                expect(error).beNil();
                done();
            }];
        });
    });

    it(@"requestPasswordResetForEmailInBackground error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            [NCMBUser requestPasswordResetForEmailInBackground:@"your.mailaddress@example.com" block:^(NSError *error) {
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"requestPasswordResetForEmail system test", ^{
        NSDictionary *responseDic = @{ @"createDate" : @"2013-09-04T04:31:43.371Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSError *error = nil;
        [NCMBUser requestPasswordResetForEmail:@"your.mailaddress@example.com" error:&error];
        expect(error).beNil();
    });

    it(@"requestPasswordResetForEmail error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSError *error = nil;
        [NCMBUser requestPasswordResetForEmail:@"your.mailaddress@example.com" error:&error];
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    afterEach(^{

    });

    afterAll(^{

    });
});

SpecEnd
