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

#import <Foundation/Foundation.h>

/**
 NCMBAnalyticsクラスは、プッシュ通知の開封をニフティクラウドmobile backendに登録するクラスです。
 */
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
