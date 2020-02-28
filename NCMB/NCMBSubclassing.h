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

@class NCMBQuery;

/**
 NCMBSubclassingに準拠したNCMBObjectのサブクラスは、registerSubclassメソッドを呼び出すことで、
 ニフクラ mobile backendのオブジェクトとして、使用することができます。
 */
@protocol NCMBSubclassing <NSObject>

/**
 オブジェクトを生成
 @return サブクラスのインスタンス
 */
+ (id)object;

/**
 指定したobjectIdでオブジェクトを生成
 @param objectId 生成するオブジェクトのobjectIdを指定
 @return サブクラスのインスタンス
 */
+ (id)objectWithoutDataWithObjectId:(NSString *)objectId;

/**
 mobile backend上のクラス名を返却する。
 @return サブクラスのデータストア上でのクラス名
 */
+ (NSString *)ncmbClassName;

/**
 設定されているクラスを対象として検索するためのNCMBQueryを生成
 @return サブクラスのクエリ
 */
+ (NCMBQuery *)query;

/**
 サブクラスの登録 setApplicationKey:clientKey:の前にこのメソッドを呼んで下さい。
 */
+ (void)registerSubclass;

@end
