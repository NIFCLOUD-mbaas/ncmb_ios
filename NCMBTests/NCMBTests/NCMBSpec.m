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

@interface NCMB (Private)
@end

SpecBegin(NCMB)

describe(@"NCMB", ^{
    
    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";
    
    beforeAll(^{

    });
    
    beforeEach(^{
        
    });
    
    it(@"should be able to create a save directory for the files used in this SDK ", ^{
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString* dirName = [paths objectAtIndex:0];
        
        BOOL isYES = YES;
        
        // remove Private Documents
        NSString *privateDocumentsFileDirPath = [NSString stringWithFormat:@"%@/%@",dirName,@"Private Documents"];
        [[NSFileManager defaultManager] removeItemAtPath:privateDocumentsFileDirPath error:nil];
        
        BOOL isPrivateDocumentsFileDirExist = [[NSFileManager defaultManager] fileExistsAtPath:privateDocumentsFileDirPath isDirectory:&isYES];
        expect(isPrivateDocumentsFileDirExist).to.beFalsy();
        
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];

        // /Library/Private Documents
        isPrivateDocumentsFileDirExist = [[NSFileManager defaultManager] fileExistsAtPath:privateDocumentsFileDirPath isDirectory:&isYES];
        expect(isPrivateDocumentsFileDirExist).to.beTruthy();
        
        // /Library/Private Documents/NCMB
        NSString *ncmbDocumentsFileDirPath = [NSString stringWithFormat:@"%@/%@",dirName,@"Private Documents/NCMB"];
        BOOL isNcmbDocumentsFileExist = [[NSFileManager defaultManager] fileExistsAtPath:ncmbDocumentsFileDirPath isDirectory:&isYES];
        expect(isNcmbDocumentsFileExist).to.beTruthy();

        // /Library/Private Documents/NCMB/Command Cache
        NSString *commandCacheDocumentsFileDirPath = [NSString stringWithFormat:@"%@/%@",dirName,@"Private Documents/NCMB/Command Cache"];
        BOOL isCommandCacheDocumentsFileExist = [[NSFileManager defaultManager] fileExistsAtPath:commandCacheDocumentsFileDirPath isDirectory:&isYES];
        expect(isCommandCacheDocumentsFileExist).to.beTruthy();

    });
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd

