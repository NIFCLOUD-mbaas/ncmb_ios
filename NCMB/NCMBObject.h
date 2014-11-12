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

#ifdef NCMBTEST
#define NCMBDEBUGLOG(...) NSLog(__VA_ARGS__)
#else
#define NCMBDEBUGLOG(...)
#endif

#ifdef NCMBTEST
#define NCMBWAIT(...) [NSThread sleepForTimeInterval:__VA_ARGS__]
#else
#define NCMBWAIT(...)
#endif

#import <Foundation/Foundation.h>

#import "NCMBConstants.h"

#define DATA_MAIN_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"]
#define COMMAND_CACHE_FOLDER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/Command Cache/", DATA_MAIN_PATH]

@class NCMBRelation;
@class NCMBUser;
@class NCMBRole;
@class NCMBACL;

/**
 NCMBObjectクラスは、ニフティクラウドmobile backendとアプリ間のデータの送受信を管理するクラスです。アプリケーション内オブジェクトの取得・保存・削除などを管理するメインのクラスです。
 */
@interface NCMBObject : NSObject{
    NSMutableArray *operationSetQueue;
    NSMutableDictionary *estimatedData;
    NSMutableDictionary *serverData;
}


/** @name Create */

/**
 クラス名を指定してNCMBObjectのインスタンスを生成
 
 【使用例】
 NCMBObject *testObject = [[NCMBObject alloc]initWithClassName:@"クラス名"];
 @param className 指定するクラス名
 */
- (id)initWithClassName:(NSString *)className;

/**
 指定されたクラス名でNCMBObjectのインスタンスを作成する
 @param className 指定するクラス名
 */
+(NCMBObject*)objectWithClassName:(NSString *)className;


/** @name Object */

/// objectId オブジェクトのobjectID（ニフティクラウドmobile backend上で自動的に生成）
@property (nonatomic) NSString *objectId;

/// updatedAt オブジェクトの更新日時
@property (nonatomic, readonly) NSDate *updatedDate;

/// createdAt オブジェクトの登録日時
@property (nonatomic, readonly) NSDate *createdDate;

/// ACL オブジェクトのアクセス権限情報
@property (nonatomic) NCMBACL *ACL;

/// ncmbClassName オブジェクトのクラス名
@property (nonatomic, readonly) NSString *ncmbClassName;



/**
 オブジェクトのキーを取得。createdAt、updatedAt、objectIdは含まれない。
 */
- (NSArray *)allKeys;

/**
 キーで指定した値を取得
 @param key 指定するキー
 */
- (id)objectForKey:(NSString *)key;

/**
 オブジェクトにACLを設定する
 @param acl 設定するACLオブジェクト
 */
- (void)setACL:(NCMBACL *)acl;

/**
 指定したキーに指定したオブジェクトを設定
 @param object 設定するオブジェクト
 @param key 指定するキー
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 キーで指定された配列の末尾にオブジェクトを追加
 @param object 追加するオブジェクト
 @param key 追加する配列のキー
 */
- (void)addObject:(id)object forKey:(NSString *)key;

/**
 キーで指定された配列の末尾に複数のオブジェクトを追加
 @param objects 追加する複数のオブジェクト
 @param key 追加する配列のキー
 */
