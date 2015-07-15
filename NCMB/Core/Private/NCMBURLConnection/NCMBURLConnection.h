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
#import <CoreFoundation/CoreFoundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>

@class NCMBUser;

@interface NCMBURLConnection : NSURLConnection

@property(nonatomic) NSString *path;
@property(nonatomic) NSString *method;
@property(nonatomic) NSString *query;
@property(nonatomic) NSString *data;
@property(nonatomic) NSString *timeStamp;

@property(nonatomic) NSString *signature;
@property(nonatomic) NSString *sessionToken;

@property(nonatomic) NSString *appKey;
@property(nonatomic) NSString *cliKey;
@property(nonatomic) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic)NSMutableURLRequest *request;
@property(nonatomic) NSData *fileData;
@property(nonatomic,copy) void (^blockProgress)(NSNumber *progress);
@property(nonatomic,readwrite,strong) NSURLResponse *response;
@property(nonatomic,readwrite,strong) NSMutableData *receivedData;
@property(nonatomic,readwrite) long long estimatedDataSize;
@property(nonatomic,copy) void (^block)(id response, NSError *error);

//コールバック
typedef void (^NCMBProgressBlock)(int percentDone);
typedef void (^NCMBResultBlock)(id response, NSError *error);

/**
 初期化を行う
 @param path APIをリクエストするパス
 @param method リクエストするmethod
 @param data 具体的な通信内容(検索条件、登録内容など)
 */
- (id)initWithPath:(NSString*)path method:(NSString*)method data:(NSData*)data;

/**
 初期化を行う
 @param path APIをリクエストするパス
 @param method リクエストするmethod
 @param data 具体的な通信内容(検索条件、登録内容など)
 @param cachePolicy キャッシュポリシー
 */
- (id)initWithPath:(NSString*)path method:(NSString*)method data:(NSData*)data cachePolicy:(NSURLRequestCachePolicy)cachePolicy;

/**
 初期化を行う。
 @param path APIをリクエストするパス
 @param method リクエストするmethod
 @param data 具体的な通信内容(検索条件、登録内容など)
 @param progress プログレス
 */
- (id)initWithProgress:(NSString*)path method:(NSString*)method data:(NSData*)data progress:(void (^)(NSNumber *progress))progress;

/**
 タイムスタンプを設定するメソッド
 @param timeStamp 設定するタイムスタンプ
 */
- (void)setTimeStamp:(NSString*)timeStamp;

/**
 シグネチャを作成するメソッド
 */
- (void)createSignature;

/**
 通信を行うメソッド
 @param error エラーを格納する
 */
- (id)syncConnection:(NSError**)error;

/**
 非同期通信を行うメソッド
 @param block 非同期通信後に実行するメソッド引数に(NSError *error)を持つ
 */
- (void)asyncConnectionWithBlock:(NCMBResultBlock)block;

/**
 非同期通信を行うメソッド。NCMBFileクラスの通信処理
 @param block 非同期通信後に実行するメソッド引数に(NSError *error)を持つ
 */
- (NSURLConnection *)fileAsyncConnectionWithBlock:(NCMBResultBlock)block;

@end