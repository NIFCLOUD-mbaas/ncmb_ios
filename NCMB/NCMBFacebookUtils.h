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
#import <FacebookSDK/FBSession.h>

@class NCMBUser;

@class FBSession;

typedef int NCMBSessionDefaultAudience;

/**
 NCMBFacebookUtilsクラスは、Facebook連携の機能を提供するクラスです。
 */
@interface NCMBFacebookUtils : NSObject


/*
 FBSessionの取得
 @return FBSessionのインスタンス
 */
+ (FBSession *)session;

/*
 Facebookの初期化
 */
+ (void)initializeFacebook;

/*
 urlSchemeSuffixを指定し、Facebookの初期化
 @param urlSchemeSuffix アプリケーションのURL Suffix。１つのFacebookAppIDを複数のアプリケーションで使用する場合に用いる。
 */
+ (void)initializeFacebookWithUrlSchemeSuffix:(NSString *)urlSchemeSuffix;

/**
 指定したユーザがfacebook連携されているかを判断。facebook連携されている場合はtureを返す。
 @param user 指定するユーザ
 @return BOOL型 ログイン中のユーザーがFacebookユーザーの場合YESを返す
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user;

/** @name logIn */

/**
 facebookを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param permissions ログイン時に要求するパーミッション
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithPermissions:(NSArray *)permissions block:(NCMBUserResultBlock)block;

/**
 facebookを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param permissions ログイン時に要求するパーミッション
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithPermissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;

/**
 facebookを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 
 facebook認証済みのユーザーは、authDataにfacebookId, accessToken, expirationDateを含んでいるので 
 それらを使ってログインを実行するとFacebookへの画面遷移が不要になる。
 @param facebookId ログインさせるFacebookアカウントのfacebookID
 @param accessToken ログインさせるFacebookアカウントのaccessToken
 @param expirationDate ログインさせるFacebookアカウントのaccessToken有効期限
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                      block:(NCMBUserResultBlock)block;

/**
 facebookを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 
 facebook認証済みのユーザーは、authDataにfacebookId, accessToken, expirationDateを含んでいるので
 それらを使ってログインを実行するとFacebookへの画面遷移が不要になる。
 @param facebookId ログインさせるFacebookアカウントのfacebookID
 @param accessToken ログインさせるFacebookアカウントのaccessToken
 @param expirationDate ログインさせるFacebookアカウントのaccessToken有効期限
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                     target:(id)target
                   selector:(SEL)selector;

/** @name linkUser */

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param permissions ログイン時に要求するパーミッション
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error） 
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user permissions:(NSArray *)permissions block:(NCMBErrorResultBlock)block;

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param permissions ログイン時に要求するパーミッション
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user permissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;


/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param facebookId ユーザにリンクさせるID
 @param accessToken ユーザにリンクさせるaccessToken
 @param expirationDate ユーザにリンクさせるaccessTokenの有効期限
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
           block:(NCMBErrorResultBlock)block;

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param facebookId ユーザにリンクさせるID
 @param accessToken ユーザにリンクさせるaccessToken
 @param expirationDate ユーザにリンクさせるaccessTokenの有効期限
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
          target:(id)target
        selector:(SEL)selector;

/**
 指定したユーザとfacebookのリンクを解除。必要があればエラーをセットし、取得することもできる。
 @param user 指定するユーザ
 @param error 処理中に起きたエラーのポインタ
 */
+ (BOOL)unlinkUser:(NCMBUser *)user error:(NSError **)error;

/**
 指定したユーザとfacebookのリンクを解除。リンク解除し終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user block:(NCMBErrorResultBlock)block;

/**
 指定したユーザとfacebookのリンクを解除。リンク解除し終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンク解除の有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user target:(id)target selector:(SEL)selector;


/**
 指定ユーザのfacebook投稿権限の取得。取得し終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param permissions 要求するPublishPermissions
 @param audience 投稿の公開範囲
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)reauthorizeUser:(NCMBUser *)user
            permissions:(NSArray *)permissions
               audience:(NCMBSessionDefaultAudience)audience
                  block:(NCMBErrorResultBlock)block;

/**
 指定ユーザのfacebook投稿権限の取得。取得し終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param permissions 要求するPublishPermissions
 @param audience 投稿の公開範囲
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultには取得の有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)reauthorizeUser:(NCMBUser *)user
            permissions:(NSArray *)permissions
               audience:(NCMBSessionDefaultAudience)audience
                 target:(id)target
               selector:(SEL)selector;

/**
 facebook認証情報の処理を行います。
 AppDelegateでapplication:handleOpenURL:メソッドもしくは、application:openURL:sourceApplication:annotationメソッドにより取得したurl内のアクセストークンを用い、APIを呼び出す処理を行います。
 @param url ユーザの認証情報
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

@end
