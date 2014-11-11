//
//  NCMBConnection.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/01.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMB.h"

#import "NCMBURLConnection.h"
#import "NCMBUser+Private.h"
#import "NCMBError.h"

static NSString *const kEndPoint           = @"https://mb.api.cloud.nifty.com";
static NSString *const kAPIVersion         = @"2013-09-01";
static NSString *const kAppliKeyFieldName  = @"X-NCMB-Application-Key";
static NSString *const kTimeStampFieldName = @"X-NCMB-Timestamp";
static NSString *const kSignatureFieldName = @"X-NCMB-Signature";
static NSString *const kSessionFieldName   = @"X-NCMB-Apps-Session-Token";
static NSString *const kSignatureMethod    = @"SignatureMethod=HmacSHA256";
static NSString *const kSignatureVersion   = @"SignatureVersion=2";
static NSString *const kNCMBErrorDomain    = @"com.nifty.cloud.mb";

NSString *strForSignature = @"";
NSString *sesstionToken = nil;

#define ERRORDOMAIN @"NCMBErrorDomain"

typedef enum : NSInteger {
    NCMB_SAVE = 1,
    NCMB_UPDATE,
    NCMB_GET,
    NCMB_DELETE,
    NCMB_SEARCH
} NCMBOperation;

@implementation NCMBURLConnection

#pragma mark init

/**
 データがすべてnilでセットされたインスタンスを生成する
 */
- (id)init{
    self = [self initWithPath:nil method:nil data:nil];
    return self;
}

- (id)initWithPath:(NSString*)path method:(NSString*)method data:(NSData*)data{
    return [self initWithPath:path method:method data:data cachePolicy:kNilOptions];
}

- (id)initWithProgress:(NSString*)path method:(NSString*)method data:(NSData*)data progress:(void (^)(NSNumber *progress))progress{
    self.blockProgress = progress;
    return [self initWithPath:path method:method data:data cachePolicy:kNilOptions];
}

/**
 初期化を行う
 @param path APIをリクエストするパス
 @param method リクエストするmethod
 @param data 具体的な通信内容(検索条件、登録内容など)
 @param cachePolicy キャッシュポリシー
 */
- (id)initWithPath:(NSString*)path method:(NSString*)method data:(NSData*)data cachePolicy:(int)cachePolicy{
    self = [super init];
    NSString *dataStr;
    if (data != nil){
        NSRange range = [path rangeOfString:@"files/"];
        if (range.location != NSNotFound && [method isEqualToString:@"POST"]) {
            //APIリクエストURLにfilesが含まれていた場合
            self.fileData = data;
        } else {
            dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    if (self){
        path = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                        NULL,
                                                        (__bridge CFStringRef)path,
                                                        NULL,
                                                        (__bridge CFStringRef)@"!*();@+,%#\"",
                                                        kCFStringEncodingUTF8 );
        
        
        self.path = [NSString stringWithFormat:@"/%@/%@", kAPIVersion, path];
        self.method = method;
        
        if ([method isEqualToString:@"GET"]){
            
            self.query = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                        NULL,
                                                        (__bridge CFStringRef)dataStr,
                                                        NULL,
                                                        (__bridge CFStringRef)@"!*();@+,%#\"",
                                                        kCFStringEncodingUTF8 );
             
            //self.query = dataStr;
        } else {
            self.data = dataStr;
        }
        self.appKey = [NCMB getApplicationKey];
        self.cliKey = [NCMB getClientKey];
        self.cachePolicy = cachePolicy;
    }
    return self;
}


#pragma mark request

/**
 リクエストを生成するメソッド
 @return NSMutableURLRequest型リクエスト
 */
