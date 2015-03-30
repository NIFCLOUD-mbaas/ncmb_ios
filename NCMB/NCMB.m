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
        [fileManager changeCurrentDirectoryPath:dirName];
        [fileManager createDirectoryAtPath:str withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


@end
