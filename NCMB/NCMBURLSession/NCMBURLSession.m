/*
 Copyright 2017-2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMBURLSession.h"
#import "NCMBError.h"
#import "NCMB.h"
#import "NCMBUser.h"
#import "NCMBUser+Private.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NCMBURLSession

#pragma mark - Initializer


// 進捗状況取得デリゲートを指定して初期化を行う（NCMBFile用）
- (id)initWithProgress:(NCMBRequest*)request  progress:(void (^)(int progress))progress{
    self.blockProgress = progress;
    return [self initWithRequestAsync:request];
}

// 初期化を行う
- (id)initWithRequestSync:(NCMBRequest*)request {
    self.session = [NSURLSession sessionWithConfiguration:self.config delegate:self delegateQueue:nil];
    return [self initWithRequest:request cachePolicy:kNilOptions];
}

// 初期化を行う
- (id)initWithRequestAsync:(NCMBRequest*)request {
    // コールバックをメインスレッドで実行させるために[NSOperationQueue mainQueue]を設定する
    self.session = [NSURLSession sessionWithConfiguration:self.config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return [self initWithRequest:request cachePolicy:kNilOptions];
}

- (id)initWithRequest:(NCMBRequest*)request cachePolicy:(NSURLRequestCachePolicy)cachePolicy{
    self = [super init];
    
    self.request = request;
    self.responseData = [[NSMutableData alloc] init];
    
    // デフォルト設定
    self.config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.config.requestCachePolicy = cachePolicy;
    
    return self;
}

#pragma mark - AsyncConnection(非同期)

// 非同期通信で通信を行う
- (void)dataAsyncConnectionWithBlock:(NCMBResultBlock)block{
    self.block = block;
    self.dataTask = [self.session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

// 非同期通信でファイルのダウンロードを行う
- (void)fileDownloadAsyncConnectionWithBlock:(NCMBResultBlock)block{
    self.block = block;
    self.downloadTask = [self.session downloadTaskWithRequest:self.request];
    [self.downloadTask resume];
}

// 非同期通信でファイルのアップロードを行う
- (void)fileUploadAsyncConnectionWithBlock:(NCMBResultBlock)block{
    self.block = block;
    self.uploadTask = [self.session uploadTaskWithRequest:self.request fromData:self.request.HTTPBody];
    [self.uploadTask resume];
}

#pragma mark - after connection

/**
 レスポンスの処理を行う
 @param contents NSData型のレスポンスデータ
 @param response NSHTTPURLResponse型のレスポンス
 @param error エラーを保持するポインタ
 @return id型のレスポンスを返す
 */
- (id)convertResponse:(NSData*)contents
             response:(NSHTTPURLResponse*)response
                error:(NSError**)error
{
    if (response.statusCode == 200 || response.statusCode == 201){
        NSDictionary *responseDic = [NSDictionary dictionary];
        
        // レスポンスシグネチャの検証
        [self signatureCheck:response contentsData:contents error:error];
        
        //NCMBFile　getDataの場合はNSDataを返却
        NSRange range = [[response.URL absoluteString] rangeOfString:@"files/"];
        if (range.location != NSNotFound && [_request.HTTPMethod isEqualToString:@"GET"]) {
            *error = nil;
            return contents;
        }
        
        //削除の場合は空、それ以外はNSDictionaryが返却される
        responseDic = [self convertResponseToDic:contents error:error];
        
        return responseDic;
    } else {
        [self convertErrorFromJSON:contents response:response error:error];
        return [self convertResponseToDic:contents error:error];
    }
}

/**
 レスポンスのNSDataをNSDictionaryにセットする
 @param contentsData mBaaSから返却されるJSONデータ
 @param error エラー
 @return レスポンスのNSDictionary
 */
