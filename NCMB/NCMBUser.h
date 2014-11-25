/*******
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
 **********/

#import <Foundation/Foundation.h>

#import "NCMBObject.h"

@class NCMBAnonymousUtils;
@class NCMBQuery;

/**
 NCMBUserクラスは、ニフティクラウドmobile backend上に保存されたユーザデータを管理するクラスです。
 このクラスは、NCMBObjectのサブクラスなので同じ機能を持っています。さらに、ユーザ新規登録、認証などを行います。
 */
@interface NCMBUser : NCMBObject

/** @name User */

/// ユーザ名
@property (nonatomic, copy) NSString *userName;
//@property (nonatomic, strong, getter = getUserName, setter=setUserName:) NSString *userName;

/// パスワード
@property (nonatomic, copy) NSString *password;
//@property (nonatomic, strong, getter = getPassword, setter=setPassword:) NSString *password;

/// メールアドレス
@property (nonatomic, copy) NSString *mailAddress;
//@property (nonatomic, strong, getter = getMailAddress, setter=setMailAddress:) NSString *mailAddress;

/// NCMBUserオブジェクトの登録の有無
@property (readonly, assign) BOOL isNew;

/// セッショントークン
@property (nonatomic, copy) NSString *sessionToken;

/**
 NCMBUserのインスタンスを新規生成
 @return 新規生成したNCMBUserのインスタンス
 */
+ (NCMBUser *)user;


/**
 NCMBQueryのインスタンスを新規作成する
 @return userクラスがセットされたNCMBQueryインスタンスを返却する
 */
+ (NCMBQuery*)query;

/**
 現在ログインしているユーザ情報を取得
 @return 現在ログインしているユーザオブジェクト
 */
+ (NCMBUser *)currentUser;

/**
 ユーザが認証済みかを判定
 　@return BOOL型YES=認証済、NO=未認証
 */
- (BOOL)isAuthenticated;

/**
 匿名ユーザの自動生成を有効化
 */
+ (void)enableAutomaticUser;

/** @name Signup */

/**
 ユーザの新規登録。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return 新規登録の成功の有無
 */
- (BOOL)signUp:(NSError **)error;

/**
 ユーザを非同期で新規登録。新規登録し終わったら与えられたblockを呼び出す。
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（BOOL succeeded, NSError *error）succeededには通信結果がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)signUpInBackgroundWithBlock:(NCMBBooleanResultBlock)block;

/**
 ユーザを非同期で新規登録。新規登録し終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultには通信結果がNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)signUpInBackgroundWithTarget:(id)target selector:(SEL)selector;

/** @name requestAuthenticationMail */

/**
 指定したメールアドレスに対して、会員登録を行うためのメールを送信するよう要求する。必要があればエラーをセットし、取得することもできる。
 @param email 指定するメールアドレス
 @param error 処理中に起きたエラーのポインタ
 @return 通信結果を返却。HTTPステータスが200ならYESを返す
 */
+ (BOOL)requestAuthenticationMail:(NSString *)email
                            error:(NSError **)error;

/**
 指定したメールアドレスに対して、会員登録を行うためのメールを送信するよう要求する。終わったら指定されたコールバックを呼び出す。
 @param email 指定するメールアドレス
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultには通信結果をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)requestAuthenticationMailInBackground:(NSString *)email
                                       target:(id)target
                                     selector:(SEL)selector;

/**
 指定したメールアドレスに対して、会員登録を行うためのメールを送信するよう要求する。終わったら与えられたblockを呼び出す。
 @param email 指定するメールアドレス
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （BOOL succeeded, NSError *error）succeededには通信結果がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)requestAuthenticationMailInBackground:(NSString *)email
                                        block:(NCMBBooleanResultBlock)block;


/** @name LogIn */

/**
 ユーザ名とパスワードを指定してログイン。必要があればエラーをセットし、取得することもできる。
 @param username ログイン時に指定するユーザ名
 @param password ログイン時に指定するパスワード
 @param error 処理中に起きたエラーのポインタ
 @return ログインしたユーザの情報
 */
+ (NCMBUser *)logInWithUsername:(NSString *)username
                       password:(NSString *)password
                          error:(NSError **)error;


