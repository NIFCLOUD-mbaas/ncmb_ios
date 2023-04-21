/*
 Copyright 2017-2023 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.

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

SpecBegin(NCMBAnonymous)
#define DATA_MAIN_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"]
#define DATA_CURRENTUSER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentUser", DATA_MAIN_PATH]

describe(@"NCMBAnonymous", ^{

    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";
    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });

    beforeEach(^{
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            NSMutableDictionary *responseDic = [@{@"createDate" : @"2014-06-03T11:28:30.348Z",
                                                  @"objectId" : @"aTAe6VXd3ZElDtlG",
                                                  @"userName" : @"ljmuJgf4ri",
                                                  @"authData" : @{@"anonymous": @{ @"id" : @"3dc72085-911b-4798-9707-d69e879a6185"}},
                                                  @"sessionToken" : @"esMM7OVu4PlK5spYNLLrR15io"
                                                  } mutableCopy];

            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            
            [NCMBAnonymousUtils logInWithBlock:^(NCMBUser *user, NSError *error) {
                done();
            }];
            
        });
    });

    it(@"update current user test", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            NSMutableDictionary *responseDic = [@{@"createDate" : @"2014-06-03T11:28:30.348Z",
                                                @"objectId" : @"aTAe6VXd3ZElDtlG",
                                                @"userName" : @"updateUserName",
                                                @"authData" : @{@"anonymous": @{ @"id" : @"3dc72085-911b-4798-9707-d69e879a6185"}},
                                                @"sessionToken" : @"esMM7OVu4PlK5spYNLLrR15io"
                                                } mutableCopy];

            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];

            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBUser *currentUser = NCMBUser.currentUser;
            expect(currentUser).notTo.beNil();
            currentUser.userName = @"updateUserName";

            [currentUser saveInBackgroundWithBlock:^(NSError *error) {
                NCMBUser *updateUser = [NCMBUser currentUser];
                expect(error).beNil();
                expect(updateUser).notTo.beNil();
                expect(updateUser.objectId).equal(@"aTAe6VXd3ZElDtlG");
                expect(updateUser.sessionToken).equal(@"esMM7OVu4PlK5spYNLLrR15io");
                expect(updateUser.userName).equal(@"updateUserName");
                done();
            }];
        });
    });
    
    it(@"create new user test", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            NSMutableDictionary *responseDic = [@{@"createDate" : @"2014-06-03T12:28:30.348Z",
                                                @"objectId" : @"aTAe6VXd3ZElD000",
                                                @"userName" : @"newUser",
                                                @"sessionToken" : @"AsMM7OVu4PlK5spYNLLrR15i1"
                                                } mutableCopy];

            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];

            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBUser *user = [[NCMBUser alloc]init];
            user.userName = @"newUser";

            [user signUpInBackgroundWithBlock:^(NSError *error) {
                NCMBUser *currentUser = [NCMBUser currentUser];
                expect(error).beNil();
                expect(currentUser).notTo.beNil();
                
                expect(currentUser.objectId).equal(@"aTAe6VXd3ZElDtlG");
                expect(currentUser.sessionToken).equal(@"esMM7OVu4PlK5spYNLLrR15io");
                expect(currentUser.userName).equal(@"ljmuJgf4ri");
                done();
            }];
        });
    });
    
    
    it(@"deleting current user test", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            NSDictionary *responseDic = @{} ;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBUser *currentUser = [NCMBUser currentUser];
            expect(currentUser).notTo.beNil();
            
            [currentUser deleteInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect([NCMBUser currentUser]).beNil();
                done();
            }];
        });
    });
    
    it(@"create object test", ^{
        
        NSDictionary *responseDic = @{ @"objectId" : @"U6TztFwTDrGSD88N",
                                       @"createDate" : @"2013-08-28T03:02:29.970Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            [object setObject:@"value" forKey:@"key"];
            [object saveInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect(object.objectId).to.equal(@"U6TztFwTDrGSD88N");
                expect([object objectForKey:@"key"]).to.equal(@"value");
                
                NCMBUser *currentUser = [NCMBUser currentUser];
                expect(currentUser.objectId).equal(@"aTAe6VXd3ZElDtlG");
                expect(currentUser.sessionToken).equal(@"esMM7OVu4PlK5spYNLLrR15io");
                expect(currentUser.userName).equal(@"ljmuJgf4ri");
                
                done();
            }];
        });
    });
    
    it(@"update object test", ^{
        NSDictionary *responseDic = @{ @"updateDate": @"2020-08-30T21:10:55.125Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            [object setObjectId:@"U6TztFwTDrGSD88N"];
            [object setObject:@"updated value" forKey:@"key"];
            [object saveInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect(object.objectId).to.equal(@"U6TztFwTDrGSD88N");
                expect([object objectForKey:@"key"]).to.equal(@"updated value");
                
                NCMBUser *currentUser = [NCMBUser currentUser];
                expect(currentUser.objectId).equal(@"aTAe6VXd3ZElDtlG");
                expect(currentUser.sessionToken).equal(@"esMM7OVu4PlK5spYNLLrR15io");
                expect(currentUser.userName).equal(@"ljmuJgf4ri");
                done();
            }];
        });
    });
    
    it(@"delete object test", ^{
        NSDictionary *responseDic = @{} ;
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            object.objectId = @"U6TztFwTDrGSD88N";
            [object deleteInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect(object.objectId).beNil();
                expect([object objectForKey:@"key"]).beNil;
                
                NCMBUser *currentUser = [NCMBUser currentUser];
                expect(currentUser.objectId).equal(@"aTAe6VXd3ZElDtlG");
                expect(currentUser.sessionToken).equal(@"esMM7OVu4PlK5spYNLLrR15io");
                expect(currentUser.userName).equal(@"ljmuJgf4ri");
                done();
            }];
        });

    });
         
    afterEach(^{
        
    });

    afterAll(^{

    });

});

SpecEnd
