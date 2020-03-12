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

#import "NCMBFile.h"
#import "NCMBObject+Private.h"
#import "NCMBACL.h"
#import "NSDataBase64Encode.h"
#import "NCMBQuery.h"
#import "NCMBURLSession.h"
#import "NCMBDateFormat.h"

#pragma mark - url
#define URL_FILE @"files"
#define URL_PATH @"https://mbaas.api.nifcloud.com/2013-09-01/"

@interface NCMBFile(){
    NCMBURLSession *session;
    dispatch_semaphore_t semaphore;
}

@property (nonatomic,strong) NSData *file;

@end

@implementation NCMBFile
static NSMutableData *resultData = nil;

#pragma mark - UnsupportedOperationException
//非推奨メソッド
-(void)refresh:(NSError **)error {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)refreshInBackgroundWithBlock:(NCMBObjectResultBlock)block {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)fetch:(NSError **)error {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)fetchInBackgroundWithBlock:(NCMBErrorResultBlock)block {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)deleteEventually:(NCMBErrorResultBlock)callback{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(NCMBRelation *)relationForKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
    return nil;
}
-(void)addObject:(id)object forKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)addUniqueObject:(id)object forKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)removeObject:(id)object forKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)removeObjectsFromArray:(NSArray *)objects forKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)removeObjectForKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)incrementKey:(NSString *)key{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}
-(void)saveEventually:(NCMBErrorResultBlock)callback{
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}

#pragma mark - init

/**
 指定したファイルパスで取得したデータと指定したファイル名を持つNCMBFileのインスタンスを生成
 @param name 指定するファイル名
 @param path 指定するファイルパス
 */
+ (id)fileWithName:(NSString *)name
    contentsAtPath:(NSString *)path{
    NCMBFile *file = [NCMBFile fileWithName:path data:nil];
    NSError *error = nil;
    NSData *data = [file getData:&error];
    if (error) {
        return nil;
    }else{
        NCMBFile *returnFile = [NCMBFile fileWithName:name data:data];
        return returnFile;
    }
}


/**
 指定したデータ(NSData)を持つNCMBFileのインスタンスを生成
 @param data 指定するデータ(NSData)
 @return id型 NCMBFile
 */
+ (id)fileWithData:(NSData *)data{
    NCMBFile *file = [[NCMBFile alloc] initWithClassName:@"file"];
    file.file = data;
    [file privateSetIsDirty:TRUE];
    [file privateSetName:[NCMBFile uniqueTagFromObject]];
    return file;
}

- (instancetype)init{
    return [self initWithClassName:@"file"];
}

/**
 指定したファイル名とデータ(NSData)を持つNCMBFileのインスタンスを生成
 @param name 指定するファイル名
 @param data 指定するデータ(NSData)
 @return id型 NCMBFile
 */
+ (id)fileWithName:(NSString *)name data:(NSData *)data{
    NCMBFile *file = [[NCMBFile alloc] init];
    file.file = data;
    [file privateSetName:name];
    [file privateSetIsDirty:YES];
    return file;
}

#pragma mark - property

/**
 プロパティnameにファイル名を設定する
 @param strName ファイル名
 */
-(void)privateSetName:(NSString *)strName{
    if (_name != strName) {
        _name = strName;
        [self setObject:strName forKey:@"fileName"];
    }
}

/**
 プロパティurlに通信成功時のパスを設定する
 @param strURL url
 */
-(void)privateSetURL:(NSString *)strURL{
    if (_url != strURL) {
        _url = strURL;
    }
}

/**
 fileの保存状態を取得する
 @param flag YES=未保存,NO=保存済
 */
-(void)privateSetIsDirty:(BOOL)flag{
    _isDirty = flag;
}

#pragma mark - save

/**
 データを非同期で保存。保存の進度により定期的にprogressBlockを呼び出し、100パーセントに達し保存がし終わったらblockを呼び出す。
 @param block 保存完了後に実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NSError *error）
 errorにはエラーがあればエラーのポインタが渡され、なければnilが渡される。
 @param progressBlock 保存進度により定期的に実行されるblock。blockは次の引数のシグネチャを持つ必要がある（int percentDone）
 */