/**
 ユーザ名とパスワードを指定して非同期でログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param username ログイン時に指定するユーザ名
 @param password ログイン時に指定するパスワード
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。(void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                               target:(id)target
                             selector:(SEL)selector;

/**
 ユーザ名とパスワードを指定して非同期でログイン。ログインし終わったら与えられたblockを呼び出す。
 @param username ログイン時に指定するユーザ名
 @param password ログイン時に指定するパスワード
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NCMBUser *user, NSError *error） userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                                block:(NCMBUserResultBlock)block;

/**
 メールアドレスとパスワードを指定してログイン。必要があればエラーをセットし、取得することもできる。
 @param email ログイン時に指定するメールアドレス
 @param password ログイン時に指定するパスワード
 @param error 処理中に起きたエラーのポインタ
 @return ログインしたユーザの情報
 */
+ (NCMBUser *)logInWithMailAddress:(NSString *)email
                          password:(NSString *)password
                             error:(NSError **)error;

/**
 メールアドレスとパスワードを指定して非同期でログイン。ログインし終わったら与えられたコールバックを呼び出す。
 @param email ログイン時に指定するメールアドレス
 @param password ログイン時に指定するパスワード
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。(void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithMailAddressInBackground:(NSString *)email
                                password:(NSString *)password
                                  target:(id)target
                                selector:(SEL)selector;

/**
 メールアドレスとパスワードを指定して非同期でログイン。ログインし終わったら与えられたblockを呼び出す。
 @param email ログイン時に指定するメールアドレス
 @param password ログイン時に指定するパスワード
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NCMBUser *user, NSError *error） userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithMailAddressInBackground:(NSString *)email
                                password:(NSString *)password
                                   block:(NCMBUserResultBlock)block;


/** @name Logout */

/**
 ログアウト
 */
+ (void)logOut;


/** @name requestPasswordReset */

/**
 指定したメールアドレスを持つユーザのパスワードリセットを要求。ユーザが存在した場合、パスワードをリセットし、再設定のメールを送信する。必要があればエラーをセットし、取得することもできる。
 @param email 指定するメールアドレス
 @param error 処理中に起きたエラーのポインタ
 @return リセットの有無。リセットしたらYESを返す
 */
+ (BOOL)requestPasswordResetForEmail:(NSString *)email
                               error:(NSError **)error;

/**
 指定したメールアドレスを持つユーザのパスワードリセットを非同期で要求。ユーザが存在した場合、パスワードをリセットし、再設定のメールを送信する。リセットし終わったら指定されたコールバックを呼び出す。
 @param email 指定するメールアドレス
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリセットの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email
                                          target:(id)target
                                        selector:(SEL)selector;

/**
 指定したメールアドレスを持つユーザのパスワードリセットを非同期で要求。ユーザが存在した場合、パスワードをリセットし、再設定のメールを送信する。リセットし終わったら与えられたblockを呼び出す。
 @param email 指定するメールアドレス
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （BOOL succeeded, NSError *error）succeededにはリセットの有無がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email
                                           block:(NCMBBooleanResultBlock)block;









/**
 匿名会員を正規会員として同期で登録する。2回のAPIリクエストが発生する。objectiId,createDate,updateDate,authdata以外の情報を引き継ぐ。必要があればエラーをセットし、取得することもできる。
 @param userName 正規会員のユーザー名
 @param password 正規会員のパスワード
 @param error 処理中に起きたエラーのポインタ
 @return 通信の成功有無
 */
- (BOOL)signUpFromAnonymous:(NSString *)userName password:(NSString *)password error:(NSError **)error;

/**
 匿名会員を正規会員として非同期で登録する。2回のAPIリクエストが発生する。objectiId,createDate,updateDate,authdata以外の情報を引き継ぐ。必要があればエラーをセットし、取得することもできる。
 @param userName 正規会員のユーザー名
 @param password 正規会員のパスワード
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（BOOL succeeded, NSError *error）succeededには通信結果がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)signUpFromAnonymousInBackgroundWithBlock:(NSString *)userName
                                        password:(NSString *)password
                                           block:(NCMBBooleanResultBlock)block;
/**
 匿名会員を正規会員として非同期で登録する。2回のAPIリクエストが発生する。objectiId,createDate,updateDate,authdata以外の情報を引き継ぐ。必要があればエラーをセットし、取得することもできる。
 @param userName 正規会員のユーザー名
 @param password 正規会員のパスワード
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultには通信結果がNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)signUpFromAnonymousInBackgroundWithTarget:(NSString *)userName
                                         password:(NSString *)password
                                           target:(id)target
                                         selector:(SEL)selector;
@end