- (NSMutableURLRequest *)createRequest {
    //url生成
    NSString *url = [kEndPoint stringByAppendingString:self.path];
    
    //request生成 タイムアウト10秒
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:self.cachePolicy
                                                       timeoutInterval:10.0];
    
    [self createSignature];
    
    //ヘッダー設定
    if(self.fileData){
        //fileでPOSTの場合
        [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=_NCMBProjectBoundary"] forHTTPHeaderField:@"Content-Type"];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[self.fileData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    }else{
        //それ以外
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [request setHTTPMethod:self.method];
    [request setValue:self.appKey forHTTPHeaderField:kAppliKeyFieldName];
    [request setValue:self.signature forHTTPHeaderField:kSignatureFieldName];
    [request setValue:self.timeStamp forHTTPHeaderField:kTimeStampFieldName];
    self.sessionToken = [NCMBUser getCurrentSessionToken];
    if ((self.sessionToken != nil) && (![self.sessionToken isEqual: @""])) {
        NSLog(@"セッショントーン確認:%@",self.sessionToken);
        [request setValue:self.sessionToken forHTTPHeaderField:kSessionFieldName];
    }
    
    return request;
}

/**
 シグネチャを生成するメソッド
 */
- (void)createSignature {
    //TODO:キーを設定していないときのエラーハンドリング
    NSArray *splitedEndPoint = [kEndPoint componentsSeparatedByString:@"/"];
    NSString *fqdn = splitedEndPoint[2];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    //和暦表示と12時間表示対策
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [df setCalendar:calendar];
    [df setLocale:[NSLocale systemLocale]];
    NSString *timeStamp = [df stringFromDate:[NSDate date]];
    self.timeStamp = timeStamp;
    
    NSLog(@"Path:%@",self.path);
    //2013-09-01/〜以降のPathの取得
    NSString *apiPath = [self.path componentsSeparatedByString:@"?"][0];
    
    //署名用文字列生成
    //NSString *strForSignature;
    if (![self.query isEqualToString:@""] && self.query != nil){
        strForSignature = [NSString stringWithFormat:@"%@\n%@\n%@\n%@&%@&%@&%@&%@",
                           self.method,
                           fqdn,
                           apiPath,
                           kSignatureMethod,
                           kSignatureVersion,
                           [NSString stringWithFormat:@"%@=%@", kAppliKeyFieldName, self.appKey],
                           [NSString stringWithFormat:@"%@=%@", kTimeStampFieldName, self.timeStamp],
                           self.query];
    } else {
        strForSignature = [NSString stringWithFormat:@"%@\n%@\n%@\n%@&%@&%@&%@",
                           self.method,
                           fqdn,
                           apiPath,
                           kSignatureMethod,
                           kSignatureVersion,
                           [NSString stringWithFormat:@"%@=%@", kAppliKeyFieldName, self.appKey],
                           [NSString stringWithFormat:@"%@=%@", kTimeStampFieldName, self.timeStamp]];
    }
    
    NSLog(@"署名用文字列\n%@", strForSignature);
    NCMBDEBUGLOG(@"\n【署名用文字列】\n%@",strForSignature);
    self.signature = [self encodingSigneture:strForSignature];
}


/**
 署名用文字列を元にシグネチャに変換
 @param strForSignature 署名用文字列
 @return NSString型シグネチャ
 */
-(NSString *)encodingSigneture:(NSString *)strForSignature{
    const char *cKey = [self.cliKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [strForSignature cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *signature = nil;
    
    //7.0からbase64EncodedStringWithOptionsが利用可能で、それ以前でもbase64Encodingが使えるようになった
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0){
        signature = [HMAC base64EncodedStringWithOptions:kNilOptions];
    } else {
        signature = [HMAC base64Encoding];
    }
    return signature;
}


#pragma mark syncConnection(同期)

/**
 同期通信を行うメソッド
 @param error エラー
 @return JSONData
 */
- (id)syncConnection:(NSError**)error{
    NSHTTPURLResponse *response;
    NSError *connectionErr;
        
    //リクエスト生成
     _request = [self createRequest];
    
    //body生成
    NSData *body = [[NSData alloc] init];
    if([self.method isEqualToString:@"POST"] ||[self.method isEqualToString:@"PUT"]){
        if(self.fileData){
            //fileでPOSTの場合
            body = self.fileData;
        }else{
            body = [[NSString stringWithFormat:@"%@",self.data]dataUsingEncoding:NSUTF8StringEncoding];
        }
        [_request setHTTPBody:body];
    }
    NSLog(@"request url:%@,signature:%@", _request.URL, self.signature);
    //同期通信開始
    NSData *contents = [NSURLConnection sendSynchronousRequest:_request
                                             returningResponse:&response
                                                         error:&connectionErr];
    if (connectionErr){
        //通信自体がエラーだった場合
        *error = connectionErr;
        NSLog(@"通信自体に失敗：%@",connectionErr);
        return nil;
    } else {
        return [self convertResponse:contents response:response error:error];
    }
    
}

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
    //TODO:削除の時はここにひっかかるのでは？
    if (response.statusCode == 200 || response.statusCode == 201){
        NSDictionary *responseDic = [NSDictionary dictionary];
        
        if([self.path isEqualToString:[NSString stringWithFormat:@"/%@/%@", kAPIVersion, @"batch"]]) {
            //バッチ処理の場合は配列が返却される
            responseDic = [NSDictionary dictionaryWithObject:[self convertResponseToArr:contents error:error] forKey:@"result"];
        } else {
            //削除の場合は空、それ以外はNSDictionaryが返却される
            responseDic = [self convertResponseToDic:contents error:error];
        }
        NCMBDEBUGLOG(@"レスポンス:%@", responseDic);
        [self signatureCheck:response contentsData:contents error:error];

         //NCMBFile　getDataの処理
        NSRange range = [[response.URL absoluteString] rangeOfString:@"files/"];
        if (range.location != NSNotFound && [_request.HTTPMethod isEqualToString:@"GET"]) {
            *error = nil;
            return contents;
        }
        
        return responseDic;
    } else {
        [self convertErrorFromJSON:contents error:error];
        return [self convertResponseToDic:contents error:error];
    }
}


#pragma mark asyncConnection(非同期)

/**
 非同期通信を行うメソッド
 @param block 非同期通信後に実行するメソッド引数に(NSError *error)を持つ
 */
- (void)asyncConnectionWithBlock:(NCMBResultBlock)block{
    
    //リクエスト生成
    NSMutableURLRequest *request = [self createRequest];
    
    //body生成
    if([self.method isEqualToString:@"POST"] ||[self.method isEqualToString:@"PUT"]){
        NSData *body = [[NSString stringWithFormat:@"%@",self.data]dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
    }
    
    //非同期通信開始
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    
    //非同期通信開始
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *contentsData, NSError *connectionError){
        //レスポンス処理
        [self connectionDidFinished:response contentsData:contentsData connectionError:connectionError request:request block:block];
    }];
}

