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

#import "NCMBFile.h"
#import "NCMBObject+Private.h"
#import "NCMBACL.h"
#import "NSDataBase64Encode.h"
#import "NCMBQuery.h"
#import "NCMBURLConnection.h"

#pragma mark - url
#define URL_FILE @"files"
#define URL_PATH @"https://mb.api.cloud.nifty.com/2013-09-01/"

@interface NCMBFile(){
    NSURLConnection *connectionLocal;
    BOOL isCancel;
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
    dispatch_queue_t main=dispatch_get_main_queue();
    dispatch_queue_t sub=dispatch_queue_create("getDataInBackgroundWithBlock", NULL);
    dispatch_async(sub, ^{
        isCancel = NO;
        //プログレス作成
        id proBlock = ^(NSNumber *progress){
            if (progressBlock) {
                int progressInt = [progress floatValue]*100;
                progressBlock(progressInt);
            }
        };
        //リクエスト作成
        NSError *e = nil;
        NSMutableDictionary *operation = [self beforeConnection];
        NCMBURLConnection *request = [self createConnectionForSave:URL_FILE
                                                         operation:operation
                                                          progress:proBlock
                                                             error:&e];
        if (request == nil && e != nil){
            if (block){
                block(e);
            }
        }
        dispatch_async(main, ^{
            //非同期通信
            if (!isCancel) {
                connectionLocal = [request fileAsyncConnectionWithBlock:^(NSDictionary *responseData, NSError *requestError){
                    if (connectionLocal) {
                        connectionLocal = nil;
                    }
                    //通信エラーだった場合はNOを返す
                    if (requestError){
                        //通信エラー or mbエラー
                        [self mergePreviousOperation:operation];
                    } else {
                        [self afterSave:responseData operations:operation];
                    }
                    if(block){
                        block(requestError);
                    }
                }];
            }else{
                connectionLocal = nil;
            }
            isCancel = NO;
        });
    });
    //dispatch_release(sub);
}



#pragma mark - get

/**
 データの取得。必要があればエラーをセットし、取得することもできる。
 @param error 処理中に起きたエラーのポインタ
 @return NSData型 取得データ
 */
- (NSData *)getData:(NSError **)error{
    isCancel = NO;
    //リクエスト作成
    NCMBURLConnection *request = [[NCMBURLConnection new] initWithPath:[NSString stringWithFormat:@"%@/%@", URL_FILE, self.name] method:@"GET" data:nil];
    
    NSError *errorLocal = nil;
    if (!isCancel) {
        //同期通信
        NSData * responseData = [request syncConnection:&errorLocal];
        
        if (errorLocal) {
            *error = errorLocal;
        }else{
            self.file = responseData;
        }
    }
    isCancel = NO;
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
    dispatch_queue_t main=dispatch_get_main_queue();
    dispatch_queue_t sub=dispatch_queue_create("getDataInBackgroundWithBlock", NULL);
    dispatch_async(sub, ^{
        isCancel = NO;
        //プログレス作成
        id block = ^(NSNumber *progress){
            if (progressBlock) {
                int progressInt = [progress floatValue]*100;
                progressBlock(progressInt);
            }
        };
        
        //リクエスト作成
        NCMBURLConnection *request = [[NCMBURLConnection new] initWithProgress:[NSString stringWithFormat:@"%@/%@", URL_FILE, self.name] method:@"GET" data:nil progress:block];
        
        dispatch_async(main, ^{
            if (!isCancel) {
                //非同期通信
                connectionLocal = [request fileAsyncConnectionWithBlock:^(NSData *responseData, NSError *errorBlock){
                    //isCancel = NO;
                    if (connectionLocal) {
                        connectionLocal = nil;
                    }
                    
                    if (!errorBlock){
                        self.file = responseData;
                    }
                    if(resultBlock){
                        resultBlock(responseData,errorBlock);
                    }
                }];
            }else{
                connectionLocal = nil;
            }
            isCancel = NO;
        });
    });
    //dispatch_release(sub);
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
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    NSTimeZone *zone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calender setTimeZone:zone];
    [df setDateFormat:@"yyyyMMddHHmmssSSSS"];
    NSString *str = [df stringFromDate:[NSDate date]];
    return str;
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

