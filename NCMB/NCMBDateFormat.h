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

#import <Foundation/Foundation.h>

/**
 NCMB内で使用するNSDateFormatterを管理するクラスです。
 */
@interface NCMBDateFormat : NSObject

/**
 ISO 8601形式の時刻表記でDateFormatを作成します。
 @return ISO 8601形式のNSDateFormatter
 */
+ (NSDateFormatter *) getIso8601DateFormat;

/**
 ファイル名に使用されるDateFormatを作成します。
 @return ファイル名用のNSDateFormatter
 */
+ (NSDateFormatter *) getFileNameDateFormat;

@end
