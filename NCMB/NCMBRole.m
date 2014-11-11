//
//  NCMBRole.m
//  NCMB
//
//  Created by SCI01433 on 2014/10/07.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

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
    NCMBDEBUGLOG(@"parentObject:%@", _users.parent);
    NCMBDEBUGLOG(@"parentOperation:%@", [_users.parent currentOperations]);
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

- (void)afterFetch:(NSMutableDictionary *)response isRefresh:(BOOL)isRefresh{
    [super afterFetch:response isRefresh:isRefresh];
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