#pragma mark asyncConnection(File非同期)

/**
 非同期通信を行うメソッド。NCMBFileクラスの通信処理
 @param block 非同期通信後に実行するメソッド引数に(NSError *error)を持つ
 */
- (NSURLConnection *)fileAsyncConnectionWithBlock:(NCMBResultBlock)block{
    //各機能クラスに返すブロックを保持
    self.block = block;
    
    //リクエスト生成
    NSMutableURLRequest *request = [self createRequest];
    
    //body生成
    if([self.method isEqualToString:@"POST"] ||[self.method isEqualToString:@"PUT"]){
        [request setHTTPBody:self.fileData];
    }
    
    //非同期通信開始
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return connection;
}

/**
 NCMBFile非同期通信処理。通信時エラーがあった場合に呼ばれる
 @param connection 現在の通信のconnection
 @param error 現在の通信のエラー
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"通信エラーです！");
    NSURLRequest* request =  [connection currentRequest];
    NSLog(@"request:%@",request);
    NSLog(@"HTTPMethod:%@",request.HTTPMethod);
    [self connectionDidFinished:self.response contentsData:self.receivedData connectionError:error request:request block:self.block];
    self.block(self.receivedData,error);
}

/**
 NCMBFile非同期通信処理。アップロード(POST)時のプログレスデータを生成する
 今までアップロードしたデータサイズ ÷ 最終的なデータサイズ
 @param bytesWritten 現在の通信で今アップロードしたデータサイズ
 @param totalBytesWritten 現在の通信で今までにアップロードしたデータサイズ
 @param totalBytesExpectedToWrite block 現在の通信でアップロードする最終的なデータサイズ
 */
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    NSLog(@"111");
    NSLog(@"bytesWritten:%ld",(long)bytesWritten);
    NSLog(@"totalBytesWritten:%ld",(long)totalBytesWritten);
    NSLog(@"totalBytesExpectedToWrite:%ld",(long)totalBytesExpectedToWrite);
    if (_blockProgress) {
        float f = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        NSLog(@"結果:%f",f);
        _blockProgress([NSNumber numberWithFloat:f]);
        if (f >=1.0f) {
            self.blockProgress = nil;
        }
    }
}