- (void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/**
 キーで指定した配列に指定したオブジェクトを追加。オブジェクトの順序は保証されません。また、追加したオブジェクトが配列内に既に存在した場合は追加されません。
 @param object 追加するオブジェクト
 @param key 追加する配列のキー
 */
- (void)addUniqueObject:(id)object forKey:(NSString *)key;

/**
 キーで指定した配列に指定した複数のオブジェクトを追加。オブジェクトの順序は保証されません。また、追加したオブジェクトが配列内に既に存在した場合は追加されません。
 @param objects 追加する複数のオブジェクト
 @param key 追加する配列のキー
 */
- (void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/**
 指定したキーの値に１を足す。未登録のものは新規登録される。デフォルト値は１。
 @param key 指定するキー
 */
- (void)incrementKey:(NSString *)key;

/**
 指定したキーの値にamountで指定した増減値を加える。未登録のものは新規登録される。デフォルトは０に増減値を加えた値になる。
 @param key 指定するキー
 @param amount 増減値
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount;

/**
 指定したキーに設定された値から、指定されたオブジェクトを削除
 @param object 削除するオブジェクト
 @param key 指定するキー
 */
- (void)removeObject:(id)object forKey:(NSString *)key;

/**
 指定したキーに設定された値から、指定された配列に含まれるオブジェクトと一致するものを削除
 @param objects 削除する複数のオブジェクト
 @param key 指定するキー
 */
- (void)removeObjectsInArray:(NSArray *)objects forKey:(NSString *)key;


/**
 指定したキーに設定された値を全て削除
 @param key 指定するキー
 */
-(void)removeObjectForKey:(NSString *)key;

/**
 指定したキーのリレーションを取得
 @param key 指定するキー
 */
- (NCMBRelation *)relationforKey:(NSString *)key;

# pragma mark - save
/** @name Save */

/**
 mobile backendにオブジェクトを保存する。エラーをセットし、エラー内容を見る事もできる。
 @param error エラーを保持するポインタ
 @return result 通信が実行されたらYESを返す
 */
- (BOOL)save:(NSError **)error;

/**
 mobile backendにオブジェクトを保存する。非同期通信を行う。
 @param block 通信後に実行されるblock。引数にBOOL succeeded, NSError *errorを持つ。
 */
- (void)saveInBackgroundWithBlock:(NCMBSaveResultBlock)userBlock;

/**
 mobile backendからobjectIdをキーにしてデータを取得する。非同期通信を行い、通信後は指定されたセレクタを実行する。
 @param selector 実行するセレクタ
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

/**
 objectsにあるNCMBObjectを継承した全てのオブジェクトを保存する。
 @param objects 保存するNCMBObjectが含まれる配列
 @param error APIリクエストについてのエラー
 @return 実行結果の配列を返却する
 */
+ (NSArray*)saveAll:(NSArray*)objects error:(NSError**)error;

/**
 objectsにある、NCMBObjectを継承した全てのオブジェクトを非同期通信で保存する。通信後は渡されたblockを実行する
 @param objects 保存するNCMBObjectが含まれる配列
 @param error APIリクエストについてのエラー
 */
+ (void)saveAllInBackground:(NSArray*)objects withBlock:(NCMBSaveAllResultBlock)userBlock;

/**
 objectsにある、NCMBObjectを継承した全てのオブジェクトを非同期通信で保存する。通信後は指定されたセレクタを実行する
 @param objects 保存するNCMBObjectが含まれる配列
 @param error APIリクエストについてのエラー
 */
+ (void)saveAllInBackground:(NSArray*)objects withTarget:(id)target selector:(SEL)selector;


#pragma mark refresh

/**
 mobile backendからobjectIdをキーにしてデータを取得する。履歴はリセットされる。
 @param error エラーを保持するポインタ
 @return 通信を行った場合にはYESを返す
 */
- (BOOL)refresh:(NSError **)error;

/**
 mobile backendからobjectIdをキーにしてデータを取得する。非同期通信を行う。履歴はリセットされる。
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)refreshInBackgroundWithBlock:(NCMBFetchResultBlock)block;

/**
 mobile backendからobjectIdをキーにしてデータを取得する。非同期通信を行い、通信後は指定されたセレクタを実行する。履歴はリセットされる。
 @param target 呼び出すセレクタのターゲット
 @param selector 実行するセレクタ
 */
- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector;

#pragma mark fetch

/**
 mobile backendからobjectIdをキーにしてデータを取得する
 @param error エラーを保持するポインタ
 @return 通信を行った場合にはYESを返却する
 */
- (BOOL)fetch:(NSError **)error;

/**
 mobile backendからobjectIdをキーにしてデータを取得する。非同期通信を行う。
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)fetchInBackgroundWithBlock:(NCMBFetchResultBlock)block;

/**
 mobile backendからobjectIdをキーにしてデータを取得する。非同期通信を行い、通信後は指定されたセレクタを実行する。
 @param target 呼び出すセレクタのターゲット
 @param selector 実行するセレクタ
 */
- (void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector;


#pragma mark delete

/**
 オブジェクトをmobile backendとローカル上から削除する
 @param error エラーを保持するポインタ
 */
- (BOOL)delete:(NSError**)error;


/**
 オブジェクトをmobile backendとローカル上から削除する。非同期通信を行う。
 @param error block 通信後に実行されるblock。引数にBOOL succeeded, NSError *errorを持つ。
 */
- (void)deleteInBackgroundWithBlock:(NCMBDeleteResultBlock)userBlock;


/**
 オブジェクトをmobile backendとローカル上から削除する。非同期通信を行い、通信後は指定されたセレクタを実行する。
 @param target 呼び出すセレクタのターゲット
 @param selector 実行するセレクタ
 */
- (void)deleteInBackgroundWithTarget:(id)target selector:(SEL)selector;

@end
