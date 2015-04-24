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

//FacebookSDKがincludeされているアプリの場合のみビルドする
#if defined(__has_include)
#if __has_include(<FacebookSDK/FacebookSDK.h>) || __has_include(<FBSDKLoginKit/FBSDKLoginKit.h>)

#if __has_include(<FacebookSDK/FacebookSDK.h>)
#import <FacebookSDK/FacebookSDK.h>
#else
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif

#import "NCMBFacebookUtils.h"
#import "NCMBUser+Private.h"
#import "NCMBURLConnection.h"
#import "NCMBAnonymousUtils.h"
#import "NCMBObject+Private.h"
#import "NCMBACL.h"
#import "NCMBError.h"

#define AUTH_TYPE_FACEBOOK              @"facebook"
#define FACEBOOKAPPID_KEY               @"FacebookAppID"
#define AUTHDATA_ID_KEY                 @"id"
#define AUTHDATA_ACCESS_TOKEN_KEY       @"access_token"
#define AUTHDATA_EXPIRATION_DATE_KEY    @"expiration_date"

@implementation NCMBFacebookUtils

#pragma mark login With Facebook Account

/**
 引数のパーミッションが許可されたFacebookのaccess tokenをもとに、
 mobile backendへの会員登録または会員情報の更新を行う
 @param linkUser Facebookのaccess tokenを紐付ける会員。nilだった場合は会員登録を行う。
 @param permission Facebook認証時にリクエストするパーミッション
 @param readPermissionFlag readPermissionの場合にYESを設定する
 @param block mobile backendへの会員登録をリクエストしたあとに実行される処理
 */
+ (void)signUpToNCMB:(NCMBUser*)linkUser
      withPermission:(NSArray *)permission
  readPermissionFlag:(BOOL)readPermissionFlag
               block:(NCMBUserResultBlock)block
{
    
    NCMBUser *user = nil;
    if (linkUser && [linkUser isKindOfClass:[NCMBUser class]]){
        user = linkUser;
    } else {
        user = [NCMBUser currentUser];
        if (user == nil){
            user = [NCMBUser user];
        }
    }
    
    //currentUserがFacebookアカウントで認証済みかを確認する
    if ([self isLinkedWithUser:user]){
        
        //認証済みであれば、既存のauthDataでmobile backendへのログインを実施
        NSDictionary *facebookInfo = nil;
        facebookInfo = [NSDictionary dictionaryWithObject:[[user objectForKey:@"authData"] objectForKey:@"facebook"] forKey:@"facebook"];
        [self signUp:user facebookInfo:facebookInfo block:block];
    } else {
        
        //認証済みでなければ、有効なaccessTokenがあるか確認
        //if ([FBSDKAccessToken currentAccessToken]){
        if ([self isValidFacebookAccessToken]){
            
            //有効なaccessTokenがあればそれで会員登録を実施
            NSDictionary *facebookInfo = [self returnFacebookAuthDataFromAccessToken];
            
            //mobile backendへのログインを実施
            [self signUp:user facebookInfo:facebookInfo block:block];
            
        } else {
            
            //なければFacebookLoginを実施
            if (readPermissionFlag){
                [self logInToFacebook:user
                   withReadPermission:permission
                                block:block];
            } else {
                [self logInToFacebook:user
                   withPublishPermission:permission
                                block:block];
            }
        }
        
    }
}

+ (void)logInWithReadPermission:(NSArray *)readPermission block:(NCMBUserResultBlock)block{
    [self signUpToNCMB:nil withPermission:readPermission readPermissionFlag:YES block:block];
}

+ (void)logInWithReadPermission:(NSArray *)readPermission target:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self logInWithReadPermission:readPermission block:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

+ (void)logInWithPublishingPermission:(NSArray *)publishingPermission block:(NCMBUserResultBlock)block{
    [self signUpToNCMB:nil withPermission:publishingPermission readPermissionFlag:NO block:block];
}

+ (void)logInWithPublishingPermission:(NSArray *)publishingPermission target:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self logInWithPublishingPermission:publishingPermission block:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

#pragma mark linkUser

+ (void)linkUser:(NCMBUser *)user withReadPermission:(NSArray *)readPermission block:(NCMBUserResultBlock)block{
    [self signUpToNCMB:user withPermission:readPermission readPermissionFlag:YES block:block];
}

