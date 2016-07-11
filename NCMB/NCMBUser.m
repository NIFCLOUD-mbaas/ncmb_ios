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

#import "NCMBUser.h"

#import "NCMBAnonymousUtils.h"
#import "NCMBQuery.h"
#import "NCMBACL.h"

#import "NCMBURLConnection.h"

#import "NCMBObject+Private.h"
#import "NCMBObject+Subclass.h"
#import "NCMBRelation+Private.h"

#if defined(__has_include)
#if __has_include(<FacebookSDK/FacebookSDK.h>) || __has_include(<FBSDKLoginKit/FBSDKLoginKit.h>)
#import "NCMBFacebookUtils+Private.h"
#endif
#endif


@implementation NCMBUser
#define DATA_MAIN_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"]
#define DATA_CURRENTUSER_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentUser", DATA_MAIN_PATH]

#pragma mark - URL
#define URL_LOGIN @"login"
#define URL_LOGOUT @"logout"
#define URL_USERS @"users"
#define URL_AUTHENTICATION_MAIL @"requestMailAddressUserEntry"
#define URL_PASSWOR_RESET  @"requestPasswordReset"

#define AUTH_TYPE_GOOGLE                @"google"
#define AUTH_TYPE_TWITTER               @"twitter"
#define AUTH_TYPE_FACEBOOK              @"facebook"
#define AUTH_TYPE_ANONYMOUS             @"Anonymous"

static NCMBUser *currentUser = nil;
static BOOL isEnableAutomaticUser = NO;

#pragma mark - init

//description用のメソッド
- (NSDictionary*)getLocalData{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super getLocalData]];
    if (self.userName){
        [dic setObject:self.userName forKey:@"userName"];
    }
    if (self.mailAddress){
        [dic setObject:self.mailAddress forKey:@"mailAddress"];
    }
    if (self.sessionToken){
        [dic setObject:self.sessionToken forKey:@"sessionToken"];
    }
    return dic;
}

//NCMBUserはクラス名を指定しての初期化は出来ない
+ (NCMBObject*)objectWithClassName:(NSString *)className{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot initialize a NCMBUser with a custom class name." userInfo:nil] raise];
    return nil;
}

- (instancetype)init{
    self = [self initWithClassName:@"user"];
    return self;
}

+ (NCMBUser *)user{
    NCMBUser *user = [[NCMBUser alloc] init];
    return user;
}

+ (NCMBQuery*)query{
    return [NCMBQuery queryWithClassName:@"user"];
}

#pragma mark - get/set

/**
 ユーザー名の設定
 @param userName ユーザー名
 */
- (void)setUserName:(NSString *)userName{
    [self setObject:userName forKey:@"userName"];
}

/**
 ユーザー名の取得
 @param userName ユーザー名
 @return NSString型ユーザー名
 */
- (NSString *)userName{
    return [self objectForKey:@"userName"];
}

/**
 パスワードの設定
 @param password パスワード
 */
- (void)setPassword:(NSString *)password{
    [self setObject:password forKey:@"password"];
}

/**
 Eメールの設定
 @param mailAddress Eメール
 */
- (void)setMailAddress:(NSString *)mailAddress{
    [self setObject:mailAddress forKey:@"mailAddress"];
}

/**
 Eメールの取得
 @param mailAddress メールアドレス
 @return NSString型メールアドレス
 */
- (NSString *)mailAddress{
    return [self objectForKey:@"mailAddress"];
}

/**
 セッショントークンの設定
 @param ユーザーのセッショントークンを設定する
 */
- (void)setSessionToken:(NSString *)newSessionToken{
    _sessionToken = newSessionToken;
}


/**
 現在ログイン中のユーザーのセッショントークンを返す
 @return NSString型セッショントークン
 */
+ (NSString *)getCurrentSessionToken{
    if (currentUser != nil) {
        return currentUser.sessionToken;
    }
    return nil;
}

/**
 匿名ユーザの自動生成を有効化
 */
+ (void)enableAutomaticUser{
    isEnableAutomaticUser = TRUE;
}

/**
 現在ログインしているユーザ情報を取得
 @return NCMBUser型ログイン中のユーザー
 */
