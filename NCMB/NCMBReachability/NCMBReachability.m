/*
 Copyright 2017 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMBReachability.h"
#import "NCMBURLConnection.h"
#import "NCMBConstants.h"

#import <objc/runtime.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <net/if.h>

static NSString *const kHostName = @"mb.api.cloud.nifty.com";

/**
 通信状況が変化した際に呼び出されるコールバックメソッド
 */
static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags, void* info){
    //電波状況の更新
    [NCMBReachability updateFlags:flags];
    
    //通信状況に応じてファイルに書き出した処理を実行するメソッドを呼び出す
    [[NCMBReachability sharedInstance] reachabilityChanged];
}


static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
    
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
}

@implementation NCMBReachability {
    SCNetworkReachabilityRef internetReachabilityRef;
    SCNetworkReachabilityFlags internetReachabilityFlags;
    SCNetworkReachabilityRef reachabilityRef;
    SCNetworkReachabilityFlags reachabilityFlags;
}

static NCMBReachability *ncmbReachability = nil;

/**
 APIのエンドポイントを指定して、インターネット接続確認用のリファレンスを作成
 */
- (NCMBReachability *)init{
    self->internetReachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [kHostName UTF8String]);
    return self;
}

/**
 シングルトンクラスのインスタンスを返す
 */
+(NCMBReachability*)sharedInstance{
    @synchronized(self){
        if (!ncmbReachability){
            ncmbReachability = [[NCMBReachability alloc] init];
            [ncmbReachability reachabilityWithHostName:kHostName];
        }
    }
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
        reachabilityRef = reachability;
        SCNetworkReachabilityGetFlags(reachabilityRef, &reachabilityFlags);
    }
}

/**
 電波状況を更新
 */
+(void)updateFlags:(SCNetworkReachabilityFlags)flags{
    [NCMBReachability sharedInstance]->reachabilityFlags = flags;
}

/**
 電波状況が変化したときに保存された処理一覧を取得する
 */
- (void)reachabilityChanged{
    dispatch_queue_t sub_queue = dispatch_queue_create("reachabilityChange", NULL);
    dispatch_async(sub_queue, ^{
        //ファイルから処理内容を取り出す
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath: COMMAND_CACHE_FOLDER_PATH
                                                             error: NULL];
        //ファイルが無い場合は監視を終了
        if ([contents count] == 0){
            ncmbReachability = nil;
        } else {
            for (NSString *fileName in contents){
                [self executeCommand:fileName];
            }
        }
    });
}

/**
 ファイルに書き出された処理を実行する
 ファイル削除後にオフラインになっていた場合はファイル復元を復元する
 */
- (void)executeCommand:(NSString*)fileName{
    //非同期で更新された電波状況を見て、通信可能であればファイルの処理を実行
    if ([self isReachableToTarget]){
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", COMMAND_CACHE_FOLDER_PATH, fileName];
        if ([fileManager fileExistsAtPath:filePath]) {
            
            //各ファイルから処理内容を取り出す
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSDictionary *dictForEventually = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
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
            
            //ファイルを削除する
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", COMMAND_CACHE_FOLDER_PATH, fileName] error:nil];
            
            //APIリクエスト用コネクションを作成
            NCMBURLConnection *connect = [[NCMBURLConnection new] initWithPath:url method:method data:saveData];
            
            //同期通信を実行
            NSError *error = nil;
            [connect syncConnection:&error] ;
            if (error){
                if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorNetworkConnectionLost){
                    //オフライン時はファイルを復元する
                    [data writeToFile:[NSString stringWithFormat:@"%@%@", COMMAND_CACHE_FOLDER_PATH, fileName] options:NSDataWritingAtomic error:nil];
                }
                
            }
        }
    }
}

/**
 電波状況の監視を開始する
 @return 問題なく開始できた場合はYESを返す
 */
- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    //電波状況が変化したときに呼び出されるコールバックを指定する
    if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context))
    {
        //電波状況の監視をスタートさせる
        if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

- (void)stopNotifier
{
    if (reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
    }
}

/**
 現在の通信状況を取得する
 @return 通信状況が取得できた場合にtrueを返却する
 */
- (BOOL)getCurrentReachabilityStatus{
    //名前解決できるかをチェック
    if (SCNetworkReachabilityGetFlags(internetReachabilityRef, &internetReachabilityFlags)){
        //ターゲットへの接続状況を取得
        if ((internetReachabilityFlags & kSCNetworkReachabilityFlagsReachable) != 0){
            return SCNetworkReachabilityGetFlags(reachabilityRef, &reachabilityFlags);
        } else {
            return NO;
        }
    }
    return NO;
    
}

/**
 指定したホスト名にアクセスできる状態かをチェックする
 @return アクセスできる場合はYESを返す
 */
- (BOOL)isReachableToTarget{
    
    if ((reachabilityFlags & kSCNetworkReachabilityFlagsReachable ) != 0)
    {
        //ターゲットへのアクセスが可能である場合
        if ((reachabilityFlags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
        {
            //ターゲットへのコネクションが
            return YES;
        }
    }
    
    return NO;
}
 
@end
