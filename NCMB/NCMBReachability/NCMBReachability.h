//
//  NCMBReachability.h
//  NCMB
//
//  Created by SCI01433 on 2014/10/29.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface NCMBReachability : NSObject

/**
 シングルトンクラスのインスタンスを返す
 */
+(NCMBReachability*)sharedInstance;

/**
 指定したhostNameにアクセスできるかを監視するインスタンスを返す
 @param hostName アクセスを確認するホスト名
 */
- (void)reachabilityWithHostName:(NSString *)hostName;

/**
 電波状況を更新
 */
-(void)updateFlags:(SCNetworkReachabilityFlags)flags;

/**
 電波状況の監視を開始する
 @return 問題なく開始できた場合はYESを返す
 */
- (BOOL)startNotifier;

/**
 指定したホスト名にアクセスできる状態かをチェックする
 @return アクセスできる場合はYESを返す
 */
- (BOOL)isReachableWWAN;

@end
