//
//  NCMBReachability.m
//  NCMB
//
//  Created by SCI01433 on 2014/10/29.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBReachability.h"
#import "NCMBObject.h"
#import "NCMBURLConnection.h"

#import <objc/runtime.h>

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    //NSCAssert([(__bridge NSObject*) info isKindOfClass: [NCMBReachability class]], @"info was wrong class in ReachabilityCallback");
 
    NSLog(@"ReachabilityCallBack");
    NCMBReachability* noteObject = (__bridge NCMBReachability *)info;
    [noteObject updateFlags:flags];
    // Post a notification to notify the client that the network reachability changed.
    //TODO:notificatonの名前を定数にする
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reachabilityChangedNotification"
                                                        object: noteObject];
}

@implementation NCMBReachability {
    SCNetworkReachabilityRef reachabilityRef;
    SCNetworkReachabilityFlags reachabilityFlags;
}

static NCMBReachability *ncmbReachability = nil;

/**
 シングルトンクラスのインスタンスを返す
 */
+(NCMBReachability*)sharedInstance{
    if (!ncmbReachability) ncmbReachability = [[NCMBReachability alloc] init];
    return ncmbReachability;
}

/**
 指定したhostNameにアクセスできるかを監視するインスタンスを返す
 @param hostName アクセスを確認するホスト名
 @return ホスト名が指定されたインスタンス
 */
- (void)reachabilityWithHostName:(NSString *)hostName{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL)
    {
        [NCMBReachability sharedInstance]->reachabilityRef = reachability;
    }
    [[NCMBReachability sharedInstance] startNotifier];
}

/**
 電波状況を更新
 */
-(void)updateFlags:(SCNetworkReachabilityFlags)flags{
    [NCMBReachability sharedInstance]->reachabilityFlags = flags;
}

/**
 ログ用
 */
- (void)reachabilityChanged{
    if ((reachabilityFlags & kSCNetworkReachabilityFlagsReachable) == 0){
        NSLog(@"endpoint not available...");
    } else {
        NSLog(@"endpoint available");
        //ファイルから処理内容を取り出す
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directoryPath = COMMAND_CACHE_FOLDER_PATH;
        NSMutableArray *contents = (NSMutableArray *)[fileManager contentsOfDirectoryAtPath: directoryPath
                                                                                      error: NULL];
        for (NSString *fileName in contents){
            NSLog(@"fileName:%@", fileName);
            NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@", directoryPath, fileName]];
            NSDictionary *dictForEventually = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            NSString *fetchTargetName = [dictForEventually objectForKey:@"targetName"];
            NSString *fetchSELName = [dictForEventually objectForKey:@"selectorName"];
            NSString *url = [dictForEventually objectForKey:@"path"];
            NSString *method = [dictForEventually objectForKey:@"method"];
            NSData *saveData = nil;
            if ([[dictForEventually allKeys] containsObject:@"saveData"]){
                NSDictionary *saveDic = [dictForEventually objectForKey:@"saveData"];
                NSError *error = nil;
                saveData = [NSJSONSerialization dataWithJSONObject:saveDic
                                                                   options:kNilOptions
                                                                     error:&error];
            }
            
            //ファイル削除
            NSError *deleteError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", COMMAND_CACHE_FOLDER_PATH, fileName] error:&deleteError];
            if (deleteError){
                NSLog(@"deleteError:%@", deleteError);
            }
            
            NCMBURLConnection *connect = [[NCMBURLConnection new] initWithPath:url method:method data:saveData];
            
            ncmbReachability = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [connect asyncConnectionWithBlock:^(NSDictionary *responseDic, NSError *error) {
                //TODO:エラーだったら履歴どうする

                //TODO:NCMBObjectに通知する？
                
                id target = objc_getClass([fetchTargetName UTF8String]);
                SEL selector = NSSelectorFromString(fetchSELName);
                NSMethodSignature *signature = [[target alloc] methodSignatureForSelector:selector];
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:[target alloc]];
                [invocation setSelector:selector];
                [invocation invoke];
            }];
        }
    }
}

/**
 電波状況の監視を開始する
 @return 問題なく開始できた場合はYESを返す
 */
- (BOOL)startNotifier
{
    //TODO:あとで消す
    NSLog(@"startNotifier");
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(reachabilityChanged)
               name:@"reachabilityChangedNotification"
             object:nil];
    
    return returnValue;
}

- (void)stopNotifier
{
    NSLog(@"stopNotifier");
    
    if (reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
    }
}
/**
 指定したホスト名にアクセスできる状態かをチェックする
 @return アクセスできる場合はYESを返す
 */
- (BOOL)isReachableWWAN{
    if ((reachabilityFlags & kSCNetworkReachabilityFlagsReachable) == 0){
        return NO;
    } else {
        return YES;
    }
}

- (void)dealloc
{
    [self stopNotifier];
    if (reachabilityRef != NULL)
    {
        CFRelease(reachabilityRef);
    }
}

@end
