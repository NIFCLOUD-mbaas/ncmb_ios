//
//  NCMBAnonymousUtils.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/10.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBAnonymousUtils.h"
#import "NCMBUser.h"
#import "NCMBUser+Private.h"

@implementation NCMBAnonymousUtils

#define AUTH_TYPE_ANONYMOUS     @"anonymous"

#pragma mark link

/**
 指定したユーザが匿名ユーザかどうか判定。匿名ユーザの場合はtrueを返す。
 @param user 指定するユーザ
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user{
    BOOL isLinkerFlag = NO;
    if ([user objectForKey:@"authData"] && [[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]) {
        if ([[user objectForKey:@"authData"] objectForKey:AUTH_TYPE_ANONYMOUS] && user.password == nil) {
            isLinkerFlag = YES;
        }
    }
    return isLinkerFlag;
}

#pragma mark logIn

/**
 匿名ユーザでログイン(同期)。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 */
+ (NCMBUser *)logIn:(NSError **)error{
    NCMBUser *user = [NCMBAnonymousUtils createAnonymousUser];
    [user signUp:error];
    return user;
}

/**
 匿名ユーザでログイン(非同期)。ログインし終わったら与えられたblockを呼び出す。
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NCMBUser *user, NSError *errorr） userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithBlock:(NCMBUserResultBlock)block{
    NCMBUser *user = [NCMBAnonymousUtils createAnonymousUser];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block) {
            block(user,error);
        }
    }];
}

/**
 匿名ユーザでログイン(非同期)。ログインし終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。(void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザの情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTarget:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self logInWithBlock:^(NCMBUser *user, NSError *error)  {
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

#pragma mark create

/**
 端末固有のIDを生成する
 二度取得すると異なる値が返るので、クラウドとローカルで保持する
 @return NSString型UUID
 */
+ (NSString*) createUUID {
    //iOS5以前向けで作成
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    //NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);//CFUUIDはARC管理対象外のため使用後リファレンスカウンタを減らす
    return uuidString;
}

/**
 ログインするための匿名ユーザーを作成する
 @return NCMBUser匿名ユーザー
 */
+ (NCMBUser *) createAnonymousUser {
    NCMBUser *user = [NCMBUser user];
    //UUIDを使用してローカルにセットする　例:authData:{anonymous={id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";};}
    NSMutableDictionary *anonymousDic = [NSMutableDictionary dictionary];
    [anonymousDic setObject:[@{@"id":[self createUUID]}mutableCopy] forKey:AUTH_TYPE_ANONYMOUS];
    [user setObject:anonymousDic forKey:@"authData"];
    return user;
}



@end
