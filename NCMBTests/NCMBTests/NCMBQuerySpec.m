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
#import <NCMB/NCMB.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "NCMBURLConnection.h"

@interface NCMBQuery (Private)
@property (nonatomic) NCMBURLConnection *connection;
@property (nonatomic) NSMutableDictionary *query;
- (NCMBURLConnection*)createConnectionForSearch:(NSMutableDictionary*)queryDic countEnableFlag:(BOOL)countEnableFlag getFirst:(BOOL)getFirstFlag;
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

        NCMBQuery *query = [NCMBRole query];
        NCMBQuery *queryMock = OCMPartialMock(query);
        
        NCMBURLConnection * connectionMock = OCMPartialMock([queryMock createConnectionForSearch:query.query countEnableFlag:NO getFirst:YES]);
        
        queryMock.connection = connectionMock;

        OCMStub([queryMock createConnectionForSearch:OCMOCK_ANY countEnableFlag:NO getFirst:YES]).andReturn(connectionMock);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void (^block) (id response, NSError *error);
            [invocation getArgument:&block atIndex:2];
            NSDictionary *responseDic = @{@"results":@[
                                                  @{@"objectId":@"objectId1",
                                                    @"createDate":@"2016-06-17T05:55:17.778Z"},
                                                  @{@"objectId":@"objectId2",
                                                    @"createDate":@"2016-06-18T05:55:17.778Z"},
                                                  ]
                                          };
            block(responseDic,nil);
        };
        
        OCMStub([connectionMock asyncConnectionWithBlock:OCMOCK_ANY]).andDo(invocation);
        
        [queryMock getFirstObjectInBackgroundWithBlock:^(id object, NSError *error) {
            expect(error).beNil();
            if (!error){
                expect([object class]).to.equal([NCMBRole class]);
            }
        }];
        
    });
    
    it(@"should create date formatter with a specification format", ^{
        
        NCMBQuery *query = [NCMBQuery queryWithClassName:@"test"];
        NSDateFormatter *dateFormatter = [query createNCMBDateFormatter]; // DateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        NSString *timeStamp = @"1494925200"; //2017-05-16 09:00:00 in UTC
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[timeStamp intValue]]];
        
        expect(dateStr).notTo.beNil();
        expect(dateStr).equal(@"2017-05-16T09:00:00.000Z");
        
    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
