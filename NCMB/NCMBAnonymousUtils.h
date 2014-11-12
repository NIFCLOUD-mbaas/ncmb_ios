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

#import "NCMBConstants.h"

@class NCMBUser;

/**
 NCMBAnonymousUtilsクラスは、匿名ユーザでのログインを管理しているクラスです。
 
 匿名ユーザには、下記のようないくつかの規則があります。
 
 ・匿名ユーザは、ユーザ名とパスワードなしでログインできます。
 
 ・一度ログアウトした場合は、匿名ユーザを復元することはできません。
 
 ・currentUserが匿名の場合、以下の(1)～(3)のように別のユーザに切り替えたり、正式なアカウントに変更します。
 
 (1)signUpは、ユーザ名とパスワードが与えられ、匿名ユーザから正式アカウントへ移行させます。その際、匿名ユーザ時のデータは保存されます。
 
 (2)ログインは、匿名ユーザ自体は変わらず、ユーザを変更します。この際、匿名ユーザのデータは失われます。
 
 (3)Facebook、twitterによるログインは、リンクさせることでFacebookやtwitter情報を用い、匿名ユーザから正式アカウントへ移行します。すでにリンクされている場合は、登録してある既存ユーザに切り替えます。
 */
@interface NCMBAnonymousUtils : NSObject

/** @name logIn */

/**
 匿名ユーザでログイン(同期)。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return BOOL型 ログインユーザーを返す
 */
+ (NCMBUser *)logIn:(NSError **)error;

/**
 匿名ユーザでログイン(非同期)。ログインし終わったら与えられたblockを呼び出す。
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NCMBUser *user, NSError *errorr） userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithBlock:(NCMBUserResultBlock)block;

/**
 匿名ユーザでログイン(非同期)。ログインし終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。(void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTarget:(id)target selector:(SEL)selector;



/**
 指定したユーザが匿名ユーザかどうか判断。匿名ユーザの場合はtrueを返す。
 @param user 指定するユーザ
 @return BOOL型 ログイン中のユーザーが匿名ユーザーの場合YESを返す
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user;



@end

