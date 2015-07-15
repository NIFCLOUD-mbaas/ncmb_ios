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


@interface NCMB_Twitter : NSObject

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *authTokenSecret;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *screenName;

- (void)authorizeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure cancel:(void (^)(void))cancel;
- (void)signRequest:(NSMutableURLRequest *)request;

@end


/**
 NCMBTwitterUtilsクラスは、Twitter連携の機能を提供するクラスです。
 */
@interface NCMBTwitterUtils : NSObject

/**
 NCMB_Twitterオブジェクトを返す
 @return NCMB_Twitter
 */
+ (NCMB_Twitter *)twitter;

/**
 twitterの初期化
 @param consumerKey twitterアプリのconsumerKey
 @param consumerSecret twitterアプリのconsumerSecret
 */
+ (void)initializeWithConsumerKey:(NSString *)consumerKey
                   consumerSecret:(NSString *)consumerSecret;

/**
 指定したユーザがtwitter連携されているかを判断。twitter連携されている場合は、trueを返す。
 @param user 指定するユーザ
 @return BOOL型 ログイン中のユーザーがtwitterユーザーの場合YESを返す
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user;

/**
 twitterを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithBlock:(NCMBUserResultBlock)block;

/**
 twitterを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTarget:(id)target selector:(SEL)selector;

/**
 twitterを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param twitterId ログインさせるtwitterアカウントのtwitterID
 @param screenName ログインさせるtwitterアカウントのscreenName
 @param authToken ログインさせるtwitterアカウントのaccessToken
 @param authTokenSecret ログインさせるtwitterアカウントのauthTokenSecret
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                     block:(NCMBUserResultBlock)block;

/**
 twitterを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param twitterId ログインさせるtwitterアカウントのtwitterID
 @param screenName ログインさせるtwitterアカウントのscreenName
 @param authToken ログインさせるtwitterアカウントのaccessToken
 @param authTokenSecret ログインさせるtwitterアカウントのauthTokenSecret
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                    target:(id)target
                  selector:(SEL)selector;

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user block:(NCMBErrorResultBlock)block;

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
          target:(id)target
        selector:(SEL)selector;

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param twitterId ユーザにリンクさせるtwitterアカウントのtwitterID
 @param screenName ユーザにリンクさせるtwitterアカウントのscreenName
 @param authToken ユーザにリンクさせるtwitterアカウントのaccessToken
 @param authTokenSecret ユーザにリンクさせるtwitterアカウントのauthTokenSecret
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
           block:(NCMBErrorResultBlock)block;

/**
指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param twitterId ユーザにリンクさせるtwitterアカウントのtwitterID
 @param screenName ユーザにリンクさせるtwitterアカウントのscreenName
 @param authToken ユーザにリンクさせるtwitterアカウントのaccessToken
 @param authTokenSecret ユーザにリンクさせるtwitterアカウントのauthTokenSecret
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
          target:(id)target
        selector:(SEL)selector;

/**
 指定したユーザとtwitterのリンクを解除。必要があればエラーをセットし、取得することもできる。
 @param user 指定するユーザ
 @param error 処理中に起きたエラーのポインタ
 */
+ (void)unlinkUser:(NCMBUser *)user error:(NSError **)error;

/**
 指定したユーザとtwitterのリンクを解除。解除し終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user
                         block:(NCMBErrorResultBlock)block;

/**
 指定したユーザとtwitterのリンクを解除する。解除し終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンク解除の有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user
                        target:(id)target selector:(SEL)selector;

@end
