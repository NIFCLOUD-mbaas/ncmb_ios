/*
 Copyright 2017-2018 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMBACL.h"

#import "NCMBUser.h"
#import "NCMBRole.h"

@implementation NCMBACL

static NCMBACL *defaultACL;

#define READ @"read"
#define WRITE @"write"

#pragma mark init

- (instancetype)init{
    self = [super init];
    if (self){
        _dicACL = [NSMutableDictionary dictionary];
        _isDirty = NO;
    }
    return self;
}

/**
 NCMBACLのインスタンスを生成。デフォルトでは全ての権限が許可されている。
 */
+ (NCMBACL *)ACL{
    if ([defaultACL isKindOfClass:[NCMBACL class]]){
        return defaultACL;
    }
    NCMBACL *acl = [[NCMBACL alloc] init];
    return acl;
}

/**
 指定したユーザのみ読込書込権限が許可されたNCMBACLのインスタンスを生成。
 @param user 権限を設定するユーザ
 */
+ (NCMBACL *)ACLWithUser:(NCMBUser *)user{
    NCMBACL *acl = [[NCMBACL alloc] init];
    [acl setReadAccess:YES forUser:user];
    [acl setWriteAccess:YES forUser:user];
    
    return acl;
}

/**
 
 オブジェクト生成時にACLが指定されなかった場合のデフォルトACLをaclで指定したアクセス権限に設定する。currentUserAccessがYESの場合は、さらにオブジェクトを生成したユーザーに読込書込権限を設定する。NOの場合はaclで指定されたアクセス権限のみが設定される。
 @param acl アクセス権限情報
 @param currentUserAccess YESの場合は、aclで指定されたアクセス権限に加えてオブジェクトを生成したユーザーに読込書込権限を設定、
 NOの場合は、aclで指定されたアクセス権限のみを設定する。
 */
+ (void)setDefaultACL:(NCMBACL *)acl withAccessForCurrentUser:(BOOL)currentUserAccess{
    if (currentUserAccess){
        [acl setReadAccess:YES forUser:[NCMBUser currentUser]];
    }
    defaultACL = acl;
}

#pragma mark Public ACL

/** @name Public Access */

/**
 パブリックな読込権限を設定
 @param allowed 読込権限の設定（YES:許可／NO:許可取り消し）
 */
- (void)setPublicReadAccess:(BOOL)allowed{
    _isDirty = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([self.dicACL objectForKey:@"*"]) {
        [dic setDictionary:[self.dicACL objectForKey:@"*"]];
    }
    if (allowed) {
        [dic setObject:[NSNumber numberWithBool:allowed] forKey:READ];
        [self.dicACL setObject:dic forKey:@"*"];
    }else{
        if ([dic objectForKey:WRITE]) {
            [dic removeObjectForKey:READ];
            [self.dicACL setObject:dic forKey:@"*"];
        }else{
            [self.dicACL removeObjectForKey:@"*"];
        }
    }
}

/**
 パブリックな読込権限の有無を取得
 */
- (BOOL)isPublicReadAccess{
    if ([[_dicACL allKeys] containsObject:@"*"]){
        NSDictionary *publicACL = [_dicACL objectForKey:@"*"];
        if ([publicACL objectForKey:@"read"]){
            return YES;
        }
    }
    return NO;
}

/**
 パブリックな書込権限を設定
 @param allowed 書込権限の設定（YES:許可／NO:許可取り消し）
 */
- (void)setPublicWriteAccess:(BOOL)allowed{
    _isDirty = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([self.dicACL objectForKey:@"*"]) {
        [dic setDictionary:[self.dicACL objectForKey:@"*"]];
    }
    if (allowed) {
        [dic setObject:[NSNumber numberWithBool:allowed] forKey:WRITE];
        [self.dicACL setObject:dic forKey:@"*"];
    }else{
        if ([dic objectForKey:READ]) {
            [dic removeObjectForKey:WRITE];
            [self.dicACL setObject:dic forKey:@"*"];
        }else{
            [self.dicACL removeObjectForKey:@"*"];
        }
    }
}

/**
 パブリックな書込権限の有無を取得
 */
- (BOOL)isPublicWriteAccess{
    NSDictionary *publicACL = [_dicACL objectForKey:@"*"];
    if ([publicACL objectForKey:@"write"]){
        return YES;
    } else {
        return NO;
    }
}


#pragma mark ACL for Role

/** @name Role Access */

