/*
 Copyright 2017-2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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
#import "NCMBScriptService.h"

/**
 NCMBScriptクラスは、ニフクラ mobile backendに登録されているスクリプトを実行するためのクラスです。
 */
@interface NCMBScript : NSObject

/// service スクリプト実行APIをリクエストするためのService
@property NCMBScriptService* service;

/// scriptName スクリプトのファイル名
@property NSString *scriptName;

/// method スクリプトをリクエストする場合のメソッド
@property NCMBScriptRequestMethod method;

/**
 スクリプト名とリクエストメソッドを指定してNCMBScriptのインスタンスを作成
 @param name スクリプトのファイル名
 @param method スクリプトをリクエストする場合のメソッド
 @return NCMBScriptのインスタンス
*/
+ (instancetype)scriptWithName:(NSString*)name method:(NCMBScriptRequestMethod)method;

/**
 スクリプト名とリクエストメソッド、APIのエンドポイントを指定してNCMBScriptのインスタンスを作成
 @param name スクリプトのファイル名
 @param method スクリプトをリクエストする場合のメソッド
 @param endpoint ローカルで動作させているスクリプトをリクエストする場合などに指定するAPIサーバーのエンドポイント
 @return NCMBScriptのインスタンス
*/
+ (instancetype)scriptWithName:(NSString *)name
                        method:(NCMBScriptRequestMethod)method
                      endpoint:(NSString *)endpoint;

/**
 リクエストパラメータを指定してスクリプトを同期通信で実行し、結果を取得する
 @param data リクエスト時のbodyデータ（リクエストメソッドが NCMBExecuteWithPostMethod / NCMBExecuteWithPutMethod の場合のみ送信される）
 @param headers リクエスト時のヘッダー
 @param queries リクエスト時のクエリパラメータ(クエリストリングに変換されます)
 @param error エラーオブジェクトのポインタ
 @return スクリプトを実行した結果をNSDataで返す
*/
- (NSData *)execute:(NSDictionary *)data
            headers:(NSDictionary *)headers
            queries:(NSDictionary *)queries
              error:(NSError **)error;

/**
 リクエストパラメータを指定してスクリプトを非同期通信で実行し、結果を取得する
 @param data リクエスト時のbodyデータ（リクエストメソッドが NCMBExecuteWithPostMethod / NCMBExecuteWithPutMethod の場合のみ送信される）
 @param headers リクエスト時のヘッダー
 @param queries リクエスト時のクエリパラメータ(クエリストリングに変換されます)
 @param block スクリプト実行APIをリクエストしたあとに実行されるコールバック。コールバック引数のdataにはスクリプト実行後の結果が入ります。errorにはスクリプト実行後のエラーが入ります。
*/
- (void)execute:(NSDictionary *)data
        headers:(NSDictionary *)headers
        queries:(NSDictionary *)queries
      withBlock:(NCMBScriptExecuteCallback)block;

@end
