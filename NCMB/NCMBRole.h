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

@class NCMBQuery;
@class NCMBUser;
@class NCMBRelation;

/**
 NCMBRoleクラスは、会員をグルーピングするロールを作成・取得・削除を行い、
 会員や子ロールの追加・削除ができるようにするものです。
 */
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
 子ロールへのリレーションを取得する
 @return 子ロールへのリレーション。設定されていない場合はnilを返却する
 */
- (NCMBRelation*)relationForRole;

/**
 ロールに属した会員へのリレーションを取得する
 @return ロールに属した会員へのリレーション。設定されていない場合はnilを返却する
 */
- (NCMBRelation*)relationForUser;

/**
 NCMBQueryインスタンスを新規作成する
 @return roleクラスがセットされたNCMBQueryインスタンスを返却する
 */
+ (NCMBQuery*)query;

@end