- (NSDictionary *)convertResponseToDic:(NSData *)contentsData error:(NSError **)error{
    NSError *convertErr = nil;
    NSDictionary *jsonDic = [NSDictionary dictionary];
    if ([contentsData isKindOfClass:[NSData class]] && [contentsData length] != 0){
        jsonDic = [NSJSONSerialization JSONObjectWithData:contentsData
                                                  options:NSJSONReadingAllowFragments
                                                    error:&convertErr];
    }
    
    if (convertErr){
        //削除の場合はconvertErrが返る
        if (error != nil){
            *error = convertErr;
        }
            return nil;
    }
    return jsonDic;
}

/**
 エラーレスポンスのJSONをNSErrorに変換する
 @param response エラーが含まれているJSON
 @param error エラーを保持するポインタ
 */
- (void)convertErrorFromJSON:(NSData*)contents response:(NSHTTPURLResponse*)response error:(NSError**)error {
    NSDictionary *errDic = [self convertResponseToDic:contents error:error];
    if (errDic != nil && [errDic count] != 0){
        // mBaaSが返却するエラー時
        [self checkE401001Error:[errDic objectForKey:@"code"]];
        //エラーコードをNSIntegerへの変換
        NSString *codeStr = [[errDic objectForKey:@"code"] stringByReplacingOccurrencesOfString:@"E"
                                                                                     withString:@""];
        //エラーメッセージがあれば取得し設定
        NSMutableDictionary *errorMessage = [NSMutableDictionary dictionary];
        if([errDic objectForKey:@"error"] ){
            [errorMessage setObject:[errDic objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
        }
        
        if (error != nil){
            *error = [[NSError alloc] initWithDomain:kNCMBErrorDomain
                                                code:[codeStr integerValue]
                                            userInfo:errorMessage];
        }
    } else {
        // 通信エラー時
        if (*error == nil){
            *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                code:response.statusCode
                                            userInfo:@{NSLocalizedDescriptionKey:@"Connection Error."}];
        }
    }
}


/**
 セッショントークンの有効期限が切れていた場合、E401001エラーが返る
 このエラーだった場合は、ログアウト処理を行う
 @param errorCode エラーコード
 */
-(void)checkE401001Error:(NSString *)errorCode{
    if([kNCMBErrorInvalidAuthHeader isEqualToString:errorCode]){
        NCMBUser *currentUser = [NCMBUser currentUser];
        NSString *currentUserSessionToken = currentUser.sessionToken;
        //Eventuallyメソッドで古いsessionの場合があるので現在のsessionとも比較する
        NSString *sessionToken = [NCMBUser getCurrentSessionToken];
        if(sessionToken != nil && [sessionToken isEqualToString:currentUserSessionToken]){
            [NCMBUser logOutEvent];
        }
    }
}

/**
 シグネチャが有効かどうかの検証を行う
 @param response 通信のレスポンス
 @param contentsData mBaaSから返却されるJSONデータ
 @param error エラー
 */
-(void)signatureCheck:(NSURLResponse *)response contentsData:(NSData *)contentsData error:(NSError **)error{
    //レスポンスシグネチャ取得
    NSDictionary *responseDic = [((NSHTTPURLResponse *)response) allHeaderFields];
    NSString *responseSignature = [responseDic valueForKey:@"X-NCMB-Response-Signature"];
    
    //有効であればレスポンスシグネチャのチェックを行う
    if ([NCMB getResponseValidationFlag] == YES && responseSignature != nil){
        
        NSString *strForSignature =  self.request.signature;
        //レスポンスシグネチャ比較用のシグネチャ生成
        NSString *createdSignature = nil;
        NSRange contentTypeRange = [[responseDic valueForKey:@"Content-Type"] rangeOfString:@"application/json"];
        if (contentTypeRange.location != NSNotFound) {
            NSString *dataString = [[NSString alloc] initWithData:contentsData encoding:NSUTF8StringEncoding];
            if (![dataString isEqualToString:@""]){
                NSString *forSignString = [strForSignature stringByAppendingFormat:@"\n%@", dataString];
                createdSignature = [NCMBRequest encodingSigneture:forSignString method:self.request];
            } else {
                //メソッドがDELETEorログアウト時はreceiveDataがない
                createdSignature = [NCMBRequest encodingSigneture:strForSignature method:self.request];
            }
        } else {
            //NCMBFile時の処理。バイナリデータは16進数文字列に変換する
            NSMutableString *dataString = [NSMutableString stringWithCapacity:[contentsData length]];
            long length = [contentsData length];
            char *bytes = malloc(sizeof(char) * length);
            [contentsData getBytes:bytes length:length];
            for (int i = 0; i < length; i++){
                [dataString appendFormat:@"%02.2hhx", bytes[i]];
            }
            free(bytes);
            NSString *forSignDataString = [strForSignature stringByAppendingFormat:@"\n%@", dataString];
            createdSignature = [NCMBRequest encodingSigneture:forSignDataString method:self.request];
        }
        
        //シグネチャが一致しない場合はエラーを設定する
        if (createdSignature && ![responseSignature isEqualToString:createdSignature]){
            NSMutableDictionary *validationErrDetails = [NSMutableDictionary dictionary];
            [validationErrDetails setObject:@"E100001" forKey:@"code"];
            [validationErrDetails setObject:@"Authentication error by response signature incorrect." forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:ERRORDOMAIN code:100001 userInfo:validationErrDetails];
        }
    }
}

#pragma mark - NSURLSessionTaskDelegate

// データタスク,アップロードタスク終了時に呼び出されるデリゲート
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 一回のパケットに収まらないデータ量の場合は複数回呼ばれるのでデータを追加していく
    [self.responseData appendData:data];
}

