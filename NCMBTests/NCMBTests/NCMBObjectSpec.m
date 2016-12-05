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
#import "NCMBObject.h"

@interface NCMBObject (Private)
+ (id)convertClass:(NSMutableDictionary*)result
     ncmbClassName:(NSString*)ncmbClassName;
@end


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
    
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
