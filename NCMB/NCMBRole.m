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

#import "NCMBRole.h"

#import "NCMBUser.h"
#import "NCMBRelation.h"
#import "NCMBQuery.h"

#import "NCMBObject+Private.h"


@interface NCMBRole()

@property (nonatomic) NCMBRelation *users;
@property (nonatomic) NCMBRelation *roles;

@end

@interface NCMBRole()

@end

@implementation NCMBRole

- (NSDictionary*)getLocalData{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super getLocalData]];
    if (_roleName){
        [dic setObject:_roleName forKey:@"roleName"];
    }
    return dic;
}

- (instancetype)init{
    self = [self initWithClassName:@"role"];
    _roles = [self relationforKey:@"belongRole"];
    _users = [self relationforKey:@"belongUser"];
    return self;
}

- (NCMBRole*)initWithRoleName:(NSString*)roleName{
    self = [self init];
    _roleName = roleName;
    [self setObject:_roleName forKey:@"roleName"];
    return self;
}
/**
 指定されたロールの名前で、NCMBRoleインスタンスを作成する
 @param roleName 作成するロールの名前
 @return NCMBRoleのインスタンスを返却
 */
+ (NCMBRole*)roleWithName:(NSString*)roleName {
    return [[NCMBRole alloc] initWithRoleName:roleName];
}

/**
 指定したユーザーをロールに追加する
 @param user 追加する会員
 */
- (void)addUser:(NCMBUser*)user{
    //ロールに属するユーザー情報がNSArrayだった場合はリレーションを新規作成する
    if ([_users isKindOfClass:[NSArray class]]) {
        _users = [self relationforKey:@"belongUser"];
    }
    //プロパティの更新
    [_users addObject:(NCMBObject*)user];
    
}

/**
 指定したロールを子ロールとして追加する
 @param role 追加するロール
 */
- (void)addRole:(NCMBRole*)role{
    //ロールに属する子ロール情報がNSArrayだった場合はリレーションを新規作成する
    if ([_roles isKindOfClass:[NSArray class]]) {
        _roles = [self relationforKey:@"belongRole"];
    }
    //プロパティの更新
    [_roles addObject:(NCMBObject*)role];
}

/**
 子ロールへのリレーションを取得する
 @return 子ロールへのリレーション。設定されていない場合はnilを返却する
 */
- (NCMBRelation*)relationForRole{
    if ([_roles isKindOfClass:[NCMBRelation class]]){
        return _roles;
    } else {
        return nil;
    }
}

/**
 ロールに属した会員へのリレーションを取得する
 @return ロールに属した会員へのリレーション。設定されていない場合はnilを返却する
 */
- (NCMBRelation*)relationForUser{
    if ([_users isKindOfClass:[NCMBRelation class]]){
        return _users;
    } else {
        return nil;
    }
}

#pragma mark override

- (void)afterFetch:(NSMutableDictionary *)response isRefresh:(BOOL)isRefresh{
    [super afterFetch:response isRefresh:isRefresh];
    if ([response objectForKey:@"belongRole"]){
        _roles = [self convertToNCMBObjectFromJSON:[response objectForKey:@"belongRole"] convertKey:@"belongRole"];
    }
    if ([response objectForKey:@"belongUser"]){
        _users = [self convertToNCMBObjectFromJSON:[response objectForKey:@"belongUser"] convertKey:@"belongUser"];
    }
    if ([response objectForKey:@"roleName"]){
        _roleName = [response objectForKey:@"roleName"];
    }
}

- (void)afterDelete{
    [super afterDelete];
    _roleName = nil;
    _users = nil;
    _roles = nil;
}

#pragma mark query

+ (NCMBQuery*)query{
    return [NCMBQuery queryWithClassName:@"role"];
}

@end