+ (NCMBUser *)currentUser{
    if (currentUser) {
        return currentUser;
    }
    currentUser = nil;
    
    //アプリ再起動などでcurrentUserがnilになった時は端末に保存したユーザ情報を取得、設定する。
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTUSER_PATH isDirectory:nil]) {
        currentUser = [NCMBUser getFromFileCurrentUser];
    }
    return currentUser;
}

+ (void)automaticCurrentUserWithBlock:(NCMBUserResultBlock)block{
    if ([self currentUser]) {
        block([self currentUser], nil);
    }
    //匿名ユーザーの自動生成がYESの時は匿名ユーザーでログインする
    else if (isEnableAutomaticUser) {
        isEnableAutomaticUser = NO;
        [NCMBAnonymousUtils logInWithBlock:^(NCMBUser *user, NSError *error) {
            if (!error) {
                currentUser = user;
            }
            isEnableAutomaticUser = YES;
            if (block){
                block(user, error);
            }
        }];
    }
}

+ (void)automaticCurrentUserWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self automaticCurrentUserWithBlock:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

/**
 認証済みか判定
 @return BOOL型YES=認証済、NO=未認証
 */
- (BOOL)isAuthenticated{
    BOOL isAuthenticateFlag = FALSE;
    if (self.sessionToken) {
        isAuthenticateFlag =TRUE;
    }
    return isAuthenticateFlag;
}

#pragma mark - signUp

/**
 ユーザの新規登録。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return 新規登録の成功の有無
 */
- (void)signUp:(NSError **)error{
    [self save:error];
}

/**
 ユーザ の新規登録(非同期)
 @param block
 */
- (void)signUpInBackgroundWithBlock:(NCMBErrorResultBlock)block{
    [self saveInBackgroundWithBlock:block];
}


/**
 target用ユーザの新規登録処理
 @param target
 @param selector
 */
- (void)signUpInBackgroundWithTarget:(id)target selector:(SEL)selector{
    [self saveInBackgroundWithTarget:target selector:selector];
}

- (void)signUpWithFacebookToken:(NSDictionary *)facebookInfo block:(NCMBErrorResultBlock)block{
    
    NSMutableDictionary *newAuthData = nil;
    NSDictionary *authData = [self objectForKey:@"authData"];
    if (authData && [authData isKindOfClass:[NSDictionary class]]){
        newAuthData = [NSMutableDictionary dictionaryWithDictionary:authData];
        if ([facebookInfo isKindOfClass:[NSDictionary class]]){
            [newAuthData addEntriesFromDictionary:facebookInfo];
        }
    } else {
        newAuthData = [NSMutableDictionary dictionaryWithDictionary:facebookInfo];
    }
    
    [self setObject:newAuthData forKey:@"authData"];
    [self saveInBackgroundWithBlock:block];
}

/**
 googleのauthDataをもとにニフティクラウドmobile backendへの会員登録(ログイン)を行う
 @param googleInfo google認証に必要なauthData
 @param block サインアップ後に実行されるblock
 */
