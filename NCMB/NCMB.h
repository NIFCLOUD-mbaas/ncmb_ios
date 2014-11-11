//
//  NCMB.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/04.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

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
#import "NCMBFacebookUtils.h"

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