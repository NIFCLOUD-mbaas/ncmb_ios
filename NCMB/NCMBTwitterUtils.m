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

#import "NCMBTwitterUtils.h"
#import "NCMBUser+Private.h"
#import "NCMBURLConnection.h"
#import "NCMBAnonymousUtils.h"
#import "NCMBACL.h"

#import "NCMBConstants.h"

#define AUTH_TYPE_TWITTER               @"twitter"
#define AUTHDATA_ID_KEY                 @"id"
#define AUTHDATA_SCREEN_NAME_KEY        @"screen_name"
#define AUTHDATA_OAUTH_CONSUMER_KEY     @"oauth_consumer_key"
#define AUTHDATA_SECRET_CONSUMER_KEY    @"consumer_secret"
#define AUTHDATA_OAUTH_TOKEN_KEY        @"oauth_token"
#define AUTHDATA_OAUTH_TOKEN_SECRET     @"oauth_token_secret"

@interface NCMB_Twitter()
-(void)checkTwitterId:(NSString *)twitterId
           screenName:(NSString *)screenName
            authToken:(NSString*)authToken
      authTokenSecret:(NSString*)authTokenSecret
              handler:(void(^)(BOOL isCallated, NSError* error))handler;
+(NCMB_Twitter*)sharedInstace;
@end

@implementation NCMBTwitterUtils
static NCMB_Twitter* _twitter = nil;

#pragma mark - init

/**
 NCMB_Twitterオブジェクトを返す
 @return NCMB_Twitter
 */
+ (NCMB_Twitter *)twitter{
    if(!_twitter) _twitter = [NCMB_Twitter sharedInstace];
    return _twitter;
}

/**
 twitterの初期化
 @param consumerKey twitterアプリのconsumerKey
 @param consumerSecret twitterアプリのconsumerSecret
 */
+ (void)initializeWithConsumerKey:(NSString *)consumerKey
                   consumerSecret:(NSString *)consumerSecret{
    NCMB_Twitter* twitter = [NCMBTwitterUtils twitter];
    twitter.consumerKey = consumerKey;
    twitter.consumerSecret = consumerSecret;
}

#pragma mark - authData

/**
 authDataの作成
 @param twitterId ユーザにリンクさせるtwitterアカウントのtwitterID
 @param screenName ユーザにリンクさせるtwitterアカウントのscreenName
 @param authToken ユーザにリンクさせるtwitterアカウントのaccessToken
 @param authTokenSecret ユーザにリンクさせるtwitterアカウントのauthTokenSecret
 @return NSDictionary型authData
 */
+(NSDictionary*)createAuthData:(NSString*)twitterId screenName:(NSString*)screenName authToken:(NSString*)authToken authTokenSecret:(NSString*)authTokenSecret{
    NSString* consumerKey = [self twitter].consumerKey;
    NSString* secretConsumerKey = [self twitter].consumerSecret;
    NSDictionary* authData = @{AUTHDATA_ID_KEY              :   twitterId,
                               AUTHDATA_SCREEN_NAME_KEY     :   screenName,
                               AUTHDATA_OAUTH_CONSUMER_KEY  :   consumerKey,
                               AUTHDATA_SECRET_CONSUMER_KEY :   secretConsumerKey,
                               AUTHDATA_OAUTH_TOKEN_KEY     :   authToken,
                               AUTHDATA_OAUTH_TOKEN_SECRET  :   authTokenSecret};
    return authData;
}


#pragma mark - logIn

/**
 authTokenの取得可否判定
 @param block
 */
+ (void)logInToTwitterWithBlock:(NCMBUserResultBlock)block{
    NCMB_Twitter* tw = [self twitter];
    [tw authorizeWithSuccess:^{
        [self logInWithTwitterId:tw.userId screenName:tw.screenName authToken:tw.authToken authTokenSecret:tw.authTokenSecret block:block check:NO];
    } failure:^(NSError *error) {
        if(block)block(nil,error);
    } cancel:^{
        if(block)block(nil,nil);
    }];
}

