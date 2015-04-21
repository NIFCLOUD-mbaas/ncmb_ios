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
 @param block 会員登録後に実行されるブロック
 */
+ (void)logInWithReadPermission:(NSArray *)readPermission block:(NCMBUserResultBlock)block;

/**
 引数に指定したPublishingPermissionをもとに、Facebookへのアクセストークン取得をし、
 Facebookのアカウントでニフティクラウド mobile backendへの会員登録を行う。
 @param publishingPermission Facebookにアクセストークンを要求するときのパーミッション設定
 @param block 会員登録後に実行されるブロック
 */
+ (void)logInWithPublishingPermission:(NSArray *)publishingPermission block:(NCMBUserResultBlock)block;

@end