+ (void)linkUser:(NCMBUser *)user
withReadPermission:(NSArray *)readPermission
          target:(id)target
        selector:(SEL)selector
{
    
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self linkUser:user withReadPermission:readPermission block:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

+ (void)linkUser:(NCMBUser *)user
withPublishingPermission:(NSArray *)publishingPermission
           block:(NCMBUserResultBlock)block
{
    [self signUpToNCMB:user withPermission:publishingPermission readPermissionFlag:NO block:block];
}

+ (void)linkUser:(NCMBUser *)user
withPublishingPermission:(NSArray *)readPermission
          target:(id)target
        selector:(SEL)selector
{
    
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target and selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self linkUser:user withPublishingPermission:readPermission block:^(NCMBUser *user, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&user atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

+ (void)unLinkUser:(NCMBUser *)user withBlock:(NCMBUserResultBlock)block{
    if ([user isKindOfClass:[NCMBUser class]]){
        NSMutableDictionary *authData = nil;
        authData = [NSMutableDictionary dictionaryWithDictionary:[user objectForKey:@"authData"]];
        
        if (authData && [[authData allKeys] containsObject:@"facebook"]){
            
            [authData removeObjectForKey:@"facebook"];
            [user setObject:authData forKey:@"authData"];
            [user saveInBackgroundWithBlock:^(NSError *error) {
                if (block){
                    block(user, error);
                }
            }];
        } else {
            
            //facebookの認証情報がなかった場合
            NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                                 code:404003
                                             userInfo:@{NSLocalizedDescriptionKey:@"Facebook token not found."}];
            block(user,error);
        }
    } else {
        
        //user以外が指定されている場合のエラーを返す
        NSError *error = [NSError errorWithDomain:ERRORDOMAIN
                                             code:400002
                                         userInfo:@{NSLocalizedDescriptionKey:@"User is invalid type."}];
        block(user,error);
    }
}

+ (void)unLinkUser:(NCMBUser *)user withTarget:(id)target selector:(SEL)selector{
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

#pragma mark isLinkedWithUser
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
#pragma mark Utilities

/**
 引数のreadPermissionの内容をリクエストして、Facebookのログインを行う
 */
+ (void)logInToFacebook:(NCMBUser*)user
     withReadPermission:(NSArray*)readPermission
                  block:(NCMBUserResultBlock)block
{
#if __has_include(<FacebookSDK/FacebookSDK.h>)
    [FBSession openActiveSessionWithReadPermissions:readPermission
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         if (error) {
             if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled){
                 NSError *ncmbError = [NSError errorWithDomain:ERRORDOMAIN
                                                          code:NCMBErrorFacebookLoginCancelled
                                                      userInfo:nil
                                       ];
                 if (block){
                     block(nil,ncmbError);
                 }
             } else {
                 if (block){
                     block(nil, error);
                 }
             }
         } else {
             
             //アクセストークンからfacebookInfoを取得
             FBAccessTokenData *tokenData = session.accessTokenData;
             if (tokenData){
                 NSDictionary *facebookInfo = @{@"facebook":@{@"id":tokenData.userID,
                                                              @"access_token":tokenData.accessToken,
                                                              @"expiration_date":tokenData.expirationDate
                                                              }
                                                };
                 
                 //mobile backendへのログインを実施
                 [self signUp:user facebookInfo:facebookInfo block:block];
             }
         }
     }];
#else
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:readPermission
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {


        if (error) {
            if (block){
                block(nil,error);
            }
        } else if (result.isCancelled) {
            // Handle cancellations
            NSError *ncmbError = [NSError errorWithDomain:ERRORDOMAIN
                                                     code:NCMBErrorFacebookLoginCancelled
                                                 userInfo:nil
                                  ];
            if (block){
                block(nil,ncmbError);
            }
        } else {
            
            //アクセストークンからfacebookInfoを取得
            NSDictionary *facebookInfo = [self returnFacebookAuthDataFromAccessToken];
            
            //mobile backendへのログインを実施
            [self signUp:user facebookInfo:facebookInfo block:block];
        }
    }];
#endif
}

/**
 引数のpublishingPermissionの内容をリクエストして、Facebookのログインを行う
 */
