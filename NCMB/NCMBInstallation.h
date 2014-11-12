/*******
 Copyright 2014 NIFTY Corporation All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **********/

#import "NCMBObject.h"

@class NCMBQuery;

@interface NCMBInstallation : NCMBObject

/// deviceType 登録された端末の種類
@property (nonatomic, readonly) NSString *deviceType;
/// deviceToken 登録された端末のデバイストークン
@property (nonatomic) NSString *deviceToken;
/// badge バッジ数
@property (nonatomic) NSInteger badge;
/// timeZone タイムゾーン
@property (nonatomic, readonly) NSString *timeZone;
/// channels 登録されたチャネルリスト
@property (nonatomic) NSMutableArray *channels;

/**
 installationクラスを検索するためのNCMBQueryを生成
 @return installationクラスを検索するように設定されたNCMBQueryのインスタンスを返却する
 */
+ (NCMBQuery *)query;

/**
 アプリが動作している端末のNCMBInstallationを取得。
 @return NCMBInstallationのインスタンスを返却する
 */
+ (NCMBInstallation *)currentInstallation;

/**
 NSData型のデバイストークンを設定
 @param deviceTokenData デバイストークン
 */
- (void)setDeviceTokenFromData:(NSData *)deviceTokenData;

@end
