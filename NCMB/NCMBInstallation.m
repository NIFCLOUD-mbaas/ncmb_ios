/*******
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
 **********/

#import "NCMBInstallation.h"
#import "NCMBQuery.h"
#import "NCMBACL.h"

#import "NCMBObject+Private.h"

#define DATA_CURRENTINSTALLATION_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentInstallation", DATA_MAIN_PATH]

@implementation NCMBInstallation

+(NCMBQuery*)query{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"installation"];
    return query;
}

- (void)setDeviceTokenFromData:(NSData *)deviceTokenData{
    NSMutableString *tokenId = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",deviceTokenData]];
    [tokenId setString:[tokenId stringByReplacingOccurrencesOfString:@" " withString:@""]]; //余計な文字を消す
    [tokenId setString:[tokenId stringByReplacingOccurrencesOfString:@"<" withString:@""]];
    [tokenId setString:[tokenId stringByReplacingOccurrencesOfString:@">" withString:@""]];
    [self setObject:tokenId forKey:@"deviceToken"];
}

-(NSDictionary*)getLocalData{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super getLocalData]];
    if (_deviceType){
        [dic setObject:_deviceType forKey:@"deviceType"];
    }
    if (_deviceToken){
        [dic setObject:_deviceToken forKey:@"deviceToken"];
    }
    if (_badge){
        [dic setObject:[NSNumber numberWithInteger:_badge] forKey:@"badge"];
    }
    if (_timeZone){
        [dic setObject:_timeZone forKey:@"timeZone"];
    }
    if (_channels){
        [dic setObject:_channels forKey:@"channels"];
    }
    return dic;
}

+(NCMBInstallation*)installation{
    NCMBInstallation *installation = [[NCMBInstallation alloc]initWithClassName:@"installation"];
    installation.channels = [NSMutableArray array];
    [installation setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
                     forKey:@"applicationName"];
    [installation setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
                     forKey:@"appVersion"];
    [installation setObject:SDK_VERSION forKey:@"sdkVersion"];
    [installation setObject:@"ios" forKey:@"deviceType"];
    
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    [installation setObject:[tz name] forKey:@"timeZone"];
    return installation;
}

+(NCMBInstallation*)currentInstallation{
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTINSTALLATION_PATH isDirectory:nil]) {
        NSError *error = nil;
        NSData *localData = [NSData dataWithContentsOfFile:DATA_CURRENTINSTALLATION_PATH
                                                   options:kNilOptions
                                                     error:&error];
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:localData
                                                             options:kNilOptions
                                                               error:&error];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:@"data"]];
        NSString *sdkVer = [dic objectForKey:@"sdkVersion"];
        NSString *appVer = [dic objectForKey:@"appVersion"];
        NSString *newSdkVer = SDK_VERSION;
        NSString *newAppVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        //SDKバージョンとアプリバージョンの更新
        if (![sdkVer isEqualToString:newSdkVer]){
            [dic setObject:newSdkVer
                                            forKey:@"sdkVersion"];
        }
        if (![appVer isEqualToString:newAppVer]){
            [dic setObject:newAppVer forKey:@"appVersion"];
        }
        NCMBInstallation *installation = [NCMBInstallation installation];
        [installation afterFetch:[NSMutableDictionary dictionaryWithDictionary:dic]
                       isRefresh:NO];
        return installation;
    }else{
        return [NCMBInstallation installation];
    }
}

#pragma  mark override

- (void)afterFetch:(NSMutableDictionary *)response isRefresh:(BOOL)isRefresh{
    [super afterFetch:response isRefresh:isRefresh];
    if ([response objectForKey:@"deviceToken"]){
        _deviceToken = [response objectForKey:@"deviceToken"];
    }
    if ([response objectForKey:@"channels"]){
        _channels = [NSMutableArray arrayWithArray:[response objectForKey:@"channels"]];
    }
    if ([response objectForKey:@"badge"]){
        _badge = [[response objectForKey:@"badge"] integerValue];
    }
    if ([response objectForKey:@"deviceType"]){
        _deviceType = [response objectForKey:@"deviceType"];
    }
    if ([response objectForKey:@"timeZone"]){
        _timeZone = [response objectForKey:@"timeZone"];
    }
    [self saveInstallationToFile];
}

- (BOOL)fetch:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"installations/%@",self.objectId];
        result = [self fetch:url error:error isRefresh:NO];
    }
    return result;
}

- (void)fetchInBackgroundWithBlock:(NCMBFetchResultBlock)block{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"installations/%@",self.objectId];
        [self fetchInBackgroundWithBlock:url block:block isRefresh:NO];
    }
}

- (BOOL)refresh:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"installations/%@",self.objectId];
        result = [self fetch:url error:error isRefresh:YES];
    }
    return result;
}

- (void)refreshInBackgroundWithBlock:(NCMBFetchResultBlock)block{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"installations/%@",self.objectId];
        [self fetchInBackgroundWithBlock:url block:block isRefresh:YES];
    }
}

- (BOOL)delete:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"installations/%@",self.objectId];
        result = [self delete:url error:error];
    }
    return result;
}

- (void)deleteInBackgroundWithBlock:(NCMBDeleteResultBlock)userBlock{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"installations/%@",self.objectId];
        [self deleteInBackgroundWithBlock:url block:userBlock];
    }
}

- (void)afterDelete{
    [super afterDelete];
    _badge = 0;
    _channels = nil;
    _deviceToken = nil;
    _deviceType = nil;
    _timeZone = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTINSTALLATION_PATH isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:DATA_CURRENTINSTALLATION_PATH error:nil];
    }
    
}

- (void)afterSave:(NSDictionary *)response operations:(NSMutableDictionary *)operations{
    [super afterSave:response operations:operations];
    //ファイルに現在のinstallationを保存する
    [self saveInstallationToFile];
}

- (BOOL)save:(NSError **)error{
    BOOL result = NO;
    result = [self save:@"installations" error:error];
    return result;
}

- (void)saveInBackgroundWithBlock:(NCMBSaveResultBlock)userBlock{
    [self saveInBackgroundWithBlock:@"installations" block:userBlock];
}

- (void)saveInstallationToFile{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *key in [estimatedData keyEnumerator]){
        [dic setObject:[self convertToJSONFromNCMBObject:[estimatedData objectForKey:key]]
                forKey:key];
    }
    
    if (self.objectId){
        [dic setObject:self.objectId forKey:@"objectId"];
    }
    if (self.createDate){
        [dic setObject:[self convertToJSONFromNCMBObject:self.createDate] forKey:@"createDate"];
    }
    if (self.updateDate){
        [dic setObject:[self convertToJSONFromNCMBObject:self.updateDate] forKey:@"updateDate"];
    }
    if (self.ACL){
        [dic setObject:self.ACL.dicACL forKey:@"acl"];
    }
    if (_deviceToken){
        [dic setObject:_deviceToken forKey:@"deviceToken"];
    }
    if (_channels){
        [dic setObject:_channels forKey:@"channels"];
    }
    if (_badge){
        [dic setObject:[NSNumber numberWithInteger:_badge] forKey:@"badge"];
    }
    NSMutableDictionary *saveDictionary = [NSMutableDictionary dictionary];
    [saveDictionary setObject:dic forKey:@"data"];
    [saveDictionary setObject:@"installation" forKey:@"className"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:saveDictionary
                                                   options:kNilOptions
                                                     error:&error];
    [data writeToFile:DATA_CURRENTINSTALLATION_PATH atomically:YES];
}

@end
