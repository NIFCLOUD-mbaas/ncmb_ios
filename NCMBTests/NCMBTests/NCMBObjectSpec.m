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
#import "NCMBObject.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface NCMBObject (Private)
- (void)saveCommandToFile:(NSDictionary*)localDic error:(NSError**)error;
+ (id)convertClass:(NSMutableDictionary*)result
     ncmbClassName:(NSString*)ncmbClassName;
@end

#define COMMAND_CACHE_FOLDER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/Command Cache/", DATA_MAIN_PATH]

SpecBegin(NCMBObject)

describe(@"NCMBObject", ^{

    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";

    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });
    
    beforeEach(^{
        
    });
    
    it(@"Should be allkeys method contained objectId, createDate and updateDate", ^{
        
        NSDictionary *jsonObj = @{
                                  @"createDate" : @{
                                          @"__type" : @"Date",
                                          @"iso" : @"2016-12-02T00:59:30.381Z"
                                          },
                                  @"acl" : @{
                                          @"*" : @{
                                                  @"write" : @true,
                                                  @"read" : @true
                                                  }
                                          },
                                  @"objectId" : @"gbexonT5DAshDGMj",
                                  @"key" : @"value",
                                  @"updateDate" : @{
                                          @"__type" : @"Date",
                                          @"iso" : @"2016-12-02T00:59:30.381Z"
                                          }
                                  };
        
        NCMBObject *object = [NCMBObject convertClass:[NSMutableDictionary dictionaryWithDictionary:jsonObj] ncmbClassName:@"test"];
        
        NSArray *allKeys = [object allKeys];
        
        expect([allKeys containsObject:@"objectId"]).to.beTruthy();
        expect([allKeys containsObject:@"createDate"]).to.beTruthy();
        expect([allKeys containsObject:@"updateDate"]).to.beTruthy();
    });

    it(@"should save command to file with the file path of date string of specification format", ^{

        id dateMock = OCMClassMock([NSDate class]);
        NSString *mockTimeStamp = @"1494925200"; //2017-05-16 09:00:00 in UTC
        OCMStub([dateMock date]).andReturn([NSDate dateWithTimeIntervalSince1970:[mockTimeStamp intValue]]);

        NSDictionary *saveDic = @{
                                  @"method":@"POST",
                                  @"path":@"classes/test",
                                  @"saveData":@{
                                          @"key":@"value"
                                          }
                                  };
        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];

        NSError *error = nil;
        [object saveCommandToFile:saveDic error:&error]; // DateFormat @"yyyyMMddHHmmssSSSS"

        // get local file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath: COMMAND_CACHE_FOLDER_PATH
                                                             error: NULL];

        NSString *filePath = [NSString stringWithFormat:@"%@%@", COMMAND_CACHE_FOLDER_PATH, [contents firstObject]];

        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *dictForEventually = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        expect(saveDic).to.equal(dictForEventually);
        NSString *pathString = [[contents firstObject] substringWithRange:NSMakeRange(0,18)];
        expect(pathString).equal(@"201705160900000000");

        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", COMMAND_CACHE_FOLDER_PATH, [contents firstObject]] error:nil];
    });


    it(@"saveInBackgroundWithBlock system test", ^{
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
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            [object setObject:@"value" forKey:@"key"];
            [object saveInBackgroundWithBlock:^(NSError *error) {
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

        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
        [object setObject:@"value" forKey:@"key"];
        NSError *error = nil;
        [object save:&error];
        expect(error).beNil();
        expect(object.objectId).to.equal(@"U6TztFwTDrGSD88N");
        expect([object objectForKey:@"key"]).to.equal(@"value");
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


        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
        [object setObject:@"value" forKey:@"key"];
        NSError *error = nil;
        [object save:&error];
        expect(error).beTruthy();
        expect(error.code).to.equal(@403001);
        expect([error localizedDescription]).to.equal(@"No access with ACL.");
    });

    it(@"fetchInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"7FrmPTBKSNtVjajm",
                                       @"createDate" : @"2014-06-03T11:28:30.348Z",
                                       @"updateDate" : @"2014-06-03T11:28:30.348Z",
                                       @"key" : @"value",
                                       @"acl" : @{@"*":@{@"read":@true,@"write":@true}}} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            object.objectId = @"7FrmPTBKSNtVjajm";
            [object fetchInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect(object.objectId).to.equal(@"7FrmPTBKSNtVjajm");
                expect([object objectForKey:@"key"]).to.equal(@"value");
                done();
            }];
        });
    });

    it(@"fetchInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            object.objectId = @"7FrmPTBKSNtVjajm";
            [object fetchInBackgroundWithBlock:^(NSError *error) {
                expect(error).beTruthy();
                expect(error.code).to.equal(@403001);
                expect([error localizedDescription]).to.equal(@"No access with ACL.");
                done();
            }];
        });
    });

    it(@"fetch system test", ^{
        NSDictionary *responseDic = @{ @"objectId" : @"7FrmPTBKSNtVjajm",
                                       @"createDate" : @"2014-06-03T11:28:30.348Z",
                                       @"updateDate" : @"2014-06-03T11:28:30.348Z",
                                       @"key" : @"value",
                                       @"acl" : @{@"*":@{@"read":@true,@"write":@true}}} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
        object.objectId = @"7FrmPTBKSNtVjajm";
        NSError *error = nil;
        [object fetch:&error];
        expect(error).beNil();
        expect(object.objectId).to.equal(@"7FrmPTBKSNtVjajm");
        expect([object objectForKey:@"key"]).to.equal(@"value");
    });

    it(@"fetch error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];


        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
        object.objectId = @"7FrmPTBKSNtVjajm";
        NSError *error = nil;
        [object fetch:&error];
        expect(error).beTruthy();
        expect(error.code).to.equal(@403001);
        expect([error localizedDescription]).to.equal(@"No access with ACL.");
    });

    it(@"deleteInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{} ;
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            object.objectId = @"7FrmPTBKSNtVjajm";
            [object deleteInBackgroundWithBlock:^(NSError *error) {
                expect(error).beNil();
                expect(object.objectId).beNil();
                expect([object objectForKey:@"key"]).beNil;
                done();
            }];
        });
    });

    it(@"deleteInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
            object.objectId = @"7FrmPTBKSNtVjajm";
            [object deleteInBackgroundWithBlock:^(NSError *error) {
                expect(error).beTruthy();
                expect(object.objectId).beTruthy();
                expect(error.code).to.equal(@403001);
                expect([error localizedDescription]).to.equal(@"No access with ACL.");
                done();
            }];
        });
    });

    it(@"delete system test", ^{
        NSDictionary *responseDic = @{} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
        object.objectId = @"7FrmPTBKSNtVjajm";
        NSError *error = nil;
        [object delete:&error];
        expect(error).beNil();
        expect(object.objectId).beNil();
        expect([object objectForKey:@"key"]).beNil;
    });

    it(@"delete error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E403001",
                                       @"error" : @"No access with ACL."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];


        NCMBObject *object = [NCMBObject objectWithClassName:@"test"];
        object.objectId = @"7FrmPTBKSNtVjajm";
        NSError *error = nil;
        [object delete:&error];
        expect(error).beTruthy();
        expect(object.objectId).beTruthy();
        expect(error.code).to.equal(@403001);
        expect([error localizedDescription]).to.equal(@"No access with ACL.");
    });

});

afterEach(^{

});

afterAll(^{
  
});

SpecEnd
