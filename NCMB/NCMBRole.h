//
//  NCMBRole.h
//  NCMB
//
//  Created by SCI01433 on 2014/10/07.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBObject.h"

@class NCMBQuery;
@class NCMBUser;
@class NCMBRelation;

@interface NCMBRole : NCMBObject

@property (nonatomic, readonly) NSString *roleName;

/**
 指定されたロールの名前で、NCMBRoleインスタンスを作成する
 @param roleName 作成するロールの名前
 @return NCMBRoleのインスタンスを返却
 */
+ (NCMBRole*)roleWithName:(NSString*)roleName;

/**
 指定したユーザーをロールに追加する
 @param user 追加する会員
 */
- (void)addUser:(NCMBUser*)user;

/**
 指定したロールを子ロールとして追加する
 @param role 追加するロール
 */
- (void)addRole:(NCMBRole*)role;

/**
 NCMBQueryインスタンスを新規作成する
 @return roleクラスがセットされたNCMBQueryインスタンスを返却する
 */
+ (NCMBQuery*)query;

@end