- (void)signUpWithGoogleToken:(NSDictionary*)googleInfo block:(NCMBErrorResultBlock)block{
    //既存のauthDataのgoogle情報のみ更新する
    NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
    if([[self objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
        userAuthData = [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:@"authData"]];
    }
    [userAuthData setObject:googleInfo forKey:@"google"];
    [self setObject:userAuthData forKey:@"authData"];
    [self signUpInBackgroundWithBlock:^(NSError *error) {
        if(block){
            block(error);
        }
    }];
}

#pragma mark - signUpAnonymous

- (void)signUpFromAnonymous:(NSString *)userName password:(NSString *)password error:(NSError **)error{
    //匿名ユーザーか判定し、正規用ユーザー作成
    NCMBUser *signUpUser = [self checkAnonymousUser];
    //正規ユーザーにデータをセットし、削除用ユーザー作成
    NCMBUser *deleteUser = [self setTheDataForUser:signUpUser userName:userName password:password];
    //新規ユーザー登録
    NSError *errorLocal = nil;
    [signUpUser signUp:&errorLocal];
    if(errorLocal){
        if (error){
            *error = errorLocal;
        }
    } else {
        //匿名ユーザー削除
        currentUser = deleteUser;
        [deleteUser delete:&errorLocal];
        if(errorLocal){
            if (error){
                *error = errorLocal;
            }
        } else {
            currentUser = signUpUser;
        }
    }
}


- (void)signUpFromAnonymousInBackgroundWithBlock:(NSString *)userName
                                        password:(NSString *)password
                                           block:(NCMBErrorResultBlock)block{
    dispatch_queue_t queue = dispatch_queue_create("saveInBackgroundWithBlock", NULL);
    dispatch_async(queue, ^{
        //匿名ユーザーか判定し、正規用ユーザー作成
        NCMBUser *signUpUser = [self checkAnonymousUser];
        //正規ユーザーにデータをセットし、削除用ユーザー作成
        NCMBUser *deleteUser = [self setTheDataForUser:signUpUser userName:userName password:password];
        //新規ユーザー登録
        [signUpUser signUpInBackgroundWithBlock:^(NSError *error) {
            if(error){
                if (block){
                    block(error);
                }
            }else{
                //匿名ユーザー削除
                currentUser = deleteUser;
                [deleteUser deleteInBackgroundWithBlock:^(NSError *error) {
                    currentUser = signUpUser;
                    if (block){
                        block(error);
                    }
                }];
            }
        }];
    });
}

/**
 target用ユーザの新規登録処理
 @param target
 @param selector
 */
- (void)signUpFromAnonymousInBackgroundWithTarget:(NSString *)userName password:(NSString *)password target:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [self signUpFromAnonymousInBackgroundWithBlock:userName password:password block:^(NSError *error) {
        [invocation setArgument:&error atIndex: 2 ];
        [invocation invoke ];
    }];
}

- (NCMBUser *)checkAnonymousUser{
    NCMBUser * anonymousUser = [NCMBUser currentUser];
    if(![NCMBAnonymousUtils isLinkedWithUser:anonymousUser]){
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"This user is not a anonymous user." userInfo:nil] raise];
    }
    return anonymousUser;
}

- (NCMBUser *)setTheDataForUser:(NCMBUser *)signUpUser userName:(NSString *)userName password:(NSString *)password{
    //削除用ユーザー作成
    NCMBUser *deleteUser = [NCMBUser user];
    deleteUser.objectId = signUpUser.objectId;
    deleteUser.sessionToken = signUpUser.sessionToken;
    
    //saiguUp用ユーザー作成。authData以外を引き継ぐ
    [signUpUser removeObjectForKey:@"authData"];
    for(id key in [signUpUser allKeys]){
        [signUpUser setObject:[self convertToJSONFromNCMBObject:[signUpUser objectForKey:key]] forKey:key];
    }
    signUpUser.userName = userName;
    signUpUser.password = password;
    signUpUser.objectId = nil;
    
    return deleteUser;
}

#pragma mark - requestAuthenticationMail

/**
 同期で会員登録メールの要求を行う
 @param email メールアドレス
 @param error エラー
 @return BOOL型通信結果の有無
 */
+ (void)requestAuthenticationMail:(NSString *)email
                            error:(NSError **)error{
    [NCMBUser requestMailFromNCMB:URL_AUTHENTICATION_MAIL mail:email error:error];
}

/**
 非同期で会員登録メールの要求を行う
 @param email メールアドレス
 @param target
 @param selector
 */
+ (void)requestAuthenticationMailInBackground:(NSString *)email
                                       target:(id)target
                                     selector:(SEL)selector{
    [NCMBUser requestMailFromNCMB:URL_AUTHENTICATION_MAIL mail:email target:target selector:selector];
}

/**
 非同期で会員登録メールの要求を行う
 @param email メールアドレス
 @param block
 */
+ (void)requestAuthenticationMailInBackground:(NSString *)email
                                        block:(NCMBErrorResultBlock)block{
    [NCMBUser requestMailFromNCMB:URL_AUTHENTICATION_MAIL mail:email block:block];
}


#pragma mark requestMailFromNCMB

/**
 target用ログイン処理
 @param path　パス
 @param email メールアドレス
 @param error エラー
 */