/**
 NCMBFile非同期通信処理。受信データの初期化を行う
 @param connection 現在の通信のconnection
 @param response 現在の通信のレスポンス
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"222");
    self.receivedData = [[NSMutableData alloc] init];
    self.response = response;
    _estimatedDataSize = [response expectedContentLength];
}



/**
 NCMBFile非同期通信処理。取得が始まると実行され、随時受信が終わったデータを追加していく
 @param connection 現在の通信のconnection
 @param data 受信データ
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"333");
    [self.receivedData appendData:data];
    if (_blockProgress) {
        _blockProgress([NSNumber numberWithFloat:[self progress]]);
    }
}

/**
 NCMBFile非同期通信処理。ダウンロード時の(GET)時のプログレスデータを生成する。取得されたデータサイズを元に計算を行う。
 今までダウンロードしたデータサイズ ÷ 最終的なデータサイズ
 */
-(CGFloat)progress{
    NSLog(@"444");
    double f_receivedData = (double)_receivedData.length;
    double f_estimatedDataSize = (double)_estimatedDataSize;
    return  _receivedData ? f_receivedData/f_estimatedDataSize : 0;
}

/**
 NCMBFile非同期通信処理。通信の一番最後に呼ばれる。
 エラー時はconnection:didFailWithError:メソッドが呼ばれるためこのメソッドは呼ばれない
 @param connection 現在の通信のconnection
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSURLRequest* request =  [connection currentRequest];
    [self connectionDidFinished:self.response contentsData:self.receivedData connectionError:nil request:request block:self.block];
}

#pragma mark response

/**
 各レスポンスデータを元にレスポンス処理を行う
 @param response 現在の通信のレスポンス
 @param contentsData 現在の通信の受信データ
 @param connectionError 現在の通信のエラー
 @param connection 現在の通信のリクエスト
 @param connection 各機能クラスに返すコールバック

 */