- (void)saveInBackgroundWithBlock:(NCMBErrorResultBlock)block
                    progressBlock:(NCMBProgressBlock)progressBlock{
    
    //リクエスト作成
    NSError *e = nil;
    NSMutableDictionary *operation = [self beforeConnection];
    NCMBRequest *request = [self createRequest:operation error:&e];
    
    // 通信
    session = [[NCMBURLSession alloc] initWithProgress:request progress:progressBlock];
    [session fileUploadAsyncConnectionWithBlock:^(NSDictionary *responseData, NSError *requestError){
        if (requestError){
            [self mergePreviousOperation:operation];
        } else {
            [self afterSave:responseData operations:operation];
        }
        
        // コールバック実行
        [self executeUserCallback:block error:requestError];
        
    }];
}



#pragma mark - get

/**
 データの取得。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return NSData型 取得データ
 */
- (NSData *)getData:(NSError **)error{
    semaphore = dispatch_semaphore_create(0);
    NSError __block *sessionError = nil;
    NCMBRequest *request = [[NCMBRequest alloc] initWithURLString:[NSString stringWithFormat:@"%@/%@",URL_FILE,self.name]
                                                           method:@"GET"
                                                           header:nil
                                                             body:nil];
    
    session = [[NCMBURLSession alloc] initWithRequestSync:request];
    [session fileDownloadAsyncConnectionWithBlock:^(NSData *responseData, NSError *requestError){
        if (requestError){
            sessionError = requestError;
        }else{
            self.file = responseData;
            [self privateSetIsDirty:NO];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if(error){
        *error = sessionError;
    }
    return self.file;
}

/**
 データを非同期で取得。取得し終わったら指定されたコールバックを呼び出す。
 @param target 呼び出すセレクタのターゲット
 @param selector 呼び出すセレクタ。次のシグネチャを持つ必要がある。 (void)callbackWithResult:(NSData *)result error:(NSError **)error
 resultには取得したデータが渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)getDataInBackgroundWithTarget:(id)target selector:(SEL)selector{
    NSMethodSignature* signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [invocation setArgument:&data atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }progressBlock:nil];
}

/**
 データを非同期で取得。取得し終わったら与えられたblockを呼び出す。
 @param block 通信後実行されるblock。blockは次の引数のシグネチャを持つ必要がある（NSData *data, NSError *error）
 resultには取得したデータが渡される。errorにはエラーがあればエラーのポインタが、なければnilが渡される。
 */
- (void)getDataInBackgroundWithBlock:(NCMBDataResultBlock)block{
    [self getDataInBackgroundWithBlock:block progressBlock:nil];
}

/**
 データを非同期で取得。取得の進度により定期的にprogressBlockを呼び出し、100パーセントに達し取得し終わったらresultBlockを呼び出す。
 @param resultBlock 取得完了後に実行されるblock。resultBlockは次の引数のシグネチャを持つ必要がある（NSData *data, NSError *error）
 @param progressBlock 取得進度により定期的に実行されるblock。progressBlockは次の引数のシグネチャを持つ必要がある（int percentDone）
 */
- (void)getDataInBackgroundWithBlock:(NCMBDataResultBlock)resultBlock
                       progressBlock:(NCMBProgressBlock)progressBlock{
    
    NCMBRequest *request = [[NCMBRequest alloc] initWithURLString:[NSString stringWithFormat:@"%@/%@",URL_FILE,self.name]
                                                           method:@"GET"
                                                           header:nil
                                                             body:nil];
    
    session = [[NCMBURLSession alloc] initWithProgress:request progress:progressBlock];
    [session fileDownloadAsyncConnectionWithBlock:^(NSData *responseData, NSError *requestError){
        if (!requestError){
            self.file = responseData;
            [self privateSetIsDirty:NO];
        }
        
        // コールバック実行
        if(resultBlock){
            resultBlock(self.file,requestError);
        }
    }];
}

#pragma mark - create

/**
 ファイル名をTimeStampとUUIDをエンコードした文字列で生成する
 @return NSString型 エンコードされた文字列
 */
+(NSString*) uniqueTagFromObject{
    NSData *data =[[NSString stringWithFormat:@"%@%@",[NCMBFile getTimeStamp],[NCMBFile getUUID]] dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@",[NSDataBase64Encode stringEncodedWithBase64:data]];
}

/**
 タイムスタンプを生成する
 @return NSString型 タイムスタンプ
 */
+(NSString*) getTimeStamp{
    return [[NCMBDateFormat getFileNameDateFormat] stringFromDate:[NSDate date]];
}

/**
 UUIDを生成する
 @return NSString型 UUID
 */
+(NSString*) getUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

- (NSMutableData*)createBody:(NSMutableDictionary*)operation
                       error:(NSError**)error{
    NSMutableDictionary *ncmbDic = [self convertToJSONDicFromOperation:operation];
    //fileは履歴管理していないため直接設定する
    if(self.file){
        [ncmbDic setObject:self.file forKey:@"file"];
    }
    
    NSMutableData *body = [[NSMutableData alloc] init];
    NSError *convertError = nil;
    
    //未保存の場合は登録、保存済みの場合は更新処理を行う
    if (self.isDirty){
        //POSTはmultipart/form-dataの形で通信を行う
        NSMutableDictionary *jsonDic = [self convertToJSONFromNCMBObject:ncmbDic];
        
        //ファイル名、mimeTypeの作成
        NSData* data = [jsonDic objectForKey:@"file"];
        NSString* fileName = [jsonDic objectForKey:@"fileName"];
        NSString* mimeType = [NCMBFile mimeTypeForFileName:fileName];
        [jsonDic removeObjectForKey:@"file"];
        [jsonDic removeObjectForKey:@"fileName"];
        
        NSString *boundary = @"_NCMBProjectBoundary";
        //aclのform-dataを作成
        if ([[jsonDic allKeys] count]>0) {
            for (NSString *key in [jsonDic allKeys]) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", key,key] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSJSONSerialization dataWithJSONObject:[jsonDic objectForKey:key] options:kNilOptions error:&convertError]];
                if (convertError){
                    return nil;
                }
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        //fileのform-dataを作成
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if (convertError){
            return nil;
        }
    } else {
        //PUTはapplication/jsonなのでaclのみ取り出し、通常の通信と同様に更新する
        NSMutableDictionary *aclDic = [NSMutableDictionary dictionary];
        if([ncmbDic objectForKey:@"acl"]){
            [aclDic setObject:[ncmbDic objectForKey:@"acl"] forKey:@"acl"];
        }
        
        NSMutableDictionary *jsonDic = [self convertToJSONFromNCMBObject:aclDic];
        body = (NSMutableData*)[NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:&convertError];
        if (convertError){
            return nil;
        }
    }
    return body;
}


/**
 拡張子に合わせてmineTypeを生成する
 @param fileName ファイル名
 @return NSString型 mineType
 */
+ (NSString*) mimeTypeForFileName: (NSString *) fileName {
    NSString * path = [[fileName componentsSeparatedByString:@"."] lastObject];
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)path, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    
    CFRelease(UTI);
    NSString* resultStr = (__bridge NSString *)(mimeType);
    if (!mimeType) {
        
        return @"application/octet-stream";
    }
    CFRelease(mimeType);
    return resultStr;
}

/**
 ファイル取得のURL及びファイル名の設定を行う
 @param response REST APIのレスポンスデータ
 */
-(void)privateSetNameAndURL:(NSDictionary *)response{
    if ([response objectForKey:@"fileName"]) {
        [self privateSetName:[response objectForKey:@"fileName"]];
        NSString *strPath = [NSString stringWithFormat:@"%@/%@",URL_FILE,[response objectForKey:@"fileName"]];
        [self privateSetURL:[NSString stringWithFormat:@"%@%@",URL_PATH,strPath]];
    }
}

#pragma mark - cancel
/**
 通信が行われていた場合に通信のキャンセルを行う
 */
- (void)cancel{
    if (session.uploadTask !=nil && session.uploadTask.state == NSURLSessionTaskStateRunning) {
        [session.uploadTask cancel];
    } else if (session.downloadTask !=nil && session.downloadTask.state == NSURLSessionTaskStateRunning){
        [session.downloadTask cancel];
    }
}

#pragma mark - query

+ (NCMBQuery *)query{
    return [NCMBQuery queryWithClassName:@"file"];
}


#pragma mark - override

/**
 mobile backendにオブジェクトを保存する
 @param error エラーを保持するポインタ
 */
- (void)save:(NSError **)error{
    semaphore = dispatch_semaphore_create(0);
    
    //リクエスト作成
    NSError __block *sessionError = nil;
    NSMutableDictionary *operation = [self beforeConnection];
    NCMBRequest *request = [self createRequest:operation error:&sessionError];
    if(sessionError){
        if(error){
            *error = sessionError;
        }
        return;
    }
    
    // 通信
    session = [[NCMBURLSession alloc] initWithRequestSync:request];
    [session fileUploadAsyncConnectionWithBlock:^(NSDictionary *responseData, NSError *requestError){
        if (requestError){
            //通信エラー or mbエラー
            [self mergePreviousOperation:operation];
            sessionError = requestError;
        } else {
            [self afterSave:responseData operations:operation];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if(error){
        *error = sessionError;
    }
}

/**
 mobile backendにfileを保存する。非同期通信を行う。
 @param userBlock 通信後に実行されるblock。引数にNSError *errorを持つ。
 */
- (void)saveInBackgroundWithBlock:(NCMBErrorResultBlock)userBlock{
    [self saveInBackgroundWithBlock:userBlock progressBlock:nil];
}

/**
 fileをmobile backendとローカル上から削除する
 @param error エラーを保持するポインタを保持するポインタ
 */
- (void)delete:(NSError**)error{
    if (_name){
        NSString *url = [NSString stringWithFormat:@"%@/%@",URL_FILE,self.name];
        [self delete:url error:error];
    } else {
        if (error){
            NSError *localError = [NSError errorWithDomain:ERRORDOMAIN
                                                      code:400003
                                                  userInfo:@{NSLocalizedDescriptionKey:@"objectId is empty."}
                                   ];
            *error = localError;
        }
    }
}

/**
 fileをmobile backendとローカル上から削除する。非同期通信を行う。
 @param userBlock 通信後に実行されるblock。引数にBOOL succeeded, NSError *errorを持つ。
 */
- (void)deleteInBackgroundWithBlock:(NCMBErrorResultBlock)userBlock{
    if (_name){
        NSString *url = [NSString stringWithFormat:@"%@/%@",URL_FILE,self.name];
        [self deleteInBackgroundWithBlock:url block:userBlock];
    } else {
        if (userBlock){
            NSError *localError = [NSError errorWithDomain:ERRORDOMAIN
                                                      code:400003
                                                  userInfo:@{NSLocalizedDescriptionKey:@"objectId is empty."}
                                   ];
            userBlock(localError);
        }
    }
}

+(id)object{
    return [[NCMBFile alloc] init];
}

+(NSString *)ncmbClassName{
    return @"file";
}

/**
 オブジェクト更新後に操作履歴とestimatedDataを同期する
 @param response REST APIのレスポンスデータ
 @param operations 同期する操作履歴
 */
-(void)afterSave:(NSDictionary*)response operations:(NSMutableDictionary*)operations{
    //NCMBFileのレスポンス処理
    [self privateSetNameAndURL:response];
    [self privateSetIsDirty:NO];
    //通常のレスポンス処理
    [super afterSave:response operations:operations];
}

/**
 ファイル情報取得時にACLを変換し、保存済みファイルであることを設定する
 */
- (void)afterFetch:(NSMutableDictionary *)response isRefresh:(BOOL)isRefresh{
    self.ACL = [NCMBACL ACL];
    self.ACL.dicACL = [NSMutableDictionary dictionaryWithDictionary:[response objectForKey:@"acl"]];
    if ([response objectForKey:@"mimeType"]){
        [estimatedData setObject:[response objectForKey:@"mimeType"] forKey:@"mimeType"];
    }
    if ([response objectForKey:@"fileSize"]){
        [estimatedData setObject:[response objectForKey:@"fileSize"] forKey:@"fileSize"];
    }
    [super afterFetch:response isRefresh:isRefresh];
    _isDirty = NO;
}

- (NCMBRequest *)createRequest:(NSMutableDictionary*)operation error:(NSError**)error{
    //リクエスト作成
    NSMutableData *body = [self createBody:operation error:error];
    NSString *method = @"POST";
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    if(self.isDirty){
        // POST時
        [header setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=_NCMBProjectBoundary"]  forKey:@"Content-Type"];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [header setValue:postLength forKey:@"Content-Length"];
    }else{
        // PUT時
        method = @"PUT";
    }
    // 日本語ファイル名の場合エンコーディング必須
    NSString *fileName = [NCMBRequest returnEncodedString:self.name];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@", URL_PATH,URL_FILE,fileName]];
    NCMBRequest *request = [[NCMBRequest alloc] initWithURL:url
                                                     method:method
                                                     header:header
                                                   bodyData:body];
    return request;
}
@end
