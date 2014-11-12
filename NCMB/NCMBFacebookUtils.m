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

//FacebookSDKがincludeされているアプリの場合のみビルドする
#if defined(__has_include)
#if __has_include(<FacebookSDK/FacebookSDK.h>)

#import <FacebookSDK/FacebookSDK.h>

#import "NCMBFacebookUtils.h"
#import "NCMBUser+Private.h"
#import "NCMBURLConnection.h"
#import "NCMBAnonymousUtils.h"
#import "NCMBObject+Private.h"
#import "NCMBACL.h"

#define AUTH_TYPE_FACEBOOK              @"facebook"
#define FACEBOOKAPPID_KEY               @"FacebookAppID"
#define AUTHDATA_ID_KEY                 @"id"
#define AUTHDATA_ACCESS_TOKEN_KEY       @"access_token"
#define AUTHDATA_EXPIRATION_DATE_KEY    @"expiration_date"

@interface NCMB_Facebook : NSObject
@property(nonatomic,readonly) FBSession* session;
@property(nonatomic,strong) NSString* facebookId;
@property(nonatomic,strong) NSString* accessToken;
@property(nonatomic,strong) NSDate* expirationDate;
@end

@implementation NCMB_Facebook

/**
 セッションを取得する
 @return session
 */
-(FBSession*)session{
    return FBSession.activeSession;
}

#pragma mark - instance method

/**
 初期化
 */
-(void)initializeFacebook{
    //Facebookログアウト(sessionクリア)処理
    [self.session closeAndClearTokenInformation];
    (void)[self.session init];
}

/**
 初期化。suffixを設定する
 @param urlSchemeSuffix suffix
 */
-(void)initializeFacebookWithUrlSchemeSuffix:(NSString*)urlSchemeSuffix{
    //Facebookログアウト(sessionクリア)処理
    [self.session closeAndClearTokenInformation];
    [FBSettings setDefaultUrlSchemeSuffix:urlSchemeSuffix];
    (void)[self.session init];
}

/**
 facebook情報を取得し設定する
 @param session セッション
 @param error エラー
 @param completionHandler 取得したfacebook情報を設定する
 */
-(void)signRequestWithFBSession:(FBSession*)session
                          error:(NSError*)logInError
              completionHandler:(void(^)(NCMB_Facebook* facebook, NSError *error))handler{
    if(session.isOpen){
        FBRequest* reqest = [FBRequest requestForMe];
        __block NCMB_Facebook* weakSelf = self;
        [reqest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error){
                weakSelf.facebookId = [result objectForKey:@"id"];
                weakSelf.accessToken = session.accessTokenData.accessToken;
                weakSelf.expirationDate = session.accessTokenData.expirationDate;
                handler(weakSelf,nil);
            }else{
                handler(nil,error);
            }
        }];
    }else{
        handler(nil,logInError);
    }
}


/**
 sessionを有効にする
 @param accessTokenData セッション
 @param completionHandler 取得したsettionを使用しfacebook情報を取得、設定する
 */
-(void)requestAuthDataWithAccessToken:(FBAccessTokenData *)accessTokenData
                    completionHandler:(void(^)(NCMB_Facebook* facebook,NSError *error))handler{
    if (self.session.isOpen) {
        //Facebookログアウト(sessionクリア)処理
        [self.session closeAndClearTokenInformation];
        //sessionの設定
        FBSession* session = [FBSession new];
        [FBSession setActiveSession:session];
    }
    
    __block BOOL isFinish = NO;
    [self.session openFromAccessTokenData:accessTokenData completionHandler:^(FBSession *session,
                                                                              FBSessionState status,
                                                                              NSError *error) {
        if(status!=FBSessionStateClosed){
            if(!isFinish){
                [FBSession setActiveSession:session];
                [self signRequestWithFBSession:self.session error:error completionHandler:handler];
                isFinish = YES;
            }
        }
    }];
    
}

/**
 OSのversionに合わせて処理を実行する。
 safariをオープンしてread権限、publish権限を得る。
 @param permissions パーミッション
 @param defaultAudience デフォルト対象
 @param block 結果の返却
 */