+ (void)requestMailFromNCMB:(NSString *)path
                       mail:(NSString *)email
                     target:(id)target
                   selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    NCMBErrorResultBlock block = ^(NSError *error) {
        [ invocation setArgument:&error atIndex: 2 ];
        [ invocation invoke ];
    };
    
    if ([path isEqualToString:URL_PASSWOR_RESET]){
        [NCMBUser requestPasswordResetForEmailInBackground:email block:block];
    } else if ([path isEqualToString:URL_AUTHENTICATION_MAIL]){
        [NCMBUser requestAuthenticationMailInBackground:email block:block];
    }
}

/**
 同期メアド要求処理
 @param path　パス
 @param email メールアドレス
 @param error エラー
 */
+ (BOOL)requestMailFromNCMB:(NSString *)path mail:(NSString *)email
                      error:(NSError **)error{
    
    NCMBUser *user = [NCMBUser user];
    user.mailAddress = email;
    
    NSError *errorLocal = nil;
    NSMutableDictionary *operations = [user beforeConnection];
    NSMutableDictionary *ncmbDic = [user convertToJSONDicFromOperation:operations];
    NSMutableDictionary *jsonDic = [user convertToJSONFromNCMBObject:ncmbDic];
    NSData *json = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:&errorLocal];
    
    //通信開始
    NCMBURLConnection *connect = [[NCMBURLConnection new] initWithPath:path method:@"POST" data:json];
    [connect syncConnection:&errorLocal];
    bool isSuccess = YES;
    if (errorLocal) {
        if(error){
            *error = errorLocal;
        }
        isSuccess = NO;
    }
    return isSuccess;
}

/**
 非同期メアド要求処理
 @param path　パス
 @param email　メールアドレス
 @param block
 */
+ (void)requestMailFromNCMB:(NSString *)path
                       mail:(NSString *)email
                      block:(NCMBErrorResultBlock)block{
    NCMBUser *user = [NCMBUser user];
    user.mailAddress = email;
    
    NSMutableDictionary *operations = [user beforeConnection];
    NSMutableDictionary *ncmbDic = [user convertToJSONDicFromOperation:operations];
    NSMutableDictionary *jsonDic = [user convertToJSONFromNCMBObject:ncmbDic];
    NSData *json = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:nil];
    
    //リクエストを作成
    NCMBURLConnection *request = [[NCMBURLConnection alloc] initWithPath:path method:@"POST" data:json];
    //非同期通信を実行
    [request asyncConnectionWithBlock:^(NSDictionary *responseData, NSError *error){
        if (block) {
            block(error);
        }
    }];
}

#pragma mark - logIn


/**
 同期でログイン(ユーザ名とパスワード)を行う
 @param username　ユーザー名
 @param password　パスワード
 @param error
 */
+ (NCMBUser *)logInWithUsername:(NSString *)username
                       password:(NSString *)password
                          error:(NSError **)error{
    return [NCMBUser ncmbLogIn:username mailAddress:nil password:password error:error];
}

/**
 非同期でログイン(ユーザ名とパスワード)を行う
 @param username　ユーザー名
 @param password　パスワード
 @param target
 @param selector
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                               target:(id)target
                             selector:(SEL)selector{
    [NCMBUser ncmbLogInInBackground:username mailAddress:nil password:password target:target selector:selector];
}

/**
 非同期でログイン(ユーザ名とパスワード)を行う
 @param username　ユーザー名
 @param password　パスワード
 @param block
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                                block:(NCMBUserResultBlock)block{
    [NCMBUser ncmbLogInInBackground:username mailAddress:nil password:password block:block];
}

#pragma mark - logInWithMailAddress

/**
 同期でログイン(メールアドレスとパスワード)を行う
 @param email　メールアドレス
 @param password　パスワード
 @param error
 */
+ (NCMBUser *)logInWithMailAddress:(NSString *)email
                          password:(NSString *)password
                             error:(NSError **)error{
    return [NCMBUser ncmbLogIn:nil mailAddress:email password:password error:error];
}

/**
 非同期でログイン(メールアドレスとパスワード)を行う
 @param email　メールアドレス
 @param password　パスワード
 @param target
 @param selector
 */
+ (void)logInWithMailAddressInBackground:(NSString *)email
                                password:(NSString *)password
                                  target:(id)target
                                selector:(SEL)selector{
    [NCMBUser ncmbLogInInBackground:nil mailAddress:email password:password target:target selector:selector];
}


