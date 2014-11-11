//
//  NCMB.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/04.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMB.h"

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
    //[NCMB createFolder];
    //[NCMB setApplicationKey:applicationKey];
    //[NCMB setClientKey:clientKey];
    //dispatch_queue_t main=dispatch_get_main_queue();
    //dispatch_queue_t sub=dispatch_queue_create("reachabilityChanged", NULL);
    //dispatch_async(sub, ^{
    //   if ([NCMB_REACHABILITY checkStart]) {
    //        [NCMBCommandCache handleCache:nil];
    //    }
    //    dispatch_async(main, ^{
    //    });
    //});
    //dispatch_release(sub);
    [NCMB createFolder];
    applicationKey = appKey;
    clientKey = cliKey;
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
 ファイルを保存(書込)する場所を確保する
 */
+(void)createFolder{
    //ライブラリファイルのパスを取得
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* dirName = [paths objectAtIndex:0];
    //ファイル作成
    [NCMB saveDirPath:dirName str:@"Private Documents"];
    [NCMB saveDirPath:[NSString stringWithFormat:@"%@/Private Documents",dirName] str:@"NCMB"];//ユーザー情報書込に使用
    //TODO:Cache実装時に必要なら作成
    [NCMB saveDirPath:[NSString stringWithFormat:@"%@/Private Documents/NCMB",dirName] str:@"Command Cache"];
    //[NCMB saveDirPath:[NSString stringWithFormat:@"%@/Private Documents/NCMB",dirName] str:@"CacheID"];
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
        [fileManager changeCurrentDirectoryPath:dirName];
        [fileManager createDirectoryAtPath:str withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


@end
