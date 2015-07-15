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
#import <MobileCoreServices/MobileCoreServices.h>
#import "NCMBObject.h"
//#import "NCMBSubclassing.h"

@class NCMBQuery;
@class NCMBACL;


/**
 NCMBFileクラスは、ニフティクラウドmobile backend上でアプリに必要な画像や動画、様々なバイナリデータを管理するクラスです。
 
 このクラスはNCMBObjectを継承していますが、REST APIでファイルクラスのフィールド更新ができないため、 
 setObject:forKey: や addObject:forKey: などは対応していません。
 対応していないメソッドは以下の通りです。
 
    relationForKey:
    addObject:forKey:
    addObjectsFromArray:forKey:
    addUniqueObject:forKey:
    addUniqueObjectsFromArray:forKey:
    removeObject:forKey:
    removeObjectsInArray:forKey:
    removeObjectForKey:
    incrementKey:
    incrementKey:byAmount:
    saveEventually:
    refresh:
    refreshInBackgroundWithBlock:
    refreshInBackgroundWithTarget:selector:
    fetch:
    fetchInBackgroundWithBlock:
    fetchInBackgroundWithTarget:selector:
    deleteEventually:
 
 */
@interface NCMBFile : NCMBObject

/** @name Properties */

/// ファイル名
@property (readonly) NSString *name;

/// ファイルを取得するためのURL
@property (readonly) NSString *url;


/** @name Create */

/**
 指定したデータ(NSData)を持つNCMBFileのインスタンスを生成
 @param data 指定するデータ(NSData)
 @return id型 NCMBFileのインスタンス
 */
+ (id)fileWithData:(NSData *)data;

/**
 指定したファイル名とデータ(NSData)を持つNCMBFileのインスタンスを生成
 @param name 指定するファイル名
 @param data 指定するデータ(NSData)
 @return id型 NCMBFileのインスタンス
 */
+ (id)fileWithName:(NSString *)name data:(NSData *)data;

/**
 指定したファイルパスで取得したデータと指定したファイル名を持つNCMBFileのインスタンスを生成
 @param name 指定するファイル名
 @param path 指定するファイルパス
 @return id型 NCMBFileのインスタンス
 */
+ (id)fileWithName:(NSString *)name
    contentsAtPath:(NSString *)path;


/// 指定したファイルがサーバ上と同じ内容かどうかを判断。変更があった場合や、生成のみで未保存状態の場合はtrueを返す。サーバにsave済の場合はfalseを返す。
@property (readonly) BOOL isDirty;


/** @name Save */

/**
 データを非同期で保存。保存の進度により定期的にprogressBlockを呼び出し、100パーセントに達し保存がし終わったらblockを呼び出す。
 @param block 保存完了後に実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NSError *error）<br/>errorにはエラーがあればエラーのポインタが渡され、なければnilが渡される。
 @param progressBlock 保存進度により定期的に実行されるblock。blockは次の引数のシグネチャを持つ必要がある（int percentDone）
 */
- (void)saveInBackgroundWithBlock:(NCMBErrorResultBlock)block
                    progressBlock:(NCMBProgressBlock)progressBlock;


/** @name Get */

/// データがあるかどうかを判断。データがあればtrueを返す。
@property (readonly) BOOL isDataAvailable;

/**
 データの取得。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return NSData型 取得データ
 */
- (NSData *)getData:(NSError **)error;

/**
 データを非同期で取得。取得し終わったら与えられたblockを呼び出す。
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NSData *data, NSError *error）
 resultには取得したデータが渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)getDataInBackgroundWithBlock:(NCMBDataResultBlock)block;

/**
 データを非同期で取得。取得の進度により定期的にprogressBlockを呼び出し、100パーセントに達し取得し終わったらresultBlockを呼び出す。
 @param resultBlock 取得完了後に実行されるblock。resultBlockは次の引数のシグネチャを持つ必要がある（NSData *data, NSError *error）
 @param progressBlock 取得進度により定期的に実行されるblock。progressBlockは次の引数のシグネチャを持つ必要がある（int percentDone）
 */
- (void)getDataInBackgroundWithBlock:(NCMBDataResultBlock)resultBlock
                       progressBlock:(NCMBProgressBlock)progressBlock;

/**
 データを非同期で取得。取得し終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSData *)result error:(NSError **)error
 resultには取得したデータが渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)getDataInBackgroundWithTarget:(id)target selector:(SEL)selector;


/** @name Transfer */


/**
 通信のキャンセルを行う
 */
- (void)cancel;


/** @name Query */

/**
 ファイルを検索するためのNCMBQueryを生成
 @return NCMBQueryのインスタンス
 */
+ (NCMBQuery *)query;

#pragma mark - Unsupported

-(void)refresh:(NSError **)error __attribute__((deprecated));
-(void)refreshInBackgroundWithBlock:(NCMBObjectResultBlock)block __attribute__((deprecated));
-(void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector __attribute__((deprecated));
-(void)fetch:(NSError **)error __attribute__((deprecated));
-(NCMBRelation *)relationForKey:(NSString *)key __attribute__((deprecated));
-(void)addObject:(id)object forKey:(NSString *)key __attribute__((deprecated));
-(void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key __attribute__((deprecated));
-(void)addUniqueObject:(id)object forKey:(NSString *)key __attribute__((deprecated));
-(void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key __attribute__((deprecated));
-(void)removeObject:(id)object forKey:(NSString *)key __attribute__((deprecated));
-(void)removeObjectsFromArray:(NSArray *)objects forKey:(NSString *)key __attribute__((deprecated));
-(void)removeObjectForKey:(NSString *)key __attribute__((deprecated));
-(void)incrementKey:(NSString *)key __attribute__((deprecated));
-(void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount __attribute__((deprecated));
-(void)saveEventually:(NCMBErrorResultBlock)callback __attribute__((deprecated));
-(void)deleteEventually:(NCMBErrorResultBlock)callback __attribute__((deprecated));



@end