/**
 twitterを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithBlock:(NCMBUserResultBlock)block{
    if([NCMBUser currentUser]&&[NCMBTwitterUtils isLinkedWithUser:[NCMBUser currentUser]]){
        NSDictionary* authData = [[NCMBUser currentUser] objectForKey:@"authData"];
        NSDictionary* twitterAuth = authData[AUTH_TYPE_TWITTER];
        NSString* twitterId = twitterAuth[AUTHDATA_ID_KEY];
        NSString* screenName = twitterAuth[AUTHDATA_SCREEN_NAME_KEY];
        NSString* authToken = twitterAuth[AUTHDATA_OAUTH_TOKEN_KEY];
        NSString* authTokenSecret = twitterAuth[AUTHDATA_OAUTH_TOKEN_SECRET];
        
        [[self twitter] checkTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret handler:^(BOOL isCallated, NSError *error) {
            if(isCallated){
                [self logInWithTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:block check:NO];
            }else{
                [self logInToTwitterWithBlock:block];
            }
        }];
    }else{
        [self logInToTwitterWithBlock:block];
    }
}

/**
 twitterを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTarget:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self logInWithBlock:^(NCMBUser *user, NSError *error) {
        [ invocation setArgument:&user atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

/**
 twitterを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param twitterId ログインさせるtwitterアカウントのtwitterID
 @param screenName ログインさせるtwitterアカウントのscreenName
 @param authToken ログインさせるtwitterアカウントのaccessToken
 @param authTokenSecret ログインさせるtwitterアカウントのauthTokenSecret
 @param block ログイン後実行されるblock
 @param check Twitter情報の確認フラグ
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                     block:(NCMBUserResultBlock)block
                     check:(BOOL)check{
    if(check){
        //Twitter情報の確認が出来ていない場合は、確認しTwitter情報を更新する
        [[self twitter] checkTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret handler:^(BOOL isCallated, NSError *error) {
            if(isCallated){
                [self logInWithTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:block check:NO];
            }else{
                if(block)block(nil,error);
            }
        }];
    }else{
        //Twitter情報の確認が出来ている場合ユーザーの新規登録または更新を行う
        NCMBUser* currentUser = [NCMBUser currentUser];
        NSDictionary* authData = [self createAuthData:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret];
        //ログインしている、かつ匿名ユーザーか判定
        if(currentUser&&[NCMBAnonymousUtils isLinkedWithUser:currentUser]){
            //ログイン済の場合は更新
            [currentUser setObject:@{AUTH_TYPE_TWITTER:authData} forKey:@"authData"];
            [currentUser signUpInBackgroundWithBlock:^(NSError *error) {
                if(block){
                    block(currentUser,error);
                }
            }];
        }else{
            //未ログインの場合は新規登録
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:authData forKey:AUTH_TYPE_TWITTER];
            
            NCMBUser *user = [NCMBUser user];
            [user setObject:dic forKey:@"authData"];
            [user signUpInBackgroundWithBlock:^(NSError *error) {
                if(!error){
                    //[user dataLocalSave:TRUE];
                    if(block)block(user,nil);
                }else
                    if(block)block(nil,error);
            }];
        }
        
    }
}

/**
 twitterを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param twitterId ログインさせるtwitterアカウントのtwitterID
 @param screenName ログインさせるtwitterアカウントのscreenName
 @param authToken ログインさせるtwitterアカウントのaccessToken
 @param authTokenSecret ログインさせるtwitterアカウントのauthTokenSecret
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                     block:(NCMBUserResultBlock)block{
    [self logInWithTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:block check:YES];
}

/**
 twitterを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param twitterId ログインさせるtwitterアカウントのtwitterID
 @param screenName ログインさせるtwitterアカウントのscreenName
 @param authToken ログインさせるtwitterアカウントのaccessToken
 @param authTokenSecret ログインさせるtwitterアカウントのauthTokenSecret
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                    target:(id)target
                  selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self logInWithTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:^(NCMBUser *user, NSError *error) {
        [ invocation setArgument:&user atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

#pragma mark - link

/**
 指定したユーザがtwitter連携されているかを判断。twitter連携されている場合は、trueを返す。
 @param user 指定するユーザ
 @return BOOL型 ログイン中のユーザーがtwitterユーザーの場合YESを返す
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user{
    BOOL isLinkerFlag = NO;
    if ([user objectForKey:@"authData"] && [[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]) {
        if ([[user objectForKey:@"authData"] objectForKey:AUTH_TYPE_TWITTER]) {
            isLinkerFlag = YES;
        }
    }
    return isLinkerFlag;
}

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user block:(NCMBErrorResultBlock)block{
    NCMB_Twitter* tw = [self twitter];
    [tw authorizeWithSuccess:^{
        [self linkUser:user twitterId:tw.userId screenName:tw.screenName authToken:tw.authToken authTokenSecret:tw.authTokenSecret block:block check:NO];
    } failure:^(NSError *error) {
        if(block)block(error);
    } cancel:^{
        if(block)block(nil);
    }];
}

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 ((NSError **)error)
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
          target:(id)target
        selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self linkUser:user block:^(NSError *error) {
        [ invocation setArgument:&error atIndex: 2 ];
        [ invocation invoke ];
    }];
}

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param twitterId ユーザにリンクさせるtwitterアカウントのtwitterID
 @param screenName ユーザにリンクさせるtwitterアカウントのscreenName
 @param authToken ユーザにリンクさせるtwitterアカウントのaccessToken
 @param authTokenSecret ユーザにリンクさせるtwitterアカウントのauthTokenSecret
 @param block 通信後実行されるblock。
 @param check Twitter情報の確認
 */