-(void)requestReAuthorizeWithPermission:(NSArray*)permissions defaultAudience:(FBSessionDefaultAudience)audience block:(void(^)(FBSession *session, NSError *error))handler{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(version>=6.0){
        [[self session] requestNewPublishPermissions:permissions defaultAudience:audience completionHandler:^(FBSession *session, NSError *error) {
            [FBSession setActiveSession:session];
            handler(session,error);
        }];
    }else{
        [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:audience allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [FBSession setActiveSession:session];
            handler(session,error);
        }];
    }
}

#pragma mark -

/**
 sessionを有効にする
 @param permissions セッション
 @param completionHandler 取得したsettionを使用しfacebook情報を取得、設定する
 */
-(void)requestAuthDataWithPermissions:(NSArray*)permissions
                    completionHandler:(void(^)(NCMB_Facebook* facebook, NSError *error))handler{
    
    if (self.session.isOpen) {
        //Facebookログアウト(sessionクリア)処理
        [self.session closeAndClearTokenInformation];
        FBSession* session = [FBSession new];
        [FBSession setActiveSession:session];
    }
    
    if (self.session.state != FBSessionStateCreated) {
        FBSession* session = [FBSession new];
        [FBSession setActiveSession:session];
        [self.session close];
    }
    
    //戻り値は使用しない
    (void)[self.session initWithPermissions:permissions];
    
    __block BOOL isFinish = NO;
    [self.session openWithCompletionHandler:^(FBSession *session,
                                              FBSessionState status,
                                              NSError *error) {
        if(status!=FBSessionStateClosed){
            if (!isFinish ) {
                [FBSession setActiveSession:session];
                [self signRequestWithFBSession:self.session error:error completionHandler:handler];
                isFinish = YES;
            }
        }
    }];
}

/**
 acessTokenが有効か確認する
 @param accessToken アクセストークン
 @param expirationDate 有効期限
 @param facebookId ID
 @param handler 結果の返却
 */
-(void)checkAcessToken:(NSString*)accessToken expirationDate:(NSDate*)expirationDate facebookId:(NSString*)facebookId handler:(void(^)(BOOL isCallated, NSError* error))handler{
    FBAccessTokenData* data = [FBAccessTokenData createTokenFromString:accessToken permissions:nil expirationDate:expirationDate loginType:FBSessionLoginTypeFacebookViaSafari refreshDate:[NSDate date]];
    [self requestAuthDataWithAccessToken:data completionHandler:^(NCMB_Facebook *facebook, NSError *error) {
        if(!error){
            // ログインしたユーザーのfacebookIDと引数のfacebookIDの照合
            if([facebook.facebookId isEqualToString:facebookId])
                handler(YES,nil);
            else{
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:0];
                [userInfo setObject:@"Unauthorized" forKey:NSLocalizedDescriptionKey];
                NSError* idError = [NSError errorWithDomain:ERRORDOMAIN code:401 userInfo:userInfo];
                handler(NO,idError);
            }
        }else{
            handler(NO,error);
        }
    }];
}

/**
 初期化
 */
-(id)init{
    if(self = [super init]){
    }
    return self;
}
@end

@implementation NCMBFacebookUtils
static NCMB_Facebook* _facebook = nil;

/**
 facebookの取得
 @return _facebook facebook情報
 */
+ (NCMB_Facebook *)facebook{
    if(!_facebook) _facebook = [NCMB_Facebook new];
    return _facebook;
}

/**
 sessionの取得
 @return session セッション
 */
+ (FBSession *)session{
    return [self facebook].session;
}

#pragma mark - initialize

/**
 Facebookの初期化
 */
+ (void)initializeFacebook{
    [[self facebook] initializeFacebook];
}

/**
 urlSchemeSuffixを指定し、Facebookの初期化
 @param urlSchemeSuffix アプリケーションのURL Suffix。１つのFacebookAppIDを複数のアプリケーションで使用する場合に用いる。
 */
+ (void)initializeFacebookWithUrlSchemeSuffix:(NSString *)urlSchemeSuffix{
    [[self facebook] initializeFacebookWithUrlSchemeSuffix:urlSchemeSuffix];
}

#pragma mark - authData

