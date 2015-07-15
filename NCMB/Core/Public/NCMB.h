/*
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
 */

#import <Foundation/Foundation.h>

#import "NCMBAnalytics.h"
#import "NCMBInstallation.h"
#import "NCMBPush.h"
#import "NCMBAnonymousUtils.h"
#import "NCMBQuery.h"
#import "NCMBGeoPoint.h"
#import "NCMBRelation.h"
#import "NCMBRole.h"
#import "NCMBACL.h"
#import "NCMBError.h"
#import "NCMBObject.h"
#import "NCMBUser.h"
#import "NCMBFile.h"
#import "NCMBTwitterUtils.h"


#if defined(__has_include)
#if __has_include(<FacebookSDK/FacebookSDK.h>) || __has_include(<FBSDKLoginKit/FBSDKLoginKit.h>)
#import "NCMBFacebookUtils.h"
#endif
#if __has_include(<GoogleSignIn/GoogleSignIn.h>)
#import "NCMBGoogleUtils.h"
#endif
#endif

#ifdef NCMBTEST
#define NCMBDEBUGLOG(...) NSLog(__VA_ARGS__)
#else
#define NCMBDEBUGLOG(...)
#endif

#ifdef NCMBTEST
#define NCMBWAIT(...) [NSThread sleepForTimeInterval:__VA_ARGS__]
#else
#define NCMBWAIT(...)
#endif

#import "NCMBSubclassing.h"
#import "NCMBConstants.h"
#import "NCMBReachability.h"

/**
 NCMBクラスは、キーの設定やレスポンスバリデーションの設定を行うクラスです。
 */
@interface NCMB : NSObject

/**
 アプリケーションキーとクライアントキーの設定
 @param applicationKey アプリケーションを一意に識別するキー
 @param clientKey APIを利用する際に必要となるキー
 */
+ (void)setApplicationKey:(NSString *)applicationKey clientKey:(NSString *)clientKey;

/**
 アプリケーションキーの取得
 */
+ (NSString *)getApplicationKey;

/**
 クライアントキーの取得
 */
+ (NSString *)getClientKey;

/**
 レスポンスが改ざんされていないか判定する機能を有効にする<br/>
 デフォルトは無効です
 @param checkFlag true:有効, false:無効
 */
+ (void)enableResponseValidation:(BOOL)checkFlag;

/**
 レスポンバリデーションの設定状況を取得
 */
+ (BOOL)getResponseValidationFlag;

@end