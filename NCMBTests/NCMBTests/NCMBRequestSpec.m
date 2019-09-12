/*
 Copyright 2017-2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.

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

#import "NCMBURLSession.h"

SpecBegin(NCMBRequest)

describe(@"NCMBRequest", ^{

    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";
    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });

    beforeEach(^{

    });

    it(@"should set required HTTP request Headers", ^{

        NSString *urlStr = @"https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass?where=%7B%22testKey%22%3A%22testValue%22%7D";
        NSURL *url = [NSURL URLWithString:urlStr];

        NSString *expectTimeStamp = @"2013-12-02T02:44:35.452Z";
        id requestMock = OCMClassMock([NCMBRequest class]);
        OCMStub([requestMock returnTimeStamp]).andReturn(expectTimeStamp);

        NSString *expectSessionToken = @"testSessionToken";
        OCMStub([requestMock returnSessionToken]).andReturn(expectSessionToken);

        NCMBRequest *request = [[NCMBRequest alloc] initWithURL:url
                                                         method:@"GET"
                                                         header:nil
                                                       bodyData:nil];

        NSDictionary *headers = [request allHTTPHeaderFields];
        expect([headers objectForKey:@"X-NCMB-Application-Key"]).to.equal(applicationKey);

        NSString *expectSignature = @"AltGkQgXurEV7u0qMd+87ud7BKuueldoCjaMgVc9Bes=";
        expect([headers objectForKey:@"X-NCMB-Signature"]).to.equal(expectSignature);

        expect([headers objectForKey:@"X-NCMB-Timestamp"]).to.equal(expectTimeStamp);

        expect([headers objectForKey:@"X-NCMB-Apps-Session-Token"]).to.equal(expectSessionToken);

        expect([headers objectForKey:@"Content-Type"]).to.equal(@"application/json");
        
        expect([headers objectForKey:@"X-NCMB-SDK-Version"]).to.equal([NSString stringWithFormat:@"ios-%@", SDK_VERSION]);
        
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        expect([headers objectForKey:@"X-NCMB-OS-Version"]).to.equal([NSString stringWithFormat:@"ios-%@", osVersion]);


    });

    it(@"test PUT request body data empty", ^{

        NSString *urlStr = @"https://mbaas.api.nifcloud.com/2013-09-01/classes/TestClass/mockObjectId";
        NSURL *url = [NSURL URLWithString:urlStr];
        NCMBRequest *request = [[NCMBRequest alloc] initWithURL:url
                                                         method:@"PUT"
                                                         header:nil
                                                       bodyData:@{}.mutableCopy];
        NSData *bodyData = [request HTTPBody];
        expect(bodyData).to.equal(@{}.mutableCopy);
    });

    afterEach(^{

    });

    afterAll(^{

    });
});

SpecEnd