// タスク終了時に呼び出されるデリゲート。正常終了、エラー終了、途中終了でもこのメソッドが呼ばれる
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
      NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)task.response;
//    NSInteger responseStatusCode = [httpURLResponse statusCode];
//    NSLog(@"ステータスコード:%li",(long)responseStatusCode);
    
    [session invalidateAndCancel];
    
    // 各機能クラスに結果を渡す。File取得APIの場合はNSData型を返却。それ以外のAPIはNSDictionary型を返却。
    id response = [self convertResponse:self.responseData response:httpURLResponse error:&error];
    if(self.block != nil){
        self.block(response,error);
    }
}

// Basic認証、SSL認証、クライアント認証が掛かっている場合に呼び出されるデリゲート
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    // SSL認証の設定
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

// アップロードタスクの処理中に定期的に呼び出されるデリゲート
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
//    NSLog(@"bytesSent:%lld",bytesSent); // 今回送信したデータサイズ
//    NSLog(@"totalBytesSent:%lld",totalBytesSent); // これまで送信したデータサイズの累計
//    NSLog(@"totalBytesExpectedToSend:%lld",totalBytesExpectedToSend); // 送信する予定すべてのデータサイズ
    if(self.blockProgress != nil){
        float percent = (float)totalBytesSent/(float)totalBytesExpectedToSend;
        self.blockProgress(percent * 100);
    }
}

// リクエストを再送する際に呼び出されるデリゲート
// 再送要求が無い場合、このメソッドは呼ばれません
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
}

// アップロート終了後，レスポンスがリダイレクトされる場合呼び出されるデリゲート
// リダイレクトが無い場合，このメソッドは呼ばれません
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
}

#pragma mark - NSURLSessionDownloadDelegate

// cancelByProducingResumeDataメソッドでダウンロードのタスクをキャンセル後、
// downloadTaskWithResumeDataメソッドでダウンロードを途中からresumeした場合に呼び出されるデリゲート
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // NSLog(@"[fileOffset] %lld, [expectedTotalBytes] %lld", fileOffset, expectedTotalBytes);
}

// ダウンロードタスクの処理中に定期的に呼び出されるデリゲート
// 進捗率をコールバックに返す
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // NSLog(@"[bytesWritten] %lld, [totalBytesWritten] %lld, [totalBytesExpectedToWrite] %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    if(self.blockProgress != nil){
        float percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        self.blockProgress(percent * 100);
    }
}

// ダウンロードタスク終了時に呼び出されるデリゲート
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if([location isFileURL]){
        NSData* data = [NSData dataWithContentsOfURL:location];
        self.responseData = (NSMutableData*)data;
    }
}

@end
