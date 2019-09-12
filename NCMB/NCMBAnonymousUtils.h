/*
 Copyright 2017-2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

/**
 NCMBAnonymousUtilsクラスは、匿名ユーザでのログインを管理しているクラスです。
 
 匿名ユーザには、下記のようないくつかの規則があります。
 
 ・匿名ユーザは、ユーザ名とパスワードなしでログインできます。
 
 ・一度ログアウトした場合は、匿名ユーザを復元することはできません。
 */
@interface NCMBAnonymousUtils : NSObject

/** @name logIn */

/**
 同期通信を利用して匿名ユーザでログインする。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return 匿名ユーザー情報を含むNCMBUserのインスタンス
 */
+ (NCMBUser *)logIn:(NSError **)error;

/**
 非同期通信を利用して匿名ユーザでログインする。ログインし終わったら与えられたblockを呼び出す。
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NCMBUser *user, NSError *errorr） userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithBlock:(NCMBUserResultBlock)block;

/**
 非同期通信を利用して匿名ユーザでログインする。ログインし終わったら指定されたセレクタをNSInvocattionで呼び出す。
 @param target 呼び出すターゲット
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

