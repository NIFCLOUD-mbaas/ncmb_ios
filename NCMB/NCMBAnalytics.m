//
//  NCMBAnalytics.m
//  NCMB
//
//  Created by SCI01433 on 2014/11/07.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

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
    if (pushId != nil && installation != nil){
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
    }
}

@end
