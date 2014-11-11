//
//  NCMBAnalytics.h
//  NCMB
//
//  Created by SCI01433 on 2014/11/07.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBAnalytics : NSObject

/**
 アプリが起動された際に、情報を送信。didFinishLaunchingWithOptions内で呼び出す。
 @param launchOptions プッシュ通知内容を含むアプリケーションの起動オプション
 */
+ (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions;

/**
 プッシュ通知によりアプリが起動された際に、情報を送信。didReceiveRemoteNotification内で呼び出す
 @param userInfo プッシュ通知内容
 */
+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo;

@end
