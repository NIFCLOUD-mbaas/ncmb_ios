//
//  CoreTest.m
//  CoreTest
//
//  Created by 大川雄生 on 2015/07/15.
//  Copyright (c) 2015年 NIFTY Corporation. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(StubTest)

beforeAll(^{
    
    NSDictionary *responseDic = @{@"key":@"value"};
    NSData *jsonResponse = [NSJSONSerialization dataWithJSONObject:responseDic options:0 error:nil];
    
    //CreateStub
    // Objective-C
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"https://example.com/2013-09-01/classes/Test"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:jsonResponse
                                          statusCode:200
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
});

describe(@"OHHTTPStubs", ^{
    it(@"should return stub response", ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com/2013-09-01/classes/Test"]];
        NSHTTPURLResponse *response = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        expect([NSJSONSerialization JSONObjectWithData:responseData
                                               options:NSJSONReadingAllowFragments
                                                 error:nil]
               ).to.equal(@{@"key":@"value"});
    });
});

afterAll(^{
    [OHHTTPStubs removeAllStubs];
});

SpecEnd
