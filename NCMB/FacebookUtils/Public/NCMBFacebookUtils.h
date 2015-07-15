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
#import "NCMBConstants.h"

@class NCMBUser;

@class FBSession;

typedef int NCMBSessionDefaultAudience;

/**
 NCMBFacebookUtilsクラスは、Facebook連携の機能を提供するクラスです。
 */
@interface NCMBFacebookUtils : NSObject

#pragma mark check link to Facebook Account

/** @name isLinkedWithUser */

/**
 指定したユーザがFacebookユーザかどうか判定。Facebookユーザの場合はtrueを返す。
 @param user 指定するユーザ
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user;

#pragma mark Login with Facebook Account

/** @name login */

/**
 引数に指定したReadPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントでニフティクラウド mobile backendへの会員登録を行う。
 @param readPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param block 会員登録をリクエストした後に実行されるブロック
 */
+ (void)logInWithReadPermission:(NSArray *)readPermission block:(NCMBUserResultBlock)block;

/**
 引数に指定したReadPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントでニフティクラウド mobile backendへの会員登録を行う。
 @param readPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param target 会員登録をリクエストした後に実行するセレクタのターゲット
 @param selector 会員登録をリクエストした後に実行するセレクタ
 */
+ (void)logInWithReadPermission:(NSArray *)readPermission target:(id)target selector:(SEL)selector;

/**
 引数に指定したPublishingPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントでニフティクラウド mobile backendへの会員登録を行う。
 @param publishingPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param block 会員登録をリクエストした後に実行されるブロック
 */
+ (void)logInWithPublishingPermission:(NSArray *)publishingPermission block:(NCMBUserResultBlock)block;

/**
 引数に指定したPublishingPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントでニフティクラウド mobile backendへの会員登録を行う。
 @param publishingPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param target 会員登録をリクエストした後に実行するセレクタのターゲット
 @param selector 会員登録をリクエストした後に実行するセレクタ
 */
+ (void)logInWithPublishingPermission:(NSArray *)publishingPermission target:(id)target selector:(SEL)selector;

#pragma mark linkUser

/** @name linkUser */

/**
 引数に指定したReadPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントをニフティクラウド mobile backendの会員情報と紐付けを行う。
 @param user Facebookのアカウント情報を紐付ける会員情報
 @param readPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param block 会員情報の更新をリクエストした後に実行されるブロック
 */
+ (void)linkUser:(NCMBUser*)user withReadPermission:(NSArray *)readPermission block:(NCMBUserResultBlock)block;

/**
 引数に指定したReadPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントをニフティクラウド mobile backendの会員情報と紐付けを行う。
 @param user Facebookのアカウント情報を紐付ける会員情報
 @param readPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param target 会員情報の更新をリクエストした後に実行されるセレクタのターゲット
 @param selector 会員情報の更新をリクエストした後に実行されるセレクタ
 */
+ (void)linkUser:(NCMBUser*)user
withReadPermission:(NSArray *)readPermission
          target:(id)target
        selector:(SEL)selector;

/**
 引数に指定したPublishingPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントをニフティクラウド mobile backendの会員情報と紐付けを行う。
 @param user Facebookのアカウント情報を紐付ける会員情報
 @param publishingPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param block 会員情報の更新をリクエストした後に実行されるブロック
 */
+ (void)linkUser:(NCMBUser*)user
withPublishingPermission:(NSArray *)publishingPermission
           block:(NCMBUserResultBlock)block;

/**
 引数に指定したPublishingPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントをニフティクラウド mobile backendの会員情報と紐付けを行う。
 @param user Facebookのアカウント情報を紐付ける会員情報
 @param publishingPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param target 会員情報の更新をリクエストした後に実行されるセレクタのターゲット
 @param selector 会員情報の更新をリクエストした後に実行されるセレクタ
 */
+ (void)linkUser:(NCMBUser*)user
withPublishingPermission:(NSArray *)publishingPermission
          target:(id)target
        selector:(SEL)selector;

/**
 指定した会員のauthDataからFacebookの認証情報を削除する
 @param user Facebookの認証情報を削除する会員情報
 @param block 会員情報の更新をリクエストしたあとに実行されるブロック
 */
+ (void)unLinkUser:(NCMBUser*)user withBlock:(NCMBUserResultBlock)block;

/**
 指定した会員のauthDataからFacebookの認証情報を削除する
 @param user Facebookの認証情報を削除する会員情報
 @param target 会員情報の更新をリクエストした後に実行されるセレクタのターゲット
 @param selector 会員情報の更新をリクエストした後に実行されるセレクタ
 */
+ (void)unLinkUser:(NCMBUser*)user withTarget:(id)target selector:(SEL)selector;

@end
