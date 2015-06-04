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

//Googleのライブラリがある場合はビルド対象に含める
#if defined(__has_include)
#if __has_include(<GoogleSignIn/GoogleSignIn.h>)

#import <Foundation/Foundation.h>
#import "NCMBUser.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface NCMBGoogleUtils : NSObject <GIDSignInDelegate>

/**
 引数に指定されたmBaaSの会員情報に、Googleの認証情報が含まれているか確認する
 @param user Googleの認証情報を確認するmBaaSの会員
 @return Googleの会員情報が含まれている場合はYESを返す
 */
+(BOOL)isLinkedWithUser:(NCMBUser*)user;

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param block mBaaSへの会員登録をリクエスト後に実行されるblock。NCMBUserとNSErrorを引数に持つ。
 */
+(void)logInWithGoogleAccountWithBlock:(NCMBUserResultBlock)block;

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param target mBaaSへの会員登録をリクエスト後に実行されるselectorのtarget
 @param selector mBaaSへの会員登録をリクエスト後に実行されるselector
 */
+(void)logInWithGoogleAccountWithTarget:(id)target selector:(SEL)selector;

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param user Googleの認証情報を追加するmBaaSの会員情報
 @param block mBaaSへの会員情報更新をリクエスト後に実行されるblock。NSErrorを引数に持つ。
 */
+(void)linkUser:(NCMBUser*)user googleAccountWithblock:(NCMBUserResultBlock)block;

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param user Googleの認証情報を追加するmBaaSの会員情報
 @param target mBaaSへの会員登録をリクエスト後に実行されるselectorのtarget
 @param selector mBaaSへの会員登録をリクエスト後に実行されるselector
 */
+(void)linkUser:(NCMBUser*)user googleAccountWithTarget:(id)target selector:(SEL)selector;

/**
 Googleの認証情報を引数で指定したmBaaSの会員情報から削除する
 @param user Googleの認証情報を削除するmBaaSの会員情報
 @param block mBaaSへの会員情報更新をリクエスト後に実行されるblock。NSErrorを引数に持つ。
 */
+(void)unLinkUser:(NCMBUser*)user withBlock:(NCMBUserResultBlock)block;

/**
 Googleの認証情報を引数で指定したmBaaSの会員情報から削除する
 @param user Googleの認証情報を削除するmBaaSの会員情報
 @param target mBaaSへの会員登録をリクエスト後に実行されるselectorのtarget
 @param selector mBaaSへの会員登録をリクエスト後に実行されるselector
 */
+(void)unLinkUser:(NCMBUser*)user withTarget:(id)target selector:(SEL)selector;


@end

#endif
#endif