/**
 非同期でログイン(メールアドレスとパスワード)を行う
 @param email　メールアドレス
 @param password　パスワード
 @param block
 */
+ (void)logInWithMailAddressInBackground:(NSString *)email
                                password:(NSString *)password
                                   block:(NCMBUserResultBlock)block{
    [NCMBUser ncmbLogInInBackground:nil mailAddress:email password:password block:block];
}

#pragma mark ncmbLogIn


/**
 targetログイン処理
 @param username　ユーザー名
 @param email　メールアドレス
 @param password　パスワード
 @param target
 @param selector
 */
+ (void)ncmbLogInInBackground:(NSString *)username
                  mailAddress:(NSString *)email
                     password:(NSString *)password
                       target:(id)target
                     selector:(SEL)selector{
    
    NSMethodSignature* signature = [target methodSignatureForSelector: selector ];
    NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
    [ invocation setTarget:target];
    [ invocation setSelector: selector ];
    
    [NCMBUser ncmbLogInInBackground:username mailAddress:email password:password block:^(NCMBUser *user, NSError *error) {
        [ invocation setArgument:&user atIndex: 2 ];
        [ invocation setArgument:&error atIndex: 3 ];
        [ invocation invoke ];
    }];
}

/**
 ログイン用のNCMBURLConnectionを返す
 */
+(NCMBURLConnection*)createConnectionForLogin:(NSString*)username
                                   mailAddress:(NSString*)mailAddress
                                      password:(NSString*)password{
    //ログインパラメーター文字列の作成
    NSMutableArray *queryArray = [NSMutableArray array];
    NSArray *sortedQueryArray = nil;
    if (![username isKindOfClass:[NSNull class]] &&
        ![mailAddress isKindOfClass:[NSNull class]] &&
        ![password isKindOfClass:[NSNull class]]){
        
        [queryArray addObject:[NSString stringWithFormat:@"password=%@", password]];
        if ([username length] != 0 && [mailAddress length] == 0){
            [queryArray addObject:[NSString stringWithFormat:@"userName=%@", username]];
        } else if ([username length] == 0 && [mailAddress length] != 0){
            [queryArray addObject:[NSString stringWithFormat:@"mailAddress=%@", mailAddress]];
        }
        sortedQueryArray = [NSArray arrayWithArray:[queryArray sortedArrayUsingSelector:@selector(compare:)]];
    }
    
    //pathの作成
    NSString *path = @"";
    for (int i = 0; i< [sortedQueryArray count]; i++){
        if (i == 0){
            path = [path stringByAppendingString:[NSString stringWithFormat:@"%@", sortedQueryArray[i]]];
        } else {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&%@", sortedQueryArray[i]]];
        }
    }
    NSData *strData = [path dataUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"login?%@", path];
    return [[NCMBURLConnection alloc] initWithPath:url method:@"GET" data:strData];
}

/**
 同期ログイン処理
 @param username　ユーザー名
 @param email　メールアドレス
 @param password　パスワード
 @param error エラー
 */
+ (NCMBUser *)ncmbLogIn:(NSString *)username
            mailAddress:(NSString *)email
               password:(NSString *)password
                  error:(NSError **)error{
    
    NSError *errorLocal = nil;

    //通信開始
    NCMBURLConnection *connect = [self createConnectionForLogin:username
                                                    mailAddress:email
                                                       password:password];
    NSDictionary * responseData = [connect syncConnection:&errorLocal];
    NCMBUser *loginUser = nil;
    if (!errorLocal){
        loginUser = [self responseLogIn:responseData];
        [self saveToFileCurrentUser:loginUser];
    } else {
        *error = errorLocal;
    }
    return loginUser;
}

/**
 非同期ログイン処理
 @param username　ユーザー名
 @param email　メールアドレス
 @param password　パスワード
 @param block
 */