+ (void)logInToFacebook:(NCMBUser*)user
     withPublishPermission:(NSArray*)publishPermission
                  block:(NCMBUserResultBlock)block
{
#if __has_include(<FacebookSDK/FacebookSDK.h>)
    [FBSession openActiveSessionWithPublishPermissions:publishPermission
                                       defaultAudience:FBSessionDefaultAudienceFriends
                                          allowLoginUI:YES
                                     completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         if (error) {
             if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled){
                 NSError *ncmbError = [NSError errorWithDomain:ERRORDOMAIN
                                                          code:NCMBErrorFacebookLoginCancelled
                                                      userInfo:nil
                                       ];
                 if (block){
                     block(nil,ncmbError);
                 }
             } else {
                 if (block){
                     block(nil, error);
                 }
             }
         } else {
             
             //アクセストークンからfacebookInfoを取得
             FBAccessTokenData *tokenData = session.accessTokenData;
             if (tokenData){
                 NSDictionary *facebookInfo = @{@"facebook":@{@"id":tokenData.userID,
                                                              @"access_token":tokenData.accessToken,
                                                              @"expiration_date":tokenData.expirationDate
                                                              }
                                                };
                 
                 //mobile backendへのログインを実施
                 [self signUp:user facebookInfo:facebookInfo block:block];
             }
             
         }
     }];
#else
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithPublishPermissions:publishPermission
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            if (block){
                block(nil,error);
            }
        } else if (result.isCancelled) {

            // Handle cancellations
            NSError *ncmbError = [NSError errorWithDomain:ERRORDOMAIN
                                                     code:NCMBErrorFacebookLoginCancelled
                                                 userInfo:nil
                                  ];
            if (block){
                block(nil,ncmbError);
            }
        } else {

            //アクセストークンからfacebookInfoを取得
            NSDictionary *facebookInfo = [self returnFacebookAuthDataFromAccessToken];
                                           
            //mobile backendへのログインを実施
            [self signUp:user facebookInfo:facebookInfo block:block];
        }
    }];

                                       
#endif
                                      
}

/**
 FacebookのauthDataでmobile backendへの会員登録を実行する
 @param user 会員登録を行うNCMBUserのインスタンス
 @param facebookInfor mobile backendに会員登録するためのfacebookの認証情報
 @param block 会員登録実行後に行う処理
 */
+ (void)signUp:(NCMBUser*)user
  facebookInfo:(NSDictionary*)facebookInfo
         block:(NCMBUserResultBlock)block{
    [user signUpWithFacebookToken:facebookInfo block:^(NSError *error) {
        if (block){
            if (error){
                block(nil,error);
            } else {
                block(user, error);
            }
        }
    }];
}


/**
 有効なFacebook Access Tokenがないかをチェックする
 @return 有効なFacebook Access Tokenがある場合はYESを返す
 */
+ (BOOL)isValidFacebookAccessToken{

#if __has_include(<FacebookSDK/FacebookSDK.h>)
    FBSession *session = [FBSession activeSession];
    if(session.state == FBSessionStateOpen && session.accessTokenData != nil){
#else
    if([FBSDKAccessToken currentAccessToken] != nil){
#endif
        return YES;
    } else {
        return NO;
    }
}

/**
 Facebook Access Tokenを取得してcurrentUserでログインする
 ログイン後は引数のblockを実行する
 @param block mobile backendへのログインをリクエストしたあとに実行されるブロック
 */
+(NSDictionary*)returnFacebookAuthDataFromAccessToken{
    
    NSDictionary *facebookInfo = nil;

#if __has_include(<FacebookSDK/FacebookSDK.h>)
    FBSession *session = [FBSession activeSession];
    FBAccessTokenData *token = session.accessTokenData;
    if (token != nil){
        facebookInfo = @{@"facebook":@{@"id":token.userID,
                                       @"access_token":token.accessToken,
                                       @"expiration_date":token.expirationDate}
                         };
    }
#else
    //アクセストークンからfacebookInfoを取得
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token != nil){
        facebookInfo = @{@"facebook":@{@"id":token.userID,
                                       @"access_token":token.tokenString,
                                       @"expiration_date":token.expirationDate}
                         };
    }
#endif
    return facebookInfo;
    
}

    
+(void)clearFacebookSession{
#if __has_include(<FacebookSDK/FacebookSDK.h>)
    FBSession *session = [FBSession activeSession];
    if (session){
        [session closeAndClearTokenInformation];
    }
#else
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (token){
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
    }
#endif
}

@end

#endif
#endif