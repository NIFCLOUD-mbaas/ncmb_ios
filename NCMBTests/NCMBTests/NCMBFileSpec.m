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
#import <NCMB/NCMB.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface NCMBFile (Private)
+(NSString*) getTimeStamp;
@end

SpecBegin(NCMBFile)

describe(@"NCMBFile", ^{

    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";

    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });

    beforeEach(^{

    });

    it(@"should get time stamp with a string of specification format", ^{
        id dateMock = OCMClassMock([NSDate class]);
        NSString *mockTimeStamp = @"1494925200"; //2017-05-16 09:00:00 in UTC
        OCMStub([dateMock date]).andReturn([NSDate dateWithTimeIntervalSince1970:[mockTimeStamp intValue]]);

        NSString *timeStamp = [NCMBFile getTimeStamp]; //DateFormat @"yyyyMMddHHmmssSSSS"

        expect(timeStamp).notTo.beNil();
        expect(timeStamp).equal(@"201705160900000000");
    });

    it(@"data should be nil if response of getDataInBackgroundWithBlock is error", ^{

        NCMBFile *fileData = [NCMBFile fileWithName:@"test.png" data:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            NSDictionary *responseDic = @{
                                          @"code" : @"E404001",
                                          @"error" : @"No data available."
                                          };

            NSError *convertErr = nil;
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic
                                                                   options:0
                                                                     error:&convertErr];

            return [OHHTTPStubsResponse responseWithData:responseData statusCode:404 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            [fileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                expect(data).beNil();
                expect(error).beTruthy();
                done();
            }];
        });
    });

    it(@"data should not be nil if response of getDataInBackgroundWithBlock is successful", ^{

        NSData *responseData = [@"NIF Cloud mobile backend" dataUsingEncoding:NSUTF8StringEncoding];

        NCMBFile *fileData = [NCMBFile fileWithName:@"ncmb.txt" data:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"text/plain;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            [fileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                expect(data).beTruthy();
                expect(data).equal(responseData);
                expect(error).beNil();
                done();
            }];
        });
    });

    it(@"getData system test", ^{
        NSData *responseData = [@"NIF Cloud mobile backend" dataUsingEncoding:NSUTF8StringEncoding];


        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"text/plain;charset=UTF-8"}];
        }];

        NCMBFile *file = [NCMBFile fileWithName:@"ncmb.txt" data:nil];
        NSError *error = nil;
        NSData *data = [file getData:&error];
        expect(error).beNil();
        expect(data).beTruthy();
        expect(data).to.equal(responseData);
    });

    it(@"getData error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];


        NCMBFile *file = [NCMBFile fileWithName:@"ncmb.txt" data:nil];
        NSError *error = nil;
        NSData *data = [file getData:&error];
        expect(data).beNil();
        expect(error).beTruthy();
        expect(error.code).to.equal(@403001);
        expect([error localizedDescription]).to.equal(@"No access with ACL.");
    });

    it(@"saveInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{ @"fileName" : @"ncmb.txt",
                                       @"createDate" : @"2013-08-28T03:02:29.970Z"} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NSData *fileData = [@"NIF Cloud mobile backend" dataUsingEncoding:NSUTF8StringEncoding];
            NCMBFile *file = [NCMBFile fileWithName:@"ncmb.txt" data:fileData];
            [file saveInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect(file.name).to.equal(@"ncmb.txt");
                done();
            }];
        });
    });

    it(@"saveInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NSData *fileData = [@"NIF Cloud mobile backend" dataUsingEncoding:NSUTF8StringEncoding];
            NCMBFile *file = [NCMBFile fileWithName:@"ncmb.txt" data:fileData];
            [file saveInBackgroundWithBlock:^(NSError *error) {
                expect(error).beTruthy();
                expect(error.code).to.equal(@403001);
                expect([error localizedDescription]).to.equal(@"No access with ACL.");
                done();
            }];
        });
    });

    it(@"save system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"U6TztFwTDrGSD88N",
                                       @"createDate" : @"2013-08-28T03:02:29.970Z"} ;
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSData *fileData = [@"NIF Cloud mobile backend" dataUsingEncoding:NSUTF8StringEncoding];
        NCMBFile *file = [NCMBFile fileWithName:@"ncmb.txt" data:fileData];
        NSError *error = nil;
        [file save:&error];
        expect(error).beNil();
        expect(file.name).to.equal(@"ncmb.txt");
    });

    it(@"save error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NSData *fileData = [@"NIF Cloud mobile backend" dataUsingEncoding:NSUTF8StringEncoding];
        NCMBFile *file = [NCMBFile fileWithName:@"ncmb.txt" data:fileData];
        NSError *error = nil;
        [file save:&error];
        expect(error).beTruthy();
        expect(error.code).to.equal(@403001);
        expect([error localizedDescription]).to.equal(@"No access with ACL.");
    });

    afterEach(^{

    });

    afterAll(^{

    });
});

SpecEnd
