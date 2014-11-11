//
//  NCMBInstallation.h
//  NCMB
//
//  Created by SCI01433 on 2014/11/06.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

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
