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

#import "NCMB.h"
#if __has_include(<UserNotifications/UserNotifications.h>)
#import <UserNotifications/UserNotifications.h>
#endif
#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

@implementation NCMB

static NSString *applicationKey = nil;
static NSString *clientKey = nil;
static BOOL responseValidationFlag = false;

#pragma mark - init

/**
 アプリケーションキーとクライアントキーの設定
 @param applicationKey アプリケーションを一意に識別するキー
 @param clientKey APIを利用する際に必要となるキー
 */
+ (void)setApplicationKey:(NSString *)appKey clientKey:(NSString *)cliKey{
    [NCMB createFolder];
    applicationKey = appKey;
    clientKey = cliKey;
    NCMBReachability *reachability = [NCMBReachability sharedInstance];
    //[reachability reachabilityWithHostName:@"mb.api.cloud.nifty.com"];
    [reachability startNotifier];
    
}

#pragma mark - Key
+ (NSString *)getApplicationKey{
    return applicationKey;
}

+ (NSString *)getClientKey{
    return clientKey;
}

#pragma mark - ResponseValidation
+ (BOOL)getResponseValidationFlag{
    return responseValidationFlag;
}

+ (void)enableResponseValidation:(BOOL)checkFlag{
    responseValidationFlag = checkFlag;
}

#pragma mark - File

/**
 SDKで利用するファイルの保存ディレクトリを作成する
 */
+(void)createFolder{
    //ライブラリファイルのパスを取得
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* dirName = [paths objectAtIndex:0];
    
    //SDKで利用するフォルダを作成
    [NCMB saveDirPath:dirName str:@"Private Documents"];
    [NCMB saveDirPath:[NSString stringWithFormat:@"%@/Private Documents",dirName] str:@"NCMB"];
    
    //SaveEventually用の処理内容保存場所
    [NCMB saveDirPath:[NSString stringWithFormat:@"%@/Private Documents/NCMB",dirName] str:@"Command Cache"];
    
}

/**
 ファイルの有無をチェックし、無ければ指定されたパスにファイルを作成する
 */
+(void)saveDirPath:(NSString*)dirName  str:(NSString*)str {
    //fileの保存先作成
    NSMutableString* saveFileDirPath = [NSMutableString string];
    [saveFileDirPath appendString:dirName];
    [saveFileDirPath appendString:[NSString stringWithFormat:@"/%@/",str]];
    
    //fileが存在するかチェックする。fileが存在しない場合のみ新規作成
    BOOL isYES = YES;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:saveFileDirPath isDirectory:&isYES];
    if( isExist == false ) {
        [fileManager createDirectoryAtPath:saveFileDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#if __has_include(<UIKit/UIKit.h>)
/**
 プッシュ通知アラート
 */
+(void)showConfirmPushNotification {
    // iOSのバージョンで処理を分ける
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10, 0, 0}]){
        #if __has_include(<UserNotifications/UserNotifications.h>)
        //iOS10以上での、DeviceToken要求方法
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                                 UNAuthorizationOptionBadge |
                                                 UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (error) {
                                      return;
                                  }
                                  if (granted) {
                                      //通知を許可にした場合DeviceTokenを要求
                                      [[UIApplication sharedApplication] registerForRemoteNotifications];
                                  }
                              }];
        #endif
    } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){8, 0, 0}]){
        //iOS10未満での、DeviceToken要求方法
        //通知のタイプを設定したsettingを用意
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIUserNotificationType type = UIUserNotificationTypeAlert |
        UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting;
        setting = [UIUserNotificationSettings settingsForTypes:type
                                                    categories:nil];
        
        //通知のタイプを設定
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        
        //DeviceTokenを要求
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        //iOS8未満での、DeviceToken要求方法
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert |
          UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound)];
    }
}
#endif

@end
