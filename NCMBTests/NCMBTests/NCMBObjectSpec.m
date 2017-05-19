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

@interface NCMBObject (Private)
- (void)saveCommandToFile:(NSDictionary*)localDic error:(NSError**)error;
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
    
    afterEach(^{
        
    });
    
    afterAll(^{
        
    });
});

SpecEnd
