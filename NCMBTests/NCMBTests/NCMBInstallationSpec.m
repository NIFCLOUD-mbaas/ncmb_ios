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

@interface NCMBInstallation (Private)
- (void)afterFetch:(NSMutableDictionary*)response isRefresh:(BOOL)isRefresh;
-(void)afterSave:(NSDictionary*)response operations:(NSMutableDictionary *)operations;
-(NSMutableDictionary *)beforeConnection;
@end

#define DATA_CURRENTINSTALLATION_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentInstallation", DATA_MAIN_PATH]

SpecBegin(NCMBInstallation)

describe(@"NCMBInstallation", ^{

    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";

    NSDictionary *initialLocalInstallation = @{
                                               @"timeZone" : @"Asia/Tokyo",
                                               @"deviceToken" : @"7f9af3973668245167e8bb132a",
                                               @"deviceType" : @"ios",
                                               @"createDate" : @{
                                                       @"iso" : @"2016-11-04T03:49:32.415Z",
                                                       @"__type" : @"Date"
                                                       },
                                               @"appVersion" : @"1",
                                               @"updateDate" : @{
                                                       @"iso" : @"2016-11-04T03:49:32.415Z",
                                                       @"__type" : @"Date"
                                                       },
                                               @"acl" : @{

                                                       },
                                               @"applicationName" : @"aaaa",
                                               @"objectId" : @"EVMu2ne7bjzZhOW2",
                                               @"sdkVersion" : @"3.0.1"
                                               };

    NSDictionary *responseInstallation = @{@"channels" : @[

                                                   ],
                                           @"timeZone" : @"Asia/Tokyo",
                                           @"applicationName" : [NSNull null],
                                           @"sdkVersion" : [NSNull null],
                                           @"badge" : @0,
                                           @"objectId" : @"90EvvPbJIvuEfHwV",
                                           @"deviceToken" : @"8fa36a7c2b490723388ebdcdd37cf1de4",
                                           @"appVersion" : [NSNull null],
                                           @"acl" : @{
                                                   @"*" : @{
                                                           @"write" : @YES,
                                                           @"read" : @YES
                                                           }
                                                   },
                                           @"updateDate" : @{
                                                   @"iso" : @"2016-11-01T08:20:00.209Z",
                                                   @"__type" : @"Date"
                                                   },
                                           @"deviceType" : @"ios",
                                           @"createDate" : @{
                                                   @"iso" : @"2016-11-01T08:08:17.615Z",
                                                   @"__type" : @"Date"
                                                   }

                                           };

    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });

    beforeEach(^{
        NSString *bundleVer = @"1";
        [[[NSBundle mainBundle] infoDictionary] setValue:bundleVer forKey:@"CFBundleVersion"];

        // save local installation file
        NSMutableDictionary *saveDictionary = [NSMutableDictionary dictionary];
        [saveDictionary setObject:initialLocalInstallation forKey:@"data"];
        [saveDictionary setObject:@"installation" forKey:@"className"];
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:saveDictionary
                                                       options:kNilOptions
                                                         error:&error];
        [data writeToFile:DATA_CURRENTINSTALLATION_PATH atomically:YES];

    });

    it(@"should be able to get currentInstallation from a local file, if appVersion and sdkVersion are null", ^{

        NSDictionary *dic = @{
                              @"timeZone" : @"Asia/Tokyo",
                              @"appVersion" : [NSNull null],
                              @"updateDate" : @{
                                      @"__type" : @"Date",
                                      @"iso" : @"2016-11-01T06:22:11.745Z"
                                      },
                              @"deviceType" : @"ios",
                              @"applicationName" : [NSNull null],
                              @"sdkVersion" : [NSNull null],
                              @"objectId" : @"iwQJ1mlfUa1fVF4R",
                              @"acl" : @{

                                      },
                              @"createDate" : @{
                                      @"__type" : @"Date",
                                      @"iso" : @"2016-11-01T06:17:43.838Z"
                                      },
                              @"deviceToken" : @"8fa36a7c2b490723388ebdcdd37cf1de47bf9ce15aa43c494f22bce68092cff1"
                              };

        NSMutableDictionary *saveDictionary = [NSMutableDictionary dictionary];
        [saveDictionary setObject:dic forKey:@"data"];
        [saveDictionary setObject:@"installation" forKey:@"className"];
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:saveDictionary
                                                       options:kNilOptions
                                                         error:&error];
        [data writeToFile:[NSString stringWithFormat:@"%@/Private Documents/NCMB/currentInstallation", DATA_MAIN_PATH] atomically:YES];

        NCMBInstallation *installation = [NCMBInstallation currentInstallation];

        expect(installation).notTo.beNil;
        expect([installation objectForKey:@"sdkVersion"]).to.equal(SDK_VERSION);
        expect([installation objectForKey:@"appVersion"]).to.equal([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);

    });

    it(@"should not be updated the local installation file, When afterFetch", ^{

        NCMBInstallation *installation = [NCMBInstallation currentInstallation];

        [installation afterFetch:[NSMutableDictionary dictionaryWithDictionary:responseInstallation] isRefresh:NO];

        // get local installation file
        NSError *fileError = nil;
        NSData *localData = [NSData dataWithContentsOfFile:DATA_CURRENTINSTALLATION_PATH
                                                   options:kNilOptions
                                                     error:&fileError];
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:localData
                                                                    options:kNilOptions
                                                                      error:&fileError];
        NSMutableDictionary *localFileDic = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:@"data"]];

        expect([localFileDic objectForKey:@"sdkVersion"])
        .toNot.equal([responseInstallation objectForKey:@"sdkVersion"]);
        expect([localFileDic objectForKey:@"appVersion"])
        .toNot.equal([responseInstallation objectForKey:@"appVersion"]);
        expect([localFileDic objectForKey:@"deviceToken"])
        .toNot.equal([responseInstallation objectForKey:@"deviceToken"]);
    });
    
    it(@"should be able to create local currentInstallation file when afterSave", ^{
        
        // remove currentInstallationFile
        [[NSFileManager defaultManager] removeItemAtPath:DATA_CURRENTINSTALLATION_PATH error:nil];
        
        BOOL isCurrentInstallationFileExist = [[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTINSTALLATION_PATH isDirectory:nil];
        expect(isCurrentInstallationFileExist).to.beFalsy();
        
        NSDictionary *responseDic = @{
                                      @"updateDate" : @"2017-06-08T03:54:28.115Z"
                                      };
        
        NSString *tokenId = @"d88757a988361805a2fb1f32837339f6390c7ed0b93d61a4d199b6e679d4ae61";
        
        NCMBInstallation *installation = [NCMBInstallation currentInstallation];
        [installation setObject:tokenId forKey:@"deviceToken"];
        
        NSMutableDictionary *operation = [installation beforeConnection];
        
        [installation afterSave:responseDic operations:operation];
        
        isCurrentInstallationFileExist = [[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTINSTALLATION_PATH isDirectory:nil];
        expect(isCurrentInstallationFileExist).to.beTruthy();
        
    });
    
    afterEach(^{

    });

    afterAll(^{

    });
});

SpecEnd
