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

#import <Foundation/Foundation.h>

@class NCMBUser;
@class NCMBObject;


#pragma mark - error
#define ERRORDOMAIN @"NCMBErrorDomain"
#define SDK_VERSION @"3.0.3"

#define DATA_MAIN_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"]
#define COMMAND_CACHE_FOLDER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/Command Cache/", DATA_MAIN_PATH]

#define API_VERSION_V1 @"2013-09-01"

/// コールバックブロック
typedef void (^NCMBBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^NCMBIntegerResultBlock)(int number, NSError *error);
typedef void (^NCMBObjectResultBlock)(NCMBObject *object, NSError *error);
typedef void (^NCMBArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^NCMBSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^NCMBUserResultBlock)(NCMBUser *user, NSError *error);
typedef void (^NCMBErrorResultBlock) (NSError *error);
typedef void (^NCMBAnyObjectResultBlock)(id object, NSError *error);

typedef void (^NCMBDataResultBlock)(NSData *data, NSError *error);
typedef void (^NCMBDataStreamResultBlock)(NSInputStream *stream, NSError *error);
typedef void (^NCMBProgressBlock)(int percentDone);
