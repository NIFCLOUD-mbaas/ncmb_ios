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
#import "NCMBURLSession.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface NCMBQuery (Private)
@property (nonatomic) NSMutableDictionary *query;

- (void)setCondition:(id)object forKey:(NSString*)key operand:(NSString*)operand;

-(NSDateFormatter*)createNCMBDateFormatter;
@end

SpecBegin(NCMBQuery)

describe(@"NCMBQuery", ^{

    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";

    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];

    });

    beforeEach(^{

    });

    it(@"should get first object in background call back any object", ^{
        NSDictionary *responseDic = @{ @"results" : @[ @{ @"objectId" : @"objectId1",
                                                          @"createDate" : @"2016-06-17T05:55:17.778Z"},
                                                       @{ @"objectId" : @"objectId2",
                                                          @"createDate" : @"2016-06-18T05:55:17.778Z"} ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:200 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBRole query];
            [query getFirstObjectInBackgroundWithBlock:^(id object, NSError *error) {
                expect(error).beNil();
                if (!error){
                    expect([object class]).to.equal([NCMBRole class]);
                }
                done();
            }];
        });


    });

    it(@"should work normally in ContainedIn method", ^{

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"test"];
        NCMBQuery *query2 = [NCMBQuery queryWithClassName:@"test"];

        [query whereKey:@"key" containedInArrayTo:@[@"value"]];
        [query2 setCondition:@[@"value"] forKey:@"key" operand:@"$inArray"];

        [query whereKey:@"key" notContainedInArrayTo:@[@"value"]];
        [query2 setCondition:@[@"value"] forKey:@"key" operand:@"$ninArray"];

        [query whereKey:@"key" containsAllObjectsInArrayTo:@[@"value"]];
        [query2 setCondition:@[@"value"] forKey:@"key" operand:@"$all"];

        expect(query.query).to.equal(query2.query);

    });

    it(@"should create date formatter with a specification format", ^{

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"test"];
        NSDateFormatter *dateFormatter = [query createNCMBDateFormatter]; // DateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        NSString *timeStamp = @"1494925200"; //2017-05-16 09:00:00 in UTC
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[timeStamp intValue]]];

        expect(dateStr).notTo.beNil();
        expect(dateStr).equal(@"2017-05-16T09:00:00.000Z");

    });

    it(@"findObjectsInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{ @"results":@[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" },
                                               @{ @"objectId" : @"wMhDqUcnIam6QoaJ",
                                                  @"createDate" : @"2013-08-09T07:40:55.108Z",
                                                  @"updateDate" : @"2013-08-09T07:40:55.108Z",
                                                  @"key" : @"obj2" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                expect(error).beNil();
                expect(objects.count).to.equal(2);
                NCMBObject *object = objects[0];
                expect(object.objectId).to.equal(@"8FgKqFlH8dZRDrBJ");
                expect([object objectForKey:@"key"]).to.equal(@"obj1");
                done();
            }];
        });
    });

    it(@"findObjectsInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                expect(objects.count).to.equal(0);
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"findObjects system test", ^{
        NSDictionary *responseDic = @{ @"results":@[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" },
                                               @{ @"objectId" : @"wMhDqUcnIam6QoaJ",
                                                  @"createDate" : @"2013-08-09T07:40:55.108Z",
                                                  @"updateDate" : @"2013-08-09T07:40:55.108Z",
                                                  @"key" : @"obj2" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NSArray *objects = [query findObjects:&error];
        expect(error).beNil();
        expect(objects.count).to.equal(2);
        NCMBObject *object = objects[0];
        expect(object.objectId).to.equal(@"8FgKqFlH8dZRDrBJ");
        expect([object objectForKey:@"key"]).to.equal(@"obj1");
    });

    it(@"findObjects error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NSArray *objects = [query findObjects:&error];
        expect(objects.count).to.equal(0);
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    it(@"getFirstObjectInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{ @"results":@[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query getFirstObjectInBackgroundWithBlock:^(id object, NSError *error) {
                expect(error).beNil();
                expect(((NCMBObject*)object).objectId).to.equal(@"8FgKqFlH8dZRDrBJ");
                expect([(NCMBObject*)object objectForKey:@"key"]).to.equal(@"obj1");
                done();
            }];
        });
    });

    it(@"getFirstObjectInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query getFirstObjectInBackgroundWithBlock:^(id object, NSError *error) {
                expect(object).beNil();
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"getFirstObject system test", ^{
        NSDictionary *responseDic = @{ @"results":@[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NCMBObject *object = (NCMBObject *)[query getFirstObject:&error];
        expect(error).beNil();
        expect(object.objectId).to.equal(@"8FgKqFlH8dZRDrBJ");
        expect([object objectForKey:@"key"]).to.equal(@"obj1");
    });

    it(@"getFirstObject error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NCMBObject *object = (NCMBObject *)[query getFirstObject:&error];
        expect(object).beNil();
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    it(@"getObjectInBackgroundWithId system test", ^{
        NSDictionary *responseDic = @{ @"results":@[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query getObjectInBackgroundWithId:@"8FgKqFlH8dZRDrBJ" block:^(NCMBObject *object, NSError *error) {
                expect(error).beNil();
                expect(object.objectId).to.equal(@"8FgKqFlH8dZRDrBJ");
                expect([object objectForKey:@"key"]).to.equal(@"obj1");
                done();
            }];

        });
    });

    it(@"getObjectInBackgroundWithId error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query getObjectInBackgroundWithId:@"8FgKqFlH8dZRDrBJ" block:^(NCMBObject *object, NSError *error) {
                expect(object).beNil();
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"getObjectWithId system test", ^{
        NSDictionary *responseDic = @{ @"results":@[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NCMBObject *object = [query getObjectWithId:@"8FgKqFlH8dZRDrBJ" error:&error];
        expect(error).beNil();
        expect(object.objectId).to.equal(@"8FgKqFlH8dZRDrBJ");
        expect([object objectForKey:@"key"]).to.equal(@"obj1");
    });

    it(@"getObjectWithId error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NCMBObject *object = [query getObjectWithId:@"8FgKqFlH8dZRDrBJ" error:&error];
        expect(object).beNil();
        expect(error).beTruthy();
        expect(error.code).to.equal(@400000);
        expect([error localizedDescription]).to.equal(@"Bad Request.");
    });

    it(@"countObjectsInBackgroundWithBlock system test", ^{
        NSDictionary *responseDic = @{ @"count" : @1,
                                       @"results": @[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                expect(error).beNil();
                expect(number).to.equal(@1);
                done();
            }];


        });
    });

    it(@"countObjectsInBackgroundWithBlock error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        waitUntil(^(DoneCallback done) {
            NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
            [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                expect(number).to.equal(0);
                expect(error).beTruthy();
                expect(error.code).to.equal(@400000);
                expect([error localizedDescription]).to.equal(@"Bad Request.");
                done();
            }];
        });
    });

    it(@"countObjects system test", ^{
        NSDictionary *responseDic = @{ @"count" : @1,
                                       @"results": @[
                                               @{ @"objectId" : @"8FgKqFlH8dZRDrBJ",
                                                  @"createDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"updateDate" : @"2013-08-09T07:37:54.869Z",
                                                  @"key" : @"obj1" }
                                               ]};

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:201 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NSInteger number = [query countObjects:&error];
        expect(error).beNil();
        expect(number).to.equal(@1);
    });

    it(@"countObjects error test", ^{
        NSDictionary *responseDic = @{ @"code" : @"E400000",
                                       @"error" : @"Bad Request."} ;

        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.host isEqualToString:@"mbaas.api.nifcloud.com"];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:responseData statusCode:403 headers:@{@"Content-Type":@"application/json;charset=UTF-8"}];
        }];

        NCMBQuery *query = [NCMBQuery queryWithClassName:@"Post"];
        NSError *error = nil;
        NSInteger number = [query countObjects:&error];
        expect(number).to.equal(0);
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
