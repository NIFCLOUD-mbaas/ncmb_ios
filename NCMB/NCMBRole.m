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

- (NCMBRole*)initWithRoleName:(NSString*)roleName{
    self = [super initWithClassName:@"role"];
    _roleName = roleName;
    [self setObject:_roleName forKey:@"roleName"];
    _roles = [self relationforKey:@"belongRole"];
    _users = [self relationforKey:@"belongUser"];
    //_roles = [[NCMBRelation alloc] initWithClassName:@"role"];
    //_users = [[NCMBRelation alloc] initWithClassName:@"user"];
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
 mobile backendにオブジェクトを保存する
 @param error エラーを保持するポインタ
 @return result 通信が実行されたらYESを返す
 */
- (BOOL)save:(NSError **)error{
    NSString *url = [NSString stringWithFormat:@"roles"];
    BOOL result = [self save:url error:error];
    return result;
}

- (void)saveInBackgroundWithBlock:(NCMBSaveResultBlock)userBlock{
    NSString *url = [NSString stringWithFormat:@"roles"];
    [self saveInBackgroundWithBlock:url block:userBlock];
}

- (void)afterDelete{
    [super afterDelete];
    _roleName = nil;
    _users = nil;
    _roles = nil;
}

/**
 mobile backendからロールを削除し、プロパティもリセットする
 @param error エラーを保持するポインタ
 @return result 通信が実行されたらYESを返す
 */
- (BOOL)delete:(NSError **)error{
    NSString *url = [NSString stringWithFormat:@"roles/%@", self.objectId];
    BOOL result = [self delete:url error:error];
    return result;
}

- (void)deleteInBackgroundWithBlock:(NCMBDeleteResultBlock)userBlock{
    NSString *url = [NSString stringWithFormat:@"roles/%@", self.objectId];
    [self deleteInBackgroundWithBlock:url block:userBlock];
}

/**
 指定したユーザーをロールに追加する
 @param user 追加する会員
 */
- (void)addUser:(NCMBUser*)user{
    //プロパティの更新
    [_users addObject:(NCMBObject*)user];
    
}

/**
 指定したロールを子ロールとして追加する
 @param role 追加するロール
 */
- (void)addRole:(NCMBRole*)role{
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

/**
 ロールの内容を取得する
 @param error エラーを保持するポインタ
 */
- (BOOL)fetch:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"roles/%@", self.objectId];
        [self fetch:url error:error isRefresh:NO];
        result = YES;
    }
    return result;
}

- (void)fetchInBackgroundWithBlock:(NCMBFetchResultBlock)block{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"roles/%@", self.objectId];
        [self fetchInBackgroundWithBlock:url block:block isRefresh:NO];
    }
}

- (BOOL)refresh:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"roles/%@", self.objectId];
        [self fetch:url error:error isRefresh:YES];
        result = YES;
    }
    return result;
}

- (void)refreshInBackgroundWithBlock:(NCMBFetchResultBlock)block{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"roles/%@", self.objectId];
        [self fetchInBackgroundWithBlock:url block:block isRefresh:YES];
    }
}

+ (NCMBQuery*)query{
    return [NCMBQuery queryWithClassName:@"role"];
}

@end
