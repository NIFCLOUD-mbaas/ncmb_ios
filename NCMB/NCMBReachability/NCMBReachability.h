/*
 Copyright 2017-2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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
