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

#import "NCMBObject.h"

@interface NCMBObject (Private)

/**
 
 */
+ (id)object;

- (NSDictionary*)getLocalData;

+ (NCMBObject *)objectWithClassName:(NSString*)className data:(NSMutableDictionary *)attrs;

/**
 指定されたクラス名とobjectIdでNCMBObjectのインスタンスを作成する
 @param className 指定するクラス名
 @param objectId 指定するオブジェクトID
 */
+ (NCMBObject*)objectWithClassName:(NSString*)className objectId:(NSString*)objectId;

/**
 通信前に履歴の取り出しと、次のOperationを保存するDictionaryをキューにセットする
 @return currentOperations オブジェクトの操作履歴
 */
-(NSMutableDictionary *)beforeConnection;

/**
 オブジェクト更新後に操作履歴とestimatedDataを同期する
 */
-(void)afterSave:(NSDictionary*)response operations:(NSMutableDictionary*)operations;

/**
 fetchを実行したあとにプロパティとestimatedDataの更新を行う
 @param response レスポンスのDicitonary
 @param isRefresh リフレッシュ実行フラグ
 */
- (void)afterFetch:(NSMutableDictionary*)response isRefresh:(BOOL)isRefresh;

/**
 ローカルオブジェクトをリセットする
 */
- (void)afterDelete;

/**
 キューから最後(前回)の履歴データの取り出し
 @return 一番最後の操作履歴
 */
- (NSMutableDictionary *)currentOperations;

/**
 渡された履歴操作を実行する
 */
-(void)performOperation:(NSString *)key byOperation:(id)operation;

/**
 JSONオブジェクトをNCMBObjectに変換する
 @param jsonData JSON形式のデータ
 @param convertKey 変換するキー
 @return JSONオブジェクトから変換されたオブジェクト
 */
- (id)convertToNCMBObjectFromJSON:(id)jsonData convertKey:(NSString*)convertKey;

/**
 mobile backendにオブジェクトを保存する。非同期通信を行う。
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
-(NSMutableDictionary *)convertToJSONDicFromOperation:(NSMutableDictionary*)operations;

/**
 NCMBObjectをJSONに変換する
 @param obj NCMBオブジェクト
 */
- (id)convertToJSONFromNCMBObject:(id)obj;

/**
 引数の配列とクラス名からサブクラスor既定クラスorその他のインスタンスを作成する
 @param NSMutableDictionary *result オブジェクトのデータ
 @param NSString *ncmbClassName mobile backend上のクラス名
 */
+ (id)convertClass:(NSMutableDictionary*)result
     ncmbClassName:(NSString*)ncmbClassName;

/**
 リクエストURLを受け取ってdeleteを実行する
 @param url リクエストURL
 @param error エラーを保持するポインタ
 */
- (BOOL)delete:(NSString *)url error:(NSError *__autoreleasing *)error;

/**
 リクエストURLを受け取ってdeleteを実行する。非同期通信を行う。
 @param url リクエストURL
 @param block
 */
- (void)deleteInBackgroundWithBlock:(NSString *)url block:(NCMBErrorResultBlock)userBlock;

/**
 リクエストURLを受け取ってmobile backendにオブジェクトを保存する。非同期通信を行う。
 @param url リクエストURL
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)saveInBackgroundWithBlock:(NSString *)url block:(NCMBErrorResultBlock)userBlock;

/**
 リクエストURLを受け取ってsave処理を実行する
 @param url リクエストURL
 @param エラーを保持するポインタ
 @return 通信が行われたかを真偽値で返却する
 */
- (void)save:(NSString*)url error:(NSError **)error;

/**
 リクエストURLを受け取ってfetchを実行する。非同期通信を行う。
 @param url リクエストURL
 @param userBlock 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)fetchInBackgroundWithBlock:(NSString *)url block:(NCMBErrorResultBlock)userBlock isRefresh:(BOOL)isRefresh;

/**
 リクエストURLを受け取ってfetchを実行する。
 @param url リクエストURL
 @param error エラーを保持するポインタ
 @return 通信が成功した場合にはYESを返す
 */
- (void)fetch:(NSString*)url error:(NSError **)error isRefresh:(BOOL)isRefresh;

/**
 NCMB形式の日付型NSDateFormatterオブジェクトを返す
 */
-(NSDateFormatter*)createNCMBDateFormatter;

/**
 mobile backendからエラーが返ってきたときに最新の操作履歴と通信中の操作履歴をマージする
 @param operations 最新の操作履歴
 */
- (void)mergePreviousOperation:(NSMutableDictionary*)operations;


@end
