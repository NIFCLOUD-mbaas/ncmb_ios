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
    if ([deviceTokenData isKindOfClass:[NSData class]] && [deviceTokenData length] != 0){
        const unsigned char *dataBuffer = deviceTokenData.bytes;
        NSMutableString *token  = [NSMutableString stringWithCapacity:(deviceTokenData.length * 2)];
        for (int i = 0; i < deviceTokenData.length; ++i) {
            [token appendFormat:@"%02x", dataBuffer[i]];
        }
        [self setObject:token forKey:@"deviceToken"];
    } else {
        [self setObject:nil forKey:@"deviceToken"];
        #if DEBUG
            NSLog(@"不正なデバイストークのため、端末登録を行いません");
        #endif
    }
}

-(NSDictionary*)getLocalData{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super getLocalData]];
    if (self.deviceType){
        [dic setObject:self.deviceType forKey:@"deviceType"];
    }
    if (self.deviceToken){
        [dic setObject:self.deviceToken forKey:@"deviceToken"];
    }
    if (self.badge){
        [dic setObject:[NSNumber numberWithInteger:self.badge] forKey:@"badge"];
    }
    if (self.timeZone){
        [dic setObject:self.timeZone forKey:@"timeZone"];
    }
    if (self.channels){
        [dic setObject:self.channels forKey:@"channels"];
    }
    return dic;
}

- (instancetype)init{
    NCMBInstallation *installation = [self initWithClassName:@"installation"];
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

+(NCMBInstallation*)installation{
    return [[NCMBInstallation alloc] init];
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
        if (![newSdkVer isEqualToString:sdkVer]){
            [dic setObject:newSdkVer
                                            forKey:@"sdkVersion"];
        }
        if (![newAppVer isEqualToString:appVer]){
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

#pragma mark setter

- (void)setDeviceToken:(NSString *)deviceToken{
    [self setObject:deviceToken forKey:@"deviceToken"];
}

- (void)setChannels:(NSMutableArray *)channels{
    if ([channels isKindOfClass:[NSArray class]] && [channels count] != 0){
        [self setObject:channels forKey:@"channels"];
    }
}

- (void)setBadge:(NSInteger)badge{
    [self setObject:[NSNumber numberWithInteger:badge] forKey:@"badge"];
}

#pragma mark getter

- (NSString*)deviceToken{
    return [self objectForKey:@"deviceToken"];
}

- (NSMutableArray*)channels{
    return [self objectForKey:@"channels"];
}

- (NSInteger)badge{
    return [[self objectForKey:@"badge"] integerValue];
}

#pragma  mark override

- (void)afterFetch:(NSMutableDictionary *)response isRefresh:(BOOL)isRefresh{
    [super afterFetch:response isRefresh:isRefresh];
    if ([response objectForKey:@"deviceToken"]){
        self.deviceToken = [response objectForKey:@"deviceToken"];
    }
    if ([response objectForKey:@"channels"]){
        self.channels = [NSMutableArray arrayWithArray:[response objectForKey:@"channels"]];
    }
    if ([response objectForKey:@"badge"]){
        self.badge = [[response objectForKey:@"badge"] integerValue];
    }
    if ([response objectForKey:@"deviceType"]){
        _deviceType = [response objectForKey:@"deviceType"];
    }
    if ([response objectForKey:@"timeZone"]){
        _timeZone = [response objectForKey:@"timeZone"];
    }
}

- (void)afterDelete{
    [super afterDelete];
    self.badge = 0;
    self.channels = nil;
    self.deviceToken = nil;
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

#pragma mark saveToFile

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
        NSDateFormatter *df = [self createNCMBDateFormatter];
        [dic setObject:[df stringFromDate:self.createDate] forKey:@"createDate"];
    }
    if (self.updateDate){
        NSDateFormatter *df = [self createNCMBDateFormatter];
        [dic setObject:[df stringFromDate:self.updateDate] forKey:@"updateDate"];
    }
    if (self.ACL){
        [dic setObject:self.ACL.dicACL forKey:@"acl"];
    }
    if (self.deviceToken){
        [dic setObject:self.deviceToken forKey:@"deviceToken"];
    }
    if (self.channels){
        [dic setObject:self.channels forKey:@"channels"];
    }
    if (self.badge){
        [dic setObject:[NSNumber numberWithInteger:self.badge] forKey:@"badge"];
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
