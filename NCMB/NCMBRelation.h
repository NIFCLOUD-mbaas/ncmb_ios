//
//  NCMBRelation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/04.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NCMBObject;
@class NCMBQuery;

/**
 NCMBRelationは、オブジェクトの関係を管理するクラスです。
 */
@interface NCMBRelation : NSObject

@property(nonatomic) NCMBObject *parent;
@property(nonatomic) NSString *key;
@property(nonatomic) NSString *targetClass;

/**
 リレーションで示されたオブジェクトのクラス名を指定してクエリを生成
 */
- (NCMBQuery *)query;

/**
 Relation初期化用
 */
- (id)initWithClassName:(NCMBObject *)parent key:(NSString *)key;

/**
 指定されたクラス名を設定したNCMBRelationのインスタンスを返却する
 @param className リレーション先のクラス名
 */
- (id)initWithClassName:(NSString *)className;

/**
 リレーションに指定したオブジェクトを追加
 @param object 指定するオブジェクト
 */
- (void)addObject:(NCMBObject *)object;

/**
 リレーションから指定したオブジェクトを削除
 @param object 指定するオブジェクト
 */
- (void)removeObject:(NCMBObject *)object;

@end