+ (void)ncmbLogInInBackground:(NSString *)username
                  mailAddress:(NSString *)email
                     password:(NSString *)password
                        block:(NCMBUserResultBlock)block{
    
    //リクエストを作成
    NCMBURLConnection *request = [self createConnectionForLogin:username
                                                    mailAddress:email
                                                       password:password];
    //非同期通信を実行
    [request asyncConnectionWithBlock:^(NSDictionary *responseData, NSError *error){
        NCMBUser *loginUser = nil;
        if (!error){
            loginUser = [self responseLogIn:responseData];
            [self saveToFileCurrentUser:loginUser];
        }
        if (block) {
            block(loginUser,error);
        }
    }];
}

/**
 ログイン系のレスポンス処理
 @param responseData　サーバーからのレスポンスデータ
 @return NCMBUser型サーバーのデータを反映させたユーザー
 */
+(NCMBUser *)responseLogIn:(NSDictionary *)responseData{
    NCMBUser *loginUser = [NCMBUser user];
    NSMutableDictionary *responseDic = [NSMutableDictionary dictionaryWithDictionary:responseData];
    [loginUser afterFetch:responseDic isRefresh:YES];
    return loginUser;
}



#pragma mark - logout

/**
 同期でログアウトを行う
 */
+ (void)logOut{
    NSError *errorLocal = nil;
    NCMBURLConnection *connect = [[NCMBURLConnection new] initWithPath:URL_LOGOUT method:@"GET" data:nil];
    [connect syncConnection:&errorLocal];
    if (errorLocal==nil) {
        [self logOutEvent];
    }
}

/**
 非同期でログアウトを行う
 @param block ログアウトのリクエストをした後に実行されるblock
 */
+ (void)logOutInBackgroundWithBlock:(NCMBErrorResultBlock)block{
    NCMBURLConnection *connect = [[NCMBURLConnection new] initWithPath:URL_LOGOUT method:@"GET" data:nil];
    [connect asyncConnectionWithBlock:^(id response, NSError *error) {
        if (!error) {
            [self logOutEvent];
            block(nil);
        } else {
            block(error);
        }
    }];
}

/**
 ログアウトの処理
 */
+ (void)logOutEvent{
    if (currentUser) {
        currentUser.sessionToken = nil;
        currentUser = nil;
    }
#if __has_include(<FacebookSDK/FacebookSDK.h>) || __has_include(<FBSDKLoginKit/FBSDKLoginKit.h>)
    
    //Facebookのセッションを削除
    [NCMBFacebookUtils clearFacebookSession];
#endif
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTUSER_PATH isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:DATA_CURRENTUSER_PATH error:nil];
    }
}

#pragma mark requestPasswordResetForEmail

/**
 同期でパスワードリセット要求を行う。
 @param error
 */
+ (void)requestPasswordResetForEmail:(NSString *)email
                               error:(NSError **)error{
    [NCMBUser requestMailFromNCMB:URL_PASSWOR_RESET mail:email error:error];
}

/**
 非同期でパスワードリセット要求を行う。
 @param target
 @param selector
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email
                                          target:(id)target
                                        selector:(SEL)selector{
    [NCMBUser requestMailFromNCMB:URL_PASSWOR_RESET mail:email target:target selector:selector];
}


/**
 非同期でパスワードリセット要求を行う。
 @param block
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email
                                           block:(NCMBErrorResultBlock)block{
    [NCMBUser requestMailFromNCMB:URL_PASSWOR_RESET mail:email block:block];
}

#pragma mark - file

+(NCMBUser*)getFromFileCurrentUser{
    NCMBUser *user = [NCMBUser user];
    [user setACL:[[NCMBACL alloc]init]];
    NSError *error = nil;
    NSString *str = [[NSString alloc] initWithContentsOfFile:DATA_CURRENTUSER_PATH encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
    
    if ([data isKindOfClass:[NSData class]] && [data length] != 0){
        
        dicData = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:&error];
        if ([[dicData allKeys] containsObject:@"data"] &&
            [[dicData allKeys] containsObject:@"className"] &&
            [dicData count] == 2){
            //v1の形式でファイルを保存していた場合
            [user afterFetch:[NSMutableDictionary dictionaryWithDictionary:dicData[@"data"]] isRefresh:YES];
        } else {
            [user afterFetch:[NSMutableDictionary dictionaryWithDictionary:dicData] isRefresh:YES];
        }
    }
    return user;
}

/**
 ログインユーザーをファイルに保存する
 @param NCMBUSer型ファイルに保存するユーザー
 */