- (void)connectionDidFinished:(NSURLResponse*)response contentsData:(NSData *)contentsData connectionError:(NSError *)connectionError request:(NSURLRequest*)request block:(NCMBResultBlock)block{
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201){
        //mBaaSからcontentsが返ってきた場合の処理
        NSError *error = nil;
        NSDictionary *responseDic = [NSDictionary dictionary];
        if (![self.method  isEqualToString: @"DELETE"] && ![self.path isEqualToString:[NSString stringWithFormat:@"/%@/%@", kAPIVersion, @"batch"]]){
            responseDic = [self convertResponseToDic:contentsData error:&error];
        } else if([self.path isEqualToString:[NSString stringWithFormat:@"/%@/%@", kAPIVersion, @"batch"]]) {
            responseDic = [NSDictionary dictionaryWithObject:[self convertResponseToArr:contentsData error:&error] forKey:@"result"];
        }
        NSLog(@"レスポンス:%@",responseDic);
        [self signatureCheck:response contentsData:contentsData error:&error];
        
        NSRange range = [[response.URL absoluteString] rangeOfString:@"files/"];
        if (range.location != NSNotFound && [request.HTTPMethod isEqualToString:@"GET"]) {
            //fileでGETの場合
            if (block){
                block(contentsData,error);
            }
        }else{
            //それ以外
            if (block){
                block(responseDic, error);
            }
        }
    } else {
        //ステータスコードがエラーだった場合
        NSDictionary *responseDic = [NSDictionary dictionary];
        responseDic = [self convertResponseToDic:contentsData error:&connectionError];
        block(responseDic, connectionError);
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
        
        //レスポンスシグネチャ比較用のシグネチャ生成
        NSString *createdSignature = nil;
        NSRange contentTypeRange = [[responseDic valueForKey:@"Content-Type"] rangeOfString:@"application/json"];
        if (contentTypeRange.location != NSNotFound) {
            NSString *dataString = [[NSString alloc] initWithData:contentsData encoding:NSUTF8StringEncoding];
            if (![dataString isEqualToString:@""]){
                NSString *forSignString = [strForSignature stringByAppendingFormat:@"\n%@", dataString];
                createdSignature = [self encodingSigneture:forSignString];
            } else {
                //メソッドがDELETEorログアウト時はreceiveDataがない
                createdSignature = [self encodingSigneture:strForSignature];
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
            createdSignature = [self encodingSigneture:forSignDataString];
        }
        
        //シグネチャが一致しない場合はエラーを設定する
        if (createdSignature && ![responseSignature isEqualToString:createdSignature]){
            NSLog(@"レスポンスシグネチャが一致しません");
            NSMutableDictionary *validationErrDetails = [NSMutableDictionary dictionary];
            [validationErrDetails setObject:@"E100001" forKey:@"code"];
            [validationErrDetails setObject:@"Authentication error by response signature incorrect." forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:ERRORDOMAIN code:100001 userInfo:validationErrDetails];
        }else{
            NSLog(@"レスポンスシグネチャ一致");//TODO:後で消す
        }
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
    if ([contentsData length] != 0){
        jsonDic = [NSJSONSerialization JSONObjectWithData:contentsData
                                                  options:NSJSONReadingAllowFragments
                                                    error:&convertErr];
    }
    if (convertErr){
        //削除の場合はconvertErrが返る
        if (error != nil){
            *error = convertErr;
        }
    }
    return jsonDic;
}

/**
 エラーレスポンスのJSONをNSErrorに変換する
 @param response エラーが含まれているJSON
 @param error エラーを保持するポインタ
 */
- (void)convertErrorFromJSON:(NSData*)contents error:(NSError**)error {
    NSDictionary *errDic = [self convertResponseToDic:contents error:error];
    [self checkE401001Error:[errDic objectForKey:@"code"]];
    //エラーコードをNSIntegerへの変換
    NSString *codeStr = [[errDic objectForKey:@"code"] stringByReplacingOccurrencesOfString:@"E"
                                                                                  withString:@""];
    //エラーメッセージの取得/設定
    NSMutableDictionary *errorMessage = [NSMutableDictionary dictionary];
    [errorMessage setObject:[errDic objectForKey:@"error"] forKey:NSLocalizedDescriptionKey];
    *error = [[NSError alloc] initWithDomain:kNCMBErrorDomain
                                        code:[codeStr integerValue]
                                    userInfo:errorMessage];
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
        if(self.sessionToken != nil && [self.sessionToken isEqualToString:currentUserSessionToken]){
            [NCMBUser logOutEvent];
        }
    }
}

/**
 レスポンスのNSDataをNSArrayに変換する
 @param data レスポンスデータ
 @param error エラーを保持するポインタ
 */
- (id)convertResponseToArr:(NSData *)data error:(NSError **)error{
    NSError *convertError = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingAllowFragments
                                              error:&convertError];
    
    if (convertError){
        *error = convertError;
    } else if ([obj isKindOfClass:[NSDictionary class]]){
        //NSDictionary *errorDic = obj;
        NSString *codeStr = [[obj objectForKey:@"code"] stringByReplacingOccurrencesOfString:@"E"
                                                                                       withString:@""];
        *error = [[NSError alloc] initWithDomain:kNCMBErrorDomain
                                            code:[codeStr integerValue]
                                        userInfo:nil];
    }
    return obj;
}




@end