/**
 指定した名前を持つロールの読込権限の有無を取得
 @param name 読込権限の有無を調べるロール名
 */
- (BOOL)isReadAccessForRoleWithName:(NSString *)name{
    NSString *roleName = [NSString stringWithFormat:@"role:%@",name];
    return [[[self.dicACL objectForKey:roleName] objectForKey:READ] boolValue];
}

/**
 指定した名前を持つロールの読込権限を設定
 @param allowed 読込権限の設定（YES:許可／NO:許可取り消し）
 @param name 読込権限を設定するロール名
 */
- (void)setReadAccess:(BOOL)allowed forRoleWithName:(NSString *)name{
    _isDirty = YES;
    NSString *roleName = [NSString stringWithFormat:@"role:%@",name];
    
    NSMutableDictionary *dic  = [NSMutableDictionary dictionary];
    if ([self.dicACL objectForKey:roleName]) {
        [dic setDictionary:[self.dicACL objectForKey:roleName]];
    }
    if (allowed) {
        [dic setObject:[NSNumber numberWithBool:allowed] forKey:READ];
        [self.dicACL setObject:dic forKey:roleName];
        
        if ([self.dicACL objectForKey:@"*"]) {
            [[self.dicACL objectForKey:@"*"] removeObjectForKey:READ];
            if ([[[self.dicACL objectForKey:@"*"] allKeys] count]==0) {
                [self.dicACL removeObjectForKey:@"*"];
            }
            
        }
    }else{
        if ([dic objectForKey:WRITE]) {
            [dic removeObjectForKey:READ];
            [self.dicACL setObject:dic forKey:roleName];
        }else{
            [self.dicACL removeObjectForKey:roleName];
        }
    }
}

/**
 指定した名前を持つロールの書込権限の有無を取得
 @param name 書込権限の有無を調べるロール名
 */
- (BOOL)isWriteAccessForRoleWithName:(NSString *)name{
    NSString *roleName = [NSString stringWithFormat:@"role:%@",name];
    return [[[self.dicACL objectForKey:roleName] objectForKey:WRITE] boolValue];
}

/**
 指定した名前を持つロールの書込権限を設定
 @param allowed 書込権限の設定（YES:許可／NO:許可取り消し）
 @param name 書込権限を設定するロール名
 */
- (void)setWriteAccess:(BOOL)allowed forRoleWithName:(NSString *)name{
    _isDirty = YES;
    NSString *roleName = [NSString stringWithFormat:@"role:%@",name];
    NSMutableDictionary *dic  = [NSMutableDictionary dictionary];
    if ([self.dicACL objectForKey:roleName]) {
        [dic setDictionary:[self.dicACL objectForKey:roleName]];
    }
    if (allowed) {
        [dic setObject:[NSNumber numberWithBool:allowed] forKey:WRITE];
        [self.dicACL setObject:dic forKey:roleName];
        if ([self.dicACL objectForKey:@"*"]) {
            [[self.dicACL objectForKey:@"*"] removeObjectForKey:WRITE];
            if ([[[self.dicACL objectForKey:@"*"] allKeys] count]==0) {
                [self.dicACL removeObjectForKey:@"*"];
            }
            
        }
        
    }else{
        if ([dic objectForKey:READ]) {
            [dic removeObjectForKey:WRITE];
            [self.dicACL setObject:dic forKey:roleName];
        }else{
            [self.dicACL removeObjectForKey:roleName];
        }
    }
}

/**
 指定したロールの読込権限の有無を取得
 @param  role 読込権限の有無を調べるロール
 */
- (BOOL)isReadAccessForRole:(NCMBRole *)role{
    return [self isReadAccessForRoleWithName:role.roleName];
}

/**
 指定したロールの読込権限を設定
 @param allowed 読込権限の設定（YES:許可／NO:許可取り消し）
 @param role 読込権限を設定するロール
 */
- (void)setReadAccess:(BOOL)allowed forRole:(NCMBRole *)role{
    [self setReadAccess:allowed forRoleWithName:role.roleName];
}

/**
 指定したロールの書込権限の有無を取得
 @param role 書込権限の有無を調べるロール
 */
- (BOOL)isWriteAccessForRole:(NCMBRole *)role{
    return [self isWriteAccessForRoleWithName:role.roleName];
}

/**
 指定したロールの書込権限を設定
 @param allowed 書込権限の設定（YES:許可／NO:許可取り消し）
 @param role 書込権限を設定するロール
 */
