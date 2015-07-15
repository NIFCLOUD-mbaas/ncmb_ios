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

//Googleのライブラリがある場合はビルド対象に含める
#if defined(__has_include)
#if __has_include(<GoogleSignIn/GoogleSignIn.h>)

#import "NCMBGoogleUtils.h"

#define AUTH_TYPE_GOOGLE                @"google"
#define AUTHDATA_ID_KEY                 @"id"
#define AUTHDATA_ACCESS_TOKEN_KEY       @"access_token"

@interface NCMBGoogleUtils ()

@end

@implementation NCMBGoogleUtils

//ライブラリ用コールバック
static NCMBGoogleUtils *googleUtils = nil;
//ユーザ用コールバック
static NCMBUserResultBlock userBlock = nil;
static NCMBUser *linkUser = nil;

#pragma mark isLinkedWithUser

/**
 引数に指定されたmBaaSの会員情報に、Googleの認証情報が含まれているか確認する
 @param user Googleの認証情報を確認するmBaaSの会員
 @return Googleの会員情報が含まれている場合はYESを返す
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user{
    BOOL isLinkerFlag = NO;
    if ([user objectForKey:@"authData"] && [[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]) {
        if ([[user objectForKey:@"authData"] objectForKey:AUTH_TYPE_GOOGLE]) {
            isLinkerFlag = YES;
        }
    }
    return isLinkerFlag;
}

#pragma mark login With Google Account

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param block mBaaSへの会員登録をリクエスト後に実行されるblock。NCMBUserとNSErrorを引数に持つ。
 */
+ (void)logInWithGoogleAccountWithBlock:(NCMBUserResultBlock)block{
    //ライブラリのコールバックを設定
    googleUtils = [[NCMBGoogleUtils alloc]init];
    [GIDSignIn sharedInstance].delegate = googleUtils;//コールバックに自身を設定
    [GIDSignIn sharedInstance].allowsSignInWithWebView = NO;//webViewに遷移しないよう設定
    //ユーザへのコールバックを設定
    userBlock = block;
    
    //認証済:アカウント画面に遷移しない。直接signInコールバックが実行される
    //未認証:アカウント画面に遷移する。承認後signInコールバックが実行される
    [[GIDSignIn sharedInstance] signIn];
}

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param target mBaaSへの会員登録をリクエスト後に実行されるselectorのtarget
 @param selector mBaaSへの会員登録をリクエスト後に実行されるselector
 */
+ (void)logInWithGoogleAccountWithTarget:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self logInWithGoogleAccountWithBlock:^(NCMBUser *user, NSError *error) {
        [ invocation setArgument:&user atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

#pragma mark linkUser

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param user Googleの認証情報を追加するmBaaSの会員情報
 @param block mBaaSへの会員情報更新をリクエスト後に実行されるblock。NSErrorを引数に持つ。
 */
+(void)linkUser:(NCMBUser*)user googleAccountWithblock:(NCMBUserResultBlock)block{
    //nilやNCMBUser型以外は許容しない
    if (![user isKindOfClass:[NCMBUser class]]){
        if (block){
            NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:400002
                                             userInfo:@{NSLocalizedDescriptionKey:@"User is invalid type."}];
            block(user,error);
        }
        return;
    }
    
    //ライブラリのコールバックを設定
    googleUtils = [[NCMBGoogleUtils alloc]init];
    [GIDSignIn sharedInstance].delegate = googleUtils;//コールバックに自身を設定
    [GIDSignIn sharedInstance].allowsSignInWithWebView = NO;//webViewに遷移しないよう設定
    //ユーザへのコールバックを設定
    userBlock = block;
    linkUser = user;
    //認証済の場合:signInコールバックが実行される
    //未認証の場合:アカウント画面に遷移する。承認後signInコールバックが実行される
    [[GIDSignIn sharedInstance] signIn];
}

/**
 Googleの認証情報を利用してmBaaSへの会員登録を行う
 @param target mBaaSへの会員登録をリクエスト後に実行されるselectorのtarget
 @param selector mBaaSへの会員登録をリクエスト後に実行されるselector
 */
+(void)linkUser:(NCMBUser*)user googleAccountWithTarget:(id)target selector:(SEL)selector
{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self linkUser:user googleAccountWithblock:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

/**
 Googleの認証情報を引数で指定したmBaaSの会員情報から削除する
 @param user Googleの認証情報を削除するmBaaSの会員情報
 @param block mBaaSへの会員情報更新をリクエスト後に実行されるblock。NSErrorを引数に持つ。
 */
+(void)unLinkUser:(NCMBUser*)user withBlock:(NCMBUserResultBlock)block{
    //nilやNCMBUser型以外は許容しない
    if (![user isKindOfClass:[NCMBUser class]]){
        if (block){
            NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:400002
                                             userInfo:@{NSLocalizedDescriptionKey:@"User is invalid type."}];
            block(user,error);
        }
        return;
    }
    
    //UserのGoogle情報を取得し削除する
    if ([[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *authData = nil;
        authData = [NSMutableDictionary dictionaryWithDictionary:[user objectForKey:@"authData"]];
        [authData removeObjectForKey:@"google"];
        [user setObject:authData forKey:@"authData"];
        [user saveInBackgroundWithBlock:^(NSError *error) {
            if (block){
                block(user, error);
            }
        }];
    } else {
        //Google情報がない場合エラーを返す
        if (block){
            NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:404003
                                             userInfo:@{NSLocalizedDescriptionKey:@"google token not found"}];
            block(user,error);
        }
    }
}

/**
 Googleの認証情報を引数で指定したmBaaSの会員情報から削除する
 @param user Googleの認証情報を削除するmBaaSの会員情報
 @param target mBaaSへの会員登録をリクエスト後に実行されるselectorのtarget
 @param selector mBaaSへの会員登録をリクエスト後に実行されるselector
 */
+(void)unLinkUser:(NCMBUser*)user withTarget:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self unLinkUser:user withBlock:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

#pragma mark Utilities

/**
 ライブラリのsignInメソッドコールバック
 取得したGoogle認証情報を元に会員登録またはログインを行う
 */
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if(error==nil){
        //認証成功:google情報を用いてmBaaSに会員登録を行う
        
        //google情報作成
        NSDictionary *googleInfo = [NSMutableDictionary dictionary];
        [googleInfo setValue:user.userID forKey:AUTHDATA_ID_KEY];
        [googleInfo setValue:user.authentication.accessToken forKey:AUTHDATA_ACCESS_TOKEN_KEY];
        
        if(linkUser){
            //リンクユーザ:Google認証のauthData(userID,accessToken)を既存AuthDataに追加して更新
            NCMBUser * user = linkUser;
            linkUser = nil;
            [user signUpWithGoogleToken:googleInfo block:^(NSError *error) {
                if(userBlock){
                    userBlock(user,error);
                }
            }];
        }else{
            //ログイン:新規会員登録 ※mBaaSのサーバー上で同じid(googleInfo内のid)がある場合はログインを行う
            NCMBUser *user = [NCMBUser user];
            [user signUpWithGoogleToken:googleInfo block:^(NSError *error) {
                if(userBlock){
                    userBlock(user,error);
                }
            }];
        }
    }else{
        //認証失敗:コールバックをユーザに返却する
        if(userBlock){
            userBlock(nil,error);
        }
    }
}

/**
 Googleのセッションを削除
 NCMBUserのlogOutEventで使用
 */
+(void)clearGoogleSession{
    [[GIDSignIn sharedInstance] signOut];
    googleUtils = nil;
    userBlock = nil;
    linkUser = nil;
}

@end

#endif
#endif