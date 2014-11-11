//
//  NCMBInstallation.m
//  NCMB
//
//  Created by SCI01433 on 2014/11/06.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBInstallation.h"
#import "NCMBQuery.h"
#import "NCMBACL.h"

#import "NCMBObject+Private.h"

//TODO:どこかに移す
#define SDK_VERSION @"2.0"

#define DATA_CURRENTINSTALLATION_PATH [NSString stringWithFormat:@"%@/Private Documents/NCMB/currentInstallation", DATA_MAIN_PATH]

@implementation NCMBInstallation

+(NCMBQuery*)query{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"installation"];
    return query;
}

- (void)setDeviceTokenFromData:(NSData *)deviceTokenData{
    NSLog(@"setDeviceToken start.");
    NSMutableString *tokenId = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",deviceTokenData]];
    [tokenId setString:[tokenId stringByReplacingOccurrencesOfString:@" " withString:@""]]; //余計な文字を消す
    [tokenId setString:[tokenId stringByReplacingOccurrencesOfString:@"<" withString:@""]];
    [tokenId setString:[tokenId stringByReplacingOccurrencesOfString:@">" withString:@""]];
    //[self setDeviceToken:tokenId];
    [self setObject:tokenId forKey:@"deviceToken"];
    NSLog(@"setDeviceToken end.");
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

-(instancetype)init{
    self = [super initWithClassName:@"installation"];
    if (self) {
        _channels = [NSMutableArray array];
    }
    return self;
}

+(NCMBInstallation*)installation{
    NCMBInstallation *installation = [[NCMBInstallation alloc] init];
    [installation setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] forKey:@"applicationName"];
    [installation setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
    [installation setObject:SDK_VERSION forKey:@"sdkVersion"];
    
    [installation setObject:@"ios" forKey:@"deviceType"];
    
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    [installation setObject:[tz name] forKey:@"timeZone"];
    return installation;
}

+(NCMBInstallation*)currentInstallation{
    /*if (currentInstallation) {
        NSLog(@"currentInstallation exist:%@", currentInstallation);
    }else*/ if ([[NSFileManager defaultManager] fileExistsAtPath:DATA_CURRENTINSTALLATION_PATH isDirectory:nil]) {
        NSError *error = nil;
        NSData *localData = [NSData dataWithContentsOfFile:DATA_CURRENTINSTALLATION_PATH
                                                   options:kNilOptions
                                                     error:&error];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:localData
                                                             options:kNilOptions
                                                               error:&error];
        NSLog(@"jsonInstallation:%@", json);
        NCMBInstallation *installation = [[NCMBInstallation alloc] init];
        [installation afterFetch:[NSMutableDictionary dictionaryWithDictionary:json] isRefresh:NO];
        return installation;
    }else{
        NSLog(@"update current Installation");
        return [NCMBInstallation installation];
    }
}

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
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:estimatedData];
    if (self.objectId){
        [dic setObject:self.objectId forKey:@"objectId"];
    }
    if (self.createdDate){
        [dic setObject:[self convertToJSONFromNCMBObject:self.createdDate] forKey:@"createdDate"];
    }
    if (self.updatedDate){
        [dic setObject:[self convertToJSONFromNCMBObject:self.updatedDate] forKey:@"updatedDate"];
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
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                   options:kNilOptions
                                                     error:&error];
    [data writeToFile:DATA_CURRENTINSTALLATION_PATH atomically:YES];
}

@end
