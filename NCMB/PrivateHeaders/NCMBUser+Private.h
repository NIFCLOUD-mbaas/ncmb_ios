//
//  NCMBUser+Private.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/08.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBUser.h"
#import "NCMBObject+Private.h"

@interface NCMBUser (Private)
/**
 現在ログイン中のユーザーのセッショントークンを返す
 */
+ (NSString *)getCurrentSessionToken;

/**
 ログアウトの処理
 */
+ (void)logOutEvent;

/**
 ログインユーザーをファイルに保存する
 @param NCMBUSer型ファイルに保存するユーザー
 */
+ (void) saveToFileCurrentUser:(NCMBUser *)user;

@end