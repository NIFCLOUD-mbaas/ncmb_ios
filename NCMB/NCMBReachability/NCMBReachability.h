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
+(void)updateFlags:(SCNetworkReachabilityFlags)flags;

/**
 電波状況が変化したときに保存された処理一覧を取得する
 */
- (void)reachabilityChanged;

/**
 電波状況の監視を開始する
 @return 問題なく開始できた場合はYESを返す
 */
- (BOOL)startNotifier;

/**
 現在の通信状況を取得する
 @return 通信状況が取得できた場合にtrueを返却する
 */
- (BOOL)getCurrentReachabilityStatus;

/**
 指定したホスト名にアクセスできる状態かをチェックする
 @return アクセスできる場合はYESを返す
 */
- (BOOL)isReachableToTarget;

@end