- (void)setWriteAccess:(BOOL)allowed forRole:(NCMBRole *)role{
    [self setWriteAccess:allowed forRoleWithName:role.roleName];
}

#pragma mark ACL for User

/** @name User Access */

/**
 指定したIDに対応するユーザーの読込権限を設定
 @param allowed 読込権限の設定（YES:許可／NO:許可取り消し）
 @param userId 読込権限を設定するユーザID
 */
- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId{
    _isDirty = YES;
    //既存のACLを取り出す
    NSMutableDictionary *dic  = [NSMutableDictionary dictionary];
    if ([self.dicACL objectForKey:userId]) {
        [dic setDictionary:[self.dicACL objectForKey:userId]];
    }
    
    if (allowed) {
        [dic setObject:[NSNumber numberWithBool:allowed] forKey:READ];
        [self.dicACL setObject:dic forKey:userId];
        if ([self.dicACL objectForKey:@"*"]) {
            [[self.dicACL objectForKey:@"*"] removeObjectForKey:READ];
            if ([[[self.dicACL objectForKey:@"*"] allKeys] count]==0) {
                [self.dicACL removeObjectForKey:@"*"];
            }
            
        }
    }else{
        if ([dic objectForKey:WRITE]) {
            [dic removeObjectForKey:READ];
            [self.dicACL setObject:dic forKey:userId];
        }else{
            [self.dicACL removeObjectForKey:userId];
        }
    }
}

/**
 指定したIDに対応するユーザーの読込権限の有無を取得
 @param userId 読込権限の有無を調べるユーザID
 */
- (BOOL)isReadAccessForUserId:(NSString *)userId{
    return [[[self.dicACL objectForKey:userId] objectForKey:READ] boolValue];
}

/**
 指定したIDに対応するユーザーの書込権限を設定
 @param allowed 書込権限の設定（YES:許可／NO:許可取り消し）
 @param userId 書込権限を設定するユーザID
 */
- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId{
    _isDirty = YES;
    NSMutableDictionary *dic  = [NSMutableDictionary dictionary];
    if ([self.dicACL objectForKey:userId]) {
        [dic setDictionary:[self.dicACL objectForKey:userId]];
    }
    
    if (allowed) {
        [dic setObject:[NSNumber numberWithBool:allowed] forKey:WRITE];
        [self.dicACL setObject:dic forKey:userId];
        if ([self.dicACL objectForKey:@"*"]) {
            [[self.dicACL objectForKey:@"*"] removeObjectForKey:WRITE];
            if ([[[self.dicACL objectForKey:@"*"] allKeys] count]==0) {
                [self.dicACL removeObjectForKey:@"*"];
            }
        }
        
    }else{
        if ([dic objectForKey:READ]) {
            [dic removeObjectForKey:WRITE];
            [self.dicACL setObject:dic forKey:userId];
        }else{
            [self.dicACL removeObjectForKey:userId];
        }
    }
}

/**
 指定したIDに対応するユーザーの書込権限の有無を取得
 @param userId 書込権限の有無を調べるユーザID
 */
- (BOOL)isWriteAccessForUserId:(NSString *)userId{
    return [[[self.dicACL objectForKey:userId] objectForKey:WRITE] boolValue];
}

/**
 指定したユーザーの読込権限を設定
 @param allowed 読込権限の設定（YES:許可／NO:許可取り消し）
 @param user 読込権限を設定するユーザ
 */
- (void)setReadAccess:(BOOL)allowed forUser:(NCMBUser *)user{
    [self setReadAccess:allowed forUserId:[user objectId]];
}

/**
 指定したユーザーの読込権限の有無を取得
 @param user 読込権限の有無を調べるユーザ
 */
- (BOOL)isReadAccessForUser:(NCMBUser *)user{
    return [self isReadAccessForUserId:[user objectId]];
}

/**
 指定したユーザーの書込権限を設定
 @param allowed 書込権限の設定（YES:許可／NO:許可取り消し）
 @param user 書込権限を設定するユーザ
 */
- (void)setWriteAccess:(BOOL)allowed forUser:(NCMBUser *)user{
    [self setWriteAccess:allowed forUserId:[user objectId]];
}

/**
 指定したユーザーの書込権限の有無を取得
 @param user 書込権限の有無を調べるユーザ
 */
- (BOOL)isWriteAccessForUser:(NCMBUser *)user{
    return [self isWriteAccessForUserId:[user objectId]];
}


@end