/**
 authDataの作成
 @param facebookId ID
 @param accessToken アクセストークン
 @param expirationDate 有効期限
 @return NSDictionary型authData
 */
+(NSDictionary*)createAuthData:(NSString*)facebookId accessToken:(NSString*)accessToken expirationDate:(NSDate*)expirationDate{
    NSDictionary* authData = @{AUTHDATA_ID_KEY                :   facebookId,
                               AUTHDATA_ACCESS_TOKEN_KEY      :   accessToken,
                               AUTHDATA_EXPIRATION_DATE_KEY   :   expirationDate};
    return authData;
}

#pragma mark - logIn

/**
 facebook情報の取得
 @param permissions ログイン時に要求するパーミッション
 @param block 情報取得後実行されるブロック。正常に取得出来た場合はfacebookユーザーの登録または更新処理に移る
 */
+(void)logInToFacebookWithPermissions:(NSArray *)permissions block:(NCMBUserResultBlock)block{
    [[NCMBFacebookUtils facebook] requestAuthDataWithPermissions:permissions completionHandler:^(NCMB_Facebook* facebook, NSError *error){
        if(!error&&facebook){
            NSString* fbId = facebook.facebookId;
            NSString* accessToken = facebook.accessToken;
            NSDate* expirationDate = facebook.expirationDate;
            [self logInWithFacebookId:fbId accessToken:accessToken expirationDate:expirationDate block:block check:NO];
        }else{
            //エラー処理
            if(block)block(nil,error);
        }
    }];
}

/**
 facebookを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param permissions ログイン時に要求するパーミッション
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithPermissions:(NSArray *)permissions block:(NCMBUserResultBlock)block{
    //ログインしている、かつFacebookユーザーか判定
    if([NCMBUser currentUser]&&[NCMBFacebookUtils isLinkedWithUser:[NCMBUser currentUser]]){
        //ログインユーザーのauthData(facebook情報)の取得
        NSDictionary* authData = [[NCMBUser currentUser] objectForKey:@"authData"];
        NSDictionary* fbAuthData = authData[AUTH_TYPE_FACEBOOK];
        NSString* facebookId = fbAuthData[AUTHDATA_ID_KEY];
        NSString* accessToken = fbAuthData[AUTHDATA_ACCESS_TOKEN_KEY];
        NSString* expirationDateStr = [fbAuthData objectForKey:AUTHDATA_EXPIRATION_DATE_KEY];
        
        //日付をmBaaS形式に直す
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [dateFormatter setCalendar:calendar];
        [dateFormatter setLocale:[NSLocale systemLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z"];
        NSDate *expirationDate = [dateFormatter dateFromString:expirationDateStr];
        
        //ログイン中のfacebook情報が有効か確認する
        [[NCMBFacebookUtils facebook] checkAcessToken:accessToken expirationDate:expirationDate facebookId:facebookId handler:^(BOOL isCallated, NSError *error) {
            if(isCallated){
                //有効であれば、facebook情報でユーザの新規登録、または更新を行う
                [self logInWithFacebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:block check:NO];
            }else{
                //無効である場合は、facebookId,accessTokenなどを更新する
                [self logInToFacebookWithPermissions:permissions block:block];
            }
        }];
        
    }else{
        //facebookId,accessTokenなどを更新する
        [self logInToFacebookWithPermissions:permissions block:block];
    }
}

/**
 facebookを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param permissions ログイン時に要求するパーミッション
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithPermissions:(NSArray *)permissions target:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self logInWithPermissions:permissions block:^(NCMBUser *user, NSError *error) {
        [ invocation setArgument:&user atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

/**
 facebook情報でユーザの新規登録、または更新を行う
 @param facebookId ID
 @param accessToken アクセストークン
 @param expirationDate 有効期限
 @param block ログイン後実行されるblock。結果を返す
 @param check facebook情報が有効かどうか。facebook情報のチェックが終わっている場合はNOが渡される
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                      block:(NCMBUserResultBlock)block
                      check:(BOOL)check
{
    
    if(check){
        //facebook情報の確認が出来ていない場合は、確認しfacebook情報を更新する
        [[NCMBFacebookUtils facebook] checkAcessToken:accessToken expirationDate:expirationDate facebookId:facebookId handler:^(BOOL isCallated, NSError *error) {
            if(isCallated){
                [self logInWithFacebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:block check:NO];
            }else{
                if(block)block(nil,error);
            }
        }];
    }else{
        //facebook情報の確認が出来ている場合ユーザーの新規登録または更新を行う
        NCMBUser* currentUser = [NCMBUser currentUser];
        NSDictionary* authData = [self createAuthData:facebookId accessToken:accessToken expirationDate:expirationDate];
        //ログインしている、かつ匿名ユーザーか判定
        if(currentUser&&[NCMBAnonymousUtils isLinkedWithUser:currentUser]){
            //ログイン済の場合は更新
            [currentUser setObject:@{AUTH_TYPE_FACEBOOK:authData} forKey:@"authData"];
            [currentUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(block){
                    block(currentUser,error);
                }
            }];
        }else{
            //未ログインの場合は新規登録
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:authData forKey:AUTH_TYPE_FACEBOOK];
            NCMBUser *user = [NCMBUser user];
            [user setObject:dic forKey:@"authData"];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    if(block)block(user,nil);
                }else{
                    if(block)block(nil,error);
                }
            }];
        }
    }
}

/**
 facebookを利用してユーザログイン。ログインし終わったら与えられたblockを呼び出す。
 @param facebookId ログインさせるFacebookアカウントのfacebookID
 @param accessToken ログインさせるFacebookアカウントのaccessToken
 @param expirationDate ログインさせるFacebookアカウントのaccessToken有効期限
 @param block ログイン後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （NCMBUser *user, NSError *error）userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                      block:(NCMBUserResultBlock)block{
    [self logInWithFacebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:block check:YES];
}

/**
 facebookを利用してユーザログイン。ログインし終わったら指定されたコールバックを呼び出す。
 @param facebookId ログインさせるFacebookアカウントのfacebookID
 @param accessToken ログインさせるFacebookアカウントのaccessToken
 @param expirationDate ログインさせるFacebookアカウントのaccessToken有効期限
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NCMBUser *)user error:(NSError **)error
 userにはログインしたユーザ情報が渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                     target:(id)target
                   selector:(SEL)selector{
    
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self logInWithFacebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:^(NCMBUser *user, NSError *error) {
        [ invocation setArgument:&user atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
    
}

#pragma mark - link

/**
 指定したユーザがFacebookユーザかどうか判定。Facebookユーザの場合はtrueを返す。
 @param user 指定するユーザ
 */
