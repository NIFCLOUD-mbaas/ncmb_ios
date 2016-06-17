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

@interface NCMBRole (Private)
@property (nonatomic) NCMBRelation *users;
@property (nonatomic) NCMBRelation *roles;
@end

SpecBegin(NCMBRole)

describe(@"NCMBRole", ^{

    beforeAll(^{
        
    });
    
    beforeEach(^{

    });
    
    it(@"should create new relations if belong user was NSArray", ^{
        
        NCMBUser *user = [NCMBUser user];
        user.userName = @"freeUser";
        user.password = @"pass";
        user.objectId = @"aaaaaaaa";
        
        NCMBRole *role = [NCMBRole roleWithName:@"freePlan"];
        role.users = (NCMBRelation *)[NSArray new];
        
        [role addUser:user];
        
        expect([role.users class]).to.equal([NCMBRelation class]);
        
    });

    it(@"should create new relations if belong role was NSArray", ^{
        
        NCMBRole *administrators = [NCMBRole roleWithName:@"Administrators"];
        administrators.objectId = @"aaaaaaaa";
        
        NCMBRole *moderators = [NCMBRole roleWithName:@"Moderators"];
        moderators.roles = (NCMBRelation *)[NSArray new];
        
        [moderators addRole:administrators];
        
        expect([moderators.roles class]).to.equal([NCMBRelation class]);
        
    });
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
