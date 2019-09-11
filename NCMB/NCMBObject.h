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
@class NCMBRelation;
@class NCMBUser;
@class NCMBRole;
@class NCMBACL;


/**
 NCMBObjectクラスは、ニフクラ mobile backendとアプリ間のデータの送受信を管理するクラスです。 
 アプリケーション内オブジェクトの取得・保存・削除などを管理するメインのクラスです。
 */
@interface NCMBObject : NSObject{
    NSMutableArray *operationSetQueue;
    NSMutableDictionary *estimatedData;
    NSMutableDictionary *serverData;
}


/** @name Create */

/**
 クラス名を指定してNCMBObjectのインスタンスを生成
 @param className 指定するクラス名
 */
- (id)initWithClassName:(NSString *)className;

/**
 指定されたクラス名でNCMBObjectのインスタンスを作成する
 @param className 指定するクラス名
 */
+(NCMBObject*)objectWithClassName:(NSString *)className;


/** @name Object */

/// objectId オブジェクトのobjectID（ニフクラ mobile backend上で自動的に生成）
@property (nonatomic) NSString *objectId;

/// updatedAt オブジェクトの更新日時
@property (nonatomic, readonly) NSDate *updateDate;

/// createdAt オブジェクトの登録日時
@property (nonatomic, readonly) NSDate *createDate;

/// ACL オブジェクトのアクセス権限情報
@property (nonatomic) NCMBACL *ACL;

/// ncmbClassName オブジェクトのクラス名
@property (nonatomic, readonly) NSString *ncmbClassName;



/**
 オブジェクトのキーを取得する。
 @return オブジェクトのキーが格納された配列
 */
- (NSArray *)allKeys;

/**
 キーで指定した値を取得する
 @param key 指定するキー
 @return 指定されたキーの値
 */
- (id)objectForKey:(NSString *)key;

/**
 オブジェクトにACLを設定する
 @param acl 設定するACLオブジェクト
 */
//- (void)setACL:(NCMBACL *)acl;

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
 キーで指定した配列に指定したオブジェクトを追加する。オブジェクトの順序は保証されない。 
 
 また、追加したオブジェクトが配列内に既に存在した場合は追加されません。
 @param object 追加するオブジェクト
 @param key 追加する配列のキー
 */
- (void)addUniqueObject:(id)object forKey:(NSString *)key;

/**
 キーで指定した配列に指定した複数のオブジェクトを追加する。オブジェクトの順序は保証されない。
 
 また、追加したオブジェクトが配列内に既に存在した場合は追加されない。
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
 指定したキーに設定された値を全て削除する
 @param key 指定するキー
 */
-(void)removeObjectForKey:(NSString *)key;

/**
 指定したキーのリレーションを取得する
 @param key 指定するキー
 @return NCMBRelationのインスタンス
 */
- (NCMBRelation *)relationforKey:(NSString *)key;

# pragma mark - save
/** @name Save */

/**
 mobile backendにオブジェクトを保存する。エラーをセットし、エラー内容を見る事もできる。
 @param error エラーを保持するポインタ
 */
- (void)save:(NSError **)error;

/**
 mobile backendにオブジェクトを保存する。非同期通信を行う。
 @param userBlock 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)saveInBackgroundWithBlock:(NCMBErrorResultBlock)userBlock;

/**
 非同期通信を利用してmobile backendにオブジェクトを保存する。通信後は指定されたセレクタを実行する。
 @param target APIリクエスト後に実行するターゲット
 @param selector APIリクエスト後に実行するセレクタ
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

/**
 電波状況を見てmobile backendにオブジェクトを保存する。
 
 通信できない場合は、次回オンライン時に保存される。
 
 保存処理が完了する前にアプリが終了した場合は、次回アプリ起動後オンライン時に保存される。
 
 この場合再度処理を実行しても指定したコールバックは実行されない。
 
 @param callback saveEventuallyを実行したあとに呼び出されるcallback。
 
 callbackは次の引数を持つ必要がある（NSError *error）
 
 saveEventually実行時にオフラインだった場合はerrorにnilが渡される
 */
- (void)saveEventually:(NCMBErrorResultBlock)callback;

#pragma mark refresh

/**
 同期通信を利用してmobile backendからobjectIdをキーにしてデータを取得する。 
 
 refreshを実行する前にセットされた値はリセットされる。
 @param error エラーを保持するポインタ
 */
- (void)refresh:(NSError **)error;

/**
 非同期通信を利用してmobile backendからobjectIdをキーにしてデータを取得し、指定されたコールバックを呼び出す。
 
 refreshを実行する前にセットされた値はリセットされる。
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)refreshInBackgroundWithBlock:(NCMBErrorResultBlock)block;

/**
 非同期通信を利用してmobile backendからobjectIdをキーにしてデータを取得し、指定されたセレクタを呼び出す。
 
 refreshを実行する前にセットされた値はリセットされる。
 @param target 呼び出すセレクタのターゲット
 @param selector 実行するセレクタ
 */
- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector;

#pragma mark fetch

/**
 同期通信を利用してmobile backendからobjectIdをキーにしてデータを取得する。 
 
 fetchを実行する前にセットされた値と統合されるが、サーバー上にすでにキーがあった値は上書きされる。
 @param error エラーを保持するポインタ
 */
- (void)fetch:(NSError **)error;

/**
 非同期通信を利用してmobile backendからobjectIdをキーにしてデータを取得し、指定されたコールバックを呼び出す。 
 
 fetchを実行する前にセットされた値と統合されるが、サーバー上にすでにキーがあった値は上書きされる。
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)fetchInBackgroundWithBlock:(NCMBErrorResultBlock)block;

/**
 非同期通信を利用してmobile backendからobjectIdをキーにしてデータを取得し、指定されたセレクタを呼び出す。 
 
 fetchを実行する前にセットされた値と統合されるが、サーバー上にすでにキーがあった値は上書きされる。
 @param target 呼び出すセレクタのターゲット
 @param selector 実行するセレクタ
 */
- (void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector;


#pragma mark delete

/**
 同期通信を利用してオブジェクトをmobile backendとローカル上から削除する。
 @param error エラーを保持するポインタ
 */
- (void)delete:(NSError**)error;


/**
 非同期通信を利用してオブジェクトをmobile backendとローカル上から削除し、指定されたコールバックを呼び出す。
 @param userBlock 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)deleteInBackgroundWithBlock:(NCMBErrorResultBlock)userBlock;


/**
 非同期通信を利用してオブジェクトをmobile backendとローカル上から削除し、指定されたセレクタを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 実行するセレクタ
 */
- (void)deleteInBackgroundWithTarget:(id)target selector:(SEL)selector;

/**
 通信状況を見てmobile backendからオブジェクトを削除する。
 
 通信できない場合は、次回オンライン時に削除される。
 
 削除処理が実行される前にアプリが終了した場合は、次回アプリ起動後オンライン時に削除される。
 
 この場合再度処理を実行しても指定したコールバックは実行されない。

 @param callback saveEventuallyを実行したあとに呼び出されるcallback。
 
 callbackは次の引数を持つ必要がある（NSError *error）
 
 deleteEventually実行時にオフラインだった場合はerrorにnilが渡される
 */
- (void)deleteEventually:(NCMBErrorResultBlock)callback;

@end