+ (BOOL)isLinkedWithUser:(NCMBUser *)user{
    BOOL isLinkerFlag = NO;
    if ([user objectForKey:@"authData"] && [[user objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]) {
        if ([[user objectForKey:@"authData"] objectForKey:AUTH_TYPE_FACEBOOK]) {
            isLinkerFlag = YES;
        }
    }
    return isLinkerFlag;
}

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param permissions ログイン時に要求するパーミッション
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （BOOL succeeded, NSError *error）succeededにはリンクの有無がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user permissions:(NSArray *)permissions block:(NCMBBooleanResultBlock)block{
    [[NCMBFacebookUtils facebook] requestAuthDataWithPermissions:permissions completionHandler:^(NCMB_Facebook* facebook, NSError *error){
        if(!error){
            NSString* fbId = facebook.facebookId;
            NSString* accessToken = facebook.accessToken;
            NSDate* expirationDate = facebook.expirationDate;
            [self linkUser:user facebookId:fbId accessToken:accessToken expirationDate:expirationDate block:block check:NO];
        }else{
            if(block)block(NO,error);
        }
    }];
}

/**
 facebook連携情報のリンク処理
 @param user 指定するユーザ
 @param facebookId ユーザにリンクさせるID
 @param accessToken ユーザにリンクさせるaccessToken
 @param expirationDate ユーザにリンクさせるaccessTokenの有効期限
 @param check acessTokenのチェック
 */
+ (void)linkUser:(NCMBUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
           block:(NCMBBooleanResultBlock)block
           check:(BOOL)check{
    if(check){
        [[self facebook] checkAcessToken:accessToken expirationDate:expirationDate facebookId:facebookId handler:^(BOOL isCallated, NSError *error) {
            if(isCallated){
                [self linkUser:user facebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:block check:NO];
            }else{
                if(block)block(NO,error);
            }
        }];
    }else{
        NSDictionary* authData = [self createAuthData:facebookId accessToken:accessToken expirationDate:expirationDate];
        NCMBURLConnection *request = [self updateRequestWithUser:user authData:authData];
        [request asyncConnectionWithBlock:^(NSDictionary *responseDic, NSError *errorBlock){
            BOOL succees = YES;
            if(errorBlock){
                succees = NO;
            }else{
                NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseDic];
                [mutableResponse setValue:@{AUTH_TYPE_FACEBOOK:authData} forKey:@"authData"];
                [user afterSave:mutableResponse operations:nil];
                [NCMBUser saveToFileCurrentUser:user];
            }
            if (block) {
                block(succees,errorBlock);
            }
        }];
    }
}

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param permissions ログイン時に要求するパーミッション
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user permissions:(NSArray *)permissions target:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self linkUser:user permissions:permissions block:^(BOOL succeeded, NSError *error) {
        NSNumber *num = [NSNumber numberWithBool:succeeded];
        [ invocation setArgument:&num atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param facebookId ユーザにリンクさせるID
 @param accessToken ユーザにリンクさせるaccessToken
 @param expirationDate ユーザにリンクさせるaccessTokenの有効期限
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （BOOL succeeded, NSError *error）succeededにはリンクの有無がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
           block:(NCMBBooleanResultBlock)block{
    [self linkUser:user facebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:block check:YES];
}

/**
 指定したユーザにfacebook連携情報をリンクさせる。リンクし終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param facebookId ユーザにリンクさせるID
 @param accessToken ユーザにリンクさせるaccessToken
 @param expirationDate ユーザにリンクさせるaccessTokenの有効期限
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンクの有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)linkUser:(NCMBUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
          target:(id)target
        selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self linkUser:user facebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:^(BOOL succeeded, NSError *error) {
        NSNumber *num = [NSNumber numberWithBool:succeeded];
        [ invocation setArgument:&num atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

#pragma mark - unlink

/**
 指定したユーザとfacebookのリンクを解除。必要があればエラーをセットし、取得することもできる。
 @param user 指定するユーザ
 @param error 処理中に起きたエラーのポインタ
 @return BOOL型 通信結果
 */
+ (BOOL)unlinkUser:(NCMBUser *)user error:(NSError **)error{
    //解除用のauthData
    id authData = [NSNull null];
    
    //通信処理
    NSError *errorLocal = nil;
    NCMBURLConnection *request = [self updateRequestWithUser:user authData:authData];
    NSDictionary *responseDic = [request syncConnection:&errorLocal];
    
    //レスポンス処理
    BOOL isSuccess = YES;
    if(errorLocal){
        isSuccess = NO;
        if (error) {
            *error =  errorLocal;
        }
    }else{
        //解除成功のためauthDataを空にする
        NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseDic];
        [mutableResponse setValue:[NSMutableDictionary dictionary] forKey:@"authData"];
        [user afterSave:mutableResponse operations:nil];
        //ファイルに登録したユーザーデータ書き込み
        [NCMBUser saveToFileCurrentUser:user];
    }
    return isSuccess;
}

/**
 指定したユーザとfacebookのリンクを解除。リンク解除し終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （BOOL succeeded, NSError *error）succeededにはリンク解除の有無がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user block:(NCMBBooleanResultBlock)block{
    //解除用のauthData
    id authData = [NSNull null];
    
    //通信処理
    NCMBURLConnection *request = [self updateRequestWithUser:user authData:authData];
    [request asyncConnectionWithBlock:^(NSDictionary *responseDic, NSError *error) {
        //レスポンス処理
        BOOL isSuccess = YES;
        if(error){
            isSuccess = NO;
        }else{
            //解除成功のためauthDataを空にする
            NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseDic];
            [mutableResponse setValue:[NSMutableDictionary dictionary] forKey:@"authData"];
            [user afterSave:mutableResponse operations:nil];
            //ファイルに登録したユーザーデータ書き込み
            [NCMBUser saveToFileCurrentUser:user];
        }
        if(block){
            block(isSuccess,error);
        }
    }];
}

/**
 指定したユーザとfacebookのリンクを解除。リンク解除し終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultにはリンク解除の有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)unlinkUserInBackground:(NCMBUser *)user target:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
        NSNumber *num = [NSNumber numberWithBool:succeeded];
        [ invocation setArgument:&num atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}


#pragma mark - reauthorize

/**
 指定ユーザのfacebook投稿権限の取得。取得し終わったら与えられたblockを呼び出す。
 @param user 指定するユーザ
 @param permissions 要求するPublishPermissions
 @param audience 投稿の公開範囲
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある （BOOL succeeded, NSError *error）succeededには取得の有無がBOOL型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)reauthorizeUser:(NCMBUser *)user
            permissions:(NSArray *)permissions
               audience:(NCMBSessionDefaultAudience)audience
                  block:(NCMBBooleanResultBlock)block{
    
    NSAssert([NCMBFacebookUtils isLinkedWithUser:user], @"The user must already be linked with Facebook in order to reauthorize.");
    
    //ユーザーのauthData情報の取得
    NSDictionary* authData = [user objectForKey:@"authData"];
    NSDictionary* fbAuthData = [authData objectForKey:AUTH_TYPE_FACEBOOK];
    NSString* facebookId = fbAuthData[AUTHDATA_ID_KEY];
    NSString* accessToken = fbAuthData[AUTHDATA_ACCESS_TOKEN_KEY];
    NSDate * expirationDateStr = [fbAuthData objectForKey:AUTHDATA_EXPIRATION_DATE_KEY];
    
    //セッションを有効にする
    [[self facebook] checkAcessToken:accessToken expirationDate:expirationDateStr facebookId:facebookId handler:^(BOOL isCallated, NSError *error) {
        if(isCallated){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self facebook] requestReAuthorizeWithPermission:permissions defaultAudience:audience block:^(FBSession *session, NSError *error) {
                    BOOL succeeded = NO;
                    if(session&&!error){
                        NSString* facebookId = fbAuthData[AUTHDATA_ID_KEY];
                        NSString* accessToken = [session accessTokenData].accessToken;
                        NSDate* expirationDate = [session accessTokenData].expirationDate;
                        //authDataのfacebook情報更新
                        [self linkUser:user facebookId:facebookId accessToken:accessToken expirationDate:expirationDate block:block check:NO];
                    }else{
                        if(block)block(succeeded,error);
                    }
                }];
            });
        }else{
            if(block)block(NO,error);
        }
    }];
    
}

/**
 指定ユーザのfacebook投稿権限の取得。取得し終わったら指定されたコールバックを呼び出す。
 @param user 指定するユーザ
 @param permissions 要求するPublishPermissions
 @param audience 投稿の公開範囲
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSNumber *)result error:(NSError **)error
 resultには取得の有無をNSNumber型で渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
+ (void)reauthorizeUser:(NCMBUser *)user
            permissions:(NSArray *)permissions
               audience:(NCMBSessionDefaultAudience)audience
                 target:(id)target
               selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self reauthorizeUser:user permissions:permissions audience:audience block:^(BOOL succeeded, NSError *error) {
        NSNumber *num = [NSNumber numberWithBool:succeeded];
        [ invocation setArgument:&num atIndex: 2 ];
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
    data[@"authData"] = @{AUTH_TYPE_FACEBOOK:authData};
    NSMutableDictionary *jsonDic = [user convertToJSONFromNCMBObject:data];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:nil];
    
    //Path作成
    NSString *path = [NSString stringWithFormat:@"users/%@",user.objectId];
    
    //更新用リクエストの作成
    NCMBURLConnection *request = [[NCMBURLConnection alloc] initWithPath:path method:@"PUT" data:jsonData];
    return request;
}

#pragma mark - other

//アプリにユーザーの資格証明を提供する
+ (BOOL)handleOpenURL:(NSURL *)url{
    return [[NCMBFacebookUtils session] handleOpenURL:url];
}

@end

#endif
#endif