/**
 file用のNCMBConnectionを生成する
 @param url APIリクエストするURL
 @param operation オブジェクトの操作履歴
 @param progress プログレス
 @return save用のNCMBConnection
 */
- (NCMBURLConnection*)createConnectionForSave:(NSString*)url
                                    operation:(NSMutableDictionary*)operation
                                     progress:(void (^)(NSNumber *progress))progress
                                        error:(NSError**)error
{
    NSMutableDictionary *ncmbDic = [self convertToJSONDicFromOperation:operation];
    //fileは履歴管理していないため直接設定する
    if(self.file){
        [ncmbDic setObject:self.file forKey:@"file"];
    }
    
    NSString *path = [url stringByAppendingString:[NSString stringWithFormat:@"/%@", self.name]];
    NCMBURLConnection *connect = nil;
    NSError *convertError = nil;
    
    //未保存の場合は登録、保存済みの場合は更新処理を行う
    if (self.isDirty){
        //POSTはmultipart/form-dataの形で通信を行う
        NSString *method = @"POST";
        NSMutableDictionary *jsonDic = [self convertToJSONFromNCMBObject:ncmbDic];
        
        //ファイル名、mimeTypeの作成
        NSData* data = [jsonDic objectForKey:@"file"];
        NSString* fileName = [jsonDic objectForKey:@"fileName"];
        NSString* mimeType = [NCMBFile mimeTypeForFileName:fileName];
        [jsonDic removeObjectForKey:@"file"];
        [jsonDic removeObjectForKey:@"fileName"];
        
        NSString *boundary = @"_NCMBProjectBoundary";
        NSMutableData* result = [[NSMutableData alloc] init];
        //aclのform-dataを作成
        if ([[jsonDic allKeys] count]>0) {
            for (NSString *key in [jsonDic allKeys]) {
                [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", key,key] dataUsingEncoding:NSUTF8StringEncoding]];
                [result appendData:[NSJSONSerialization dataWithJSONObject:[jsonDic objectForKey:key] options:kNilOptions error:&convertError]];
                if (convertError){
                    return nil;
                }
                [result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        //fileのform-dataを作成
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendData:data];
        [result appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if (convertError){
            return nil;
        }
        connect = [[NCMBURLConnection new] initWithProgress:path method:method data:result progress:progress];
    } else {
        //PUTはapplication/jsonなのでaclのみ取り出し、通常の通信と同様に更新する
        NSString *method = @"PUT";
        NSMutableDictionary *aclDic = [NSMutableDictionary dictionary];
        if([ncmbDic objectForKey:@"acl"]){
            [aclDic setObject:[ncmbDic objectForKey:@"acl"] forKey:@"acl"];
        }
        
        NSMutableDictionary *jsonDic = [self convertToJSONFromNCMBObject:aclDic];
        NSData *json = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:&convertError];
        if (convertError){
            return nil;
        }
        connect = [[NCMBURLConnection new] initWithProgress:path method:method data:json progress:progress];
    }
    return connect;
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
 通信のキャンセルを行う
 */
- (void)cancel{
    if (connectionLocal) {
        if ([connectionLocal isKindOfClass:[NSURLConnection class]]) {
            [connectionLocal cancel];
        }
        connectionLocal = nil;
        isCancel = NO;
    }else{
        isCancel = YES;
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
    isCancel = NO;
    NSMutableDictionary *operation = [self beforeConnection];
    
    NSError *connectionError = nil;
    NCMBURLConnection *connect = [self createConnectionForSave:URL_FILE
                                                     operation:operation
                                                      progress:nil
                                                         error:&connectionError];
    if (connect == nil && connectionError != nil){
        if (error){
            *error = connectionError;
        }
    }
    if (!isCancel) {
        NSError *requestError = nil;
        NSDictionary *response = [connect syncConnection:&requestError];
        //通信エラーだった場合はNOを返す
        if (requestError){
            if (error){
                *error = requestError;
            }
            //通信エラー or mbエラー
            [self mergePreviousOperation:operation];
        } else {
            [self afterSave:response operations:operation];
        }
    }
    isCancel = NO;
}

/**
 mobile backendにfileを保存する。非同期通信を行う。
 @param block 通信後に実行されるblock。引数にNSError *errorを持つ。
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
 @param error block 通信後に実行されるblock。引数にBOOL succeeded, NSError *errorを持つ。
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
@end
