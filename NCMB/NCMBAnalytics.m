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

#import <UIKit/UIKit.h>
#import "NCMBAnalytics.h"
#import "NCMBPush.h"
#import "NCMBURLConnection.h"
#import "NCMBInstallation.h"

@implementation NCMBAnalytics

+(void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions{
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    [self trackAppOpenedWithRemoteNotificationPayload:userInfo];
}

+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo{
    NSString * pushId = [userInfo objectForKey:@"com.nifty.PushId"];
    NCMBInstallation *installation = [NCMBInstallation currentInstallation];
    if (pushId != nil && installation.deviceToken != nil){
        //コネクションを作成
        NSDictionary *requestData = @{@"deviceType":installation.deviceType,
                                     @"deviceToken":installation.deviceToken
                                     };
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:requestData
                                                       options:kNilOptions
                                                         error:&error];
        NSString *url = [NSString stringWithFormat:@"push/%@/openNumber", pushId];
        NCMBURLConnection *connect = [[NCMBURLConnection alloc] initWithPath:url
                                                                      method:@"POST" data:json];
        [connect asyncConnectionWithBlock:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

@end