+ (void) saveToFileCurrentUser:(NCMBUser *)user {
    NSError *e = nil;
    NSMutableDictionary *dic = [user toJSONObjectForDataFile];
    NSData *json = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&e];
    NSString *strSaveData = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    [strSaveData writeToFile:DATA_CURRENTUSER_PATH atomically:YES encoding:NSUTF8StringEncoding error:&e];
    currentUser = user;
}

/**
 ファイルに書き込むためユーザー情報作成
 @return NSMutableDictionary型ユーザー情報
 */
- (NSMutableDictionary *)toJSONObjectForDataFile{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (id key in [estimatedData keyEnumerator]) {
        [dic setObject:[self convertToJSONFromNCMBObject:[estimatedData valueForKey:key]] forKey:key];
    }
    if (self.objectId) {
        [dic setObject:self.objectId forKey:@"objectId"];
    }
    if (self.createDate){
        NSDateFormatter *df = [self createNCMBDateFormatter];
        [dic setObject:[df stringFromDate:self.createDate] forKey:@"createDate"];
    }
    if (self.updateDate){
        NSDateFormatter *df = [self createNCMBDateFormatter];
        [dic setObject:[df stringFromDate:self.updateDate] forKey:@"updateDate"];
    }
    if(self.sessionToken){
        [dic setObject:self.sessionToken forKey:@"sessionToken"];
    }
    if (self.ACL) {
        [dic setObject:self.ACL.dicACL forKey:@"acl"];
    }
    return dic;
}


#pragma mark - override

/**
 ローカルオブジェクトをリセットし、ログアウトする
 */
- (void)afterDelete{
    [super afterDelete];
    self.userName = nil;
    self.password = nil;
    self.sessionToken = nil;
    self.mailAddress = nil;
    [NCMBUser logOutEvent];
}

- (void)afterFetch:(NSMutableDictionary *)response isRefresh:(BOOL)isRefresh{
    if ([response objectForKey:@"userName"]){
        self.userName = [response objectForKey:@"userName"];
    }
    if ([response objectForKey:@"mailAddress"]){
        self.mailAddress = [response objectForKey:@"mailAddress"];
    }
    if ([response objectForKey:@"sessionToken"]) {
        self.sessionToken = [response objectForKey:@"sessionToken"];
    }
    [super afterFetch:response isRefresh:isRefresh];
}

/**
 オブジェクト更新後に操作履歴とestimatedDataを同期する
 @param response REST APIのレスポンスデータ
 @param operations 同期する操作履歴
 */
-(void)afterSave:(NSDictionary*)response operations:(NSMutableDictionary *)operations{
    [super afterSave:response operations:operations];
    if ([response objectForKey:@"sessionToken"]){
        [self setSessionToken:[response objectForKey:@"sessionToken"]];
    }
    //会員新規登録の有無
    //if ([response objectForKey:@"createDate"]&&![response objectForKey:@"updateDate"]){
    if ([response objectForKey:@"createDate"] && [response objectForKey:@"updateDate"]){
        if ([response objectForKey:@"createDate"] == [response objectForKey:@"updateDate"]){
            _isNew = YES;
        }
    }else{
        _isNew = NO;
    }
    
    //SNS連携(匿名ユーザー等はリクエスト時にuserNameを設定しない)時に必要
    if ([response objectForKey:@"userName"]){
        [estimatedData setObject:[response objectForKey:@"userName"] forKey:@"userName"];
    }
    //SNS連携時に必要
    //if (![[response objectForKey:@"authData"] isKindOfClass:[NSNull class]]){
    if ([response objectForKey:@"authData"]){
        if([[response objectForKey:@"authData"] isKindOfClass:[NSNull class]]){
        } else {
            NSDictionary *authDataDic = [response objectForKey:@"authData"];
            NSMutableDictionary *converted = [NSMutableDictionary dictionary];
            for (NSString *key in [[authDataDic allKeys] objectEnumerator]){
                [converted setObject:[self convertToNCMBObjectFromJSON:[authDataDic objectForKey:key]
                                                            convertKey:key]
                              forKey:key];
            }
            [estimatedData setObject:converted forKey:@"authData"];
        }
    }
    [NCMBUser saveToFileCurrentUser:self];
}