+ (void)linkUser:(NCMBUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
           block:(NCMBErrorResultBlock)block
           check:(BOOL)check
{
    if(check){
        [[self twitter] checkTwitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret handler:^(BOOL isCallated, NSError *error) {
            if(isCallated){
                [self linkUser:user twitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:block check:NO];
            }else{
                if(block)block(error);
            }
        }];
    }else{
        NSDictionary* authData = [self createAuthData:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret];
        NCMBURLConnection *request = [self updateRequestWithUser:user authData:authData];
        [request asyncConnectionWithBlock:^(NSDictionary *responseDic, NSError *errorBlock){
            BOOL succees = YES;
            if(errorBlock){
                succees = NO;
            }else{
                NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseDic];
                [mutableResponse setValue:@{AUTH_TYPE_TWITTER:authData} forKey:@"authData"];
                [user afterSave:mutableResponse operations:nil];
                [NCMBUser saveToFileCurrentUser:user];
            }
            if (block) {
                block(errorBlock);
            }
        }];
    }
}


/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param twitterId ユーザにリンクさせるtwitterアカウントのtwitterID
 @param screenName ユーザにリンクさせるtwitterアカウントのscreenName
 @param authToken ユーザにリンクさせるtwitterアカウントのaccessToken
 @param authTokenSecret ユーザにリンクさせるtwitterアカウントのauthTokenSecret
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
           block:(NCMBErrorResultBlock)block{
    [self linkUser:user twitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:block check:YES];
}

/**
 指定したユーザにtwitter連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param twitterId ユーザにリンクさせるtwitterアカウントのtwitterID
 @param screenName ユーザにリンクさせるtwitterアカウントのscreenName
 @param authToken ユーザにリンクさせるtwitterアカウントのaccessToken
 @param authTokenSecret ユーザにリンクさせるtwitterアカウントのauthTokenSecret
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
          target:(id)target
        selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self linkUser:user twitterId:twitterId screenName:screenName authToken:authToken authTokenSecret:authTokenSecret block:^(NSError *error) {
        [ invocation setArgument:&error atIndex: 2 ];
        [ invocation invoke ];
    }];
}

#pragma mark - unlink

/**
 指定したユーザとtwitterのリンクを解除。必要があればエラーをセットし、取得することもできる。
 @param user 指定するユーザ
 @param error 処理中に起きたエラーのポインタ
 @return BOOL型 通信成功の場合YESを返す
 */
+ (void)unlinkUser:(NCMBUser *)user error:(NSError **)error{

    if ([[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *authData = nil;
        authData = [NSMutableDictionary dictionaryWithDictionary:[user objectForKey:@"authData"]];
        
        [authData removeObjectForKey:@"twitter"];
        
        [user setObject:authData forKey:@"authData"];
        [user save:error];
        
    } else {
        *error = [NSError errorWithDomain:ERRORDOMAIN
                                     code:404003
                                 userInfo:@{NSLocalizedDescriptionKey:@"twitter token not found"}];
    }
}



/**
 指定したユーザとtwitterのリンクを解除。解除し終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NSError *error）
 errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user
                         block:(NCMBErrorResultBlock)block{
    if ([[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *authData = nil;
        authData = [NSMutableDictionary dictionaryWithDictionary:[user objectForKey:@"authData"]];
        
        [authData removeObjectForKey:@"twitter"];
        [user setObject:authData forKey:@"authData"];
        [user saveInBackgroundWithBlock:block];
    } else {
        if (block){
            NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:404003
                                             userInfo:@{NSLocalizedDescriptionKey:@"twitter token not found"}];
            block(error);
        }
    }
}

/**
 指定したユーザとtwitterのリンクを解除する。解除し終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンク解除の有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user
                        target:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self unlinkUserInBackground:user block:^(NSError *error) {
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

#pragma mark - request

/**
 更新用のリクエストを作成する(authDataを更新する)
 @param user 更新するユーザ
 @param authData 更新用のデータ
 @return NCMBURLConnection型 リクエスト
 */
+(NCMBURLConnection*)updateRequestWithUser:(NCMBUser*)user authData:(id)authData{
    //JSONデータ作成
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    data[@"authData"] = @{AUTH_TYPE_TWITTER:authData};
    NSMutableDictionary *jsonDic = [user convertToJSONFromNCMBObject:data];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:nil];
    
    //Path作成
    NSString *path = [NSString stringWithFormat:@"users/%@",user.objectId];
    
    //更新用リクエストの作成
    NCMBURLConnection *request = [[NCMBURLConnection alloc] initWithPath:path method:@"PUT" data:jsonData];
    return request;
}



@end