#pragma mark - link

/**
 他の認証方法でログイン中のcurrentUserに、googleの認証情報を紐付ける
 @param googleInfo googleの認証情報（idとaccess_token）
 @param block 既存のauthDataのgoogle情報のみ更新後実行されるblock。エラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)linkWithGoogleToken:(NSDictionary *)googleInfo withBlock:(NCMBErrorResultBlock)block{
    // ローカルデータを取得
    NSMutableDictionary *localAuthData = [NSMutableDictionary dictionary];
    if([[self objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
        localAuthData = [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:@"authData"]];
    }
    //既存のauthDataのgoogle情報のみ更新する
    NSMutableDictionary *userAuthData = [NSMutableDictionary dictionary];
    [userAuthData setObject:googleInfo forKey:AUTH_TYPE_GOOGLE];
    [self setObject:userAuthData forKey:@"authData"];
    [self saveInBackgroundWithBlock:^(NSError *error) {
        if (!error){
            // ローカルデータから既にあるauthDataを取得してgoogleInfoをマージ
            [localAuthData setObject:googleInfo forKey:AUTH_TYPE_GOOGLE];
        }
        [estimatedData setObject:localAuthData forKey:@"authData"];
        // ログインユーザーをファイルに保存する
        [NCMBUser saveToFileCurrentUser:self];
        if(block){
            block(error);
        }
    }];
}

/**
 会員情報に、引数で指定したtypeの認証情報が含まれているか確認する
 @param type 認証情報のtype（googleもしくはtwitter、facebook、anonymous）
 @return 引数で指定したtypeの会員情報が含まれている場合はYESを返す
 */
- (BOOL)isLinkedWith:(NSString *)type{
    
    BOOL isLinkerFlag = NO;
    if ([type isEqualToString:AUTH_TYPE_GOOGLE]
        || [type isEqualToString:AUTH_TYPE_TWITTER]
        || [type isEqualToString:AUTH_TYPE_FACEBOOK]
        || [type isEqualToString:AUTH_TYPE_ANONYMOUS])
    {
        if ([self objectForKey:@"authData"] && [[self objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]) {
            if ([[self objectForKey:@"authData"] objectForKey:type]) {
                isLinkerFlag = YES;
            }
        }
    }
    return isLinkerFlag;
}

/**
 会員情報から、引数で指定したtypeの認証情報を削除する
 @param type 認証情報のtype（googleもしくはtwitter、facebook、anonymous）
 @param block エラー情報を返却するblock エラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)unlink:(NSString *)type withBlock:(NCMBErrorResultBlock)block{
    
    // Userから指定したtypeの認証情報を削除する
    if ([[self objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
        // 指定したtypeと同じ認証情報の場合は削除する
        if ([self isLinkedWith:type]) {
            // ローカルデータを取得
            NSMutableDictionary *localAuthData = [NSMutableDictionary dictionary];
            if([[self objectForKey:@"authData"] isKindOfClass:[NSDictionary class]]){
                localAuthData = [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:@"authData"]];
            }
            // 削除する認証情報を取得
            NSMutableDictionary *authData = [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:@"authData"]];
            // 引数で指定した認証情報を削除
            [authData setObject:[NSNull null] forKey:type];
            
            [self setObject:authData forKey:@"authData"];
            [self saveInBackgroundWithBlock:^(NSError *error) {
                if (!error){
                    // ローカルデータから既にあるauthDataを取得してgoogleInfoをマージ
                    [localAuthData removeObjectForKey:type];
                }
                [estimatedData setObject:localAuthData forKey:@"authData"];
                // ログインユーザーをファイルに保存する
                [NCMBUser saveToFileCurrentUser:self];
                if (block){
                    block(error);
                }
            }];
        } else {
            // 指定したtype以外の認証情報の場合はエラーを返す
            if (block){
                NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                     code:404003
                                                 userInfo:@{NSLocalizedDescriptionKey:@"other token type"}];
                block(error);
            }
        }
    } else {
        // 認証情報がない場合エラーを返す
        if (block){
            NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:404003
                                             userInfo:@{NSLocalizedDescriptionKey:@"token not found"}];
            block(error);
        }
    }
}

@end
