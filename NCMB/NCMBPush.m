//
//  NCMBPush.m
//  NCMB
//
//  Created by SCI01433 on 2014/11/07.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBPush.h"

#import "NCMBQuery.h"

#import "NCMBObject+Private.h"
#import "NCMBQuery+Private.h"
#import "NCMBRichPushView.h"

@interface NCMBPush ()

@property (nonatomic)NCMBQuery *searchCondition;

@end

@implementation NCMBPush

+(NCMBQuery*)query{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"push"];
    return query;
}

+(instancetype)push{
    NCMBPush *push = [[NCMBPush alloc] init];
    return push;
}

-(instancetype)init{
    self = [super init];
    if (self){
        _searchCondition = [NCMBQuery queryWithClassName:@"push"];
    }
    return self;
}

#pragma mark - handlilng

+(id)stringWithFormat:(NSString*)format arrayArguments:(NSArray*)argsArray{
    NSRange range = NSMakeRange(0, [argsArray count]);
    
    NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [argsArray count]];
    
    [argsArray getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
    
    NSString *str =  [[NSString alloc] initWithFormat:format  arguments: data.mutableBytes];
    return str;
}

+ (void)handlePush:(NSDictionary *)userInfo{
    
    NSMutableDictionary *dicAps = [userInfo objectForKey:@"aps"];
    NSString *message = nil;
    NSString *cancelButtonTitle = @"Close";
    NSString *actionButtonTitle = nil;
    UIAlertView *alert = nil;
    UIAlertController *alertController = nil;
    if ([[dicAps objectForKey:@"alert"] isKindOfClass:[NSNull class]]) {
    }else if ([[dicAps objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        message = [dicAps objectForKey:@"alert"];
    }else{
        NSMutableDictionary *dicParams = [NSMutableDictionary dictionary];
        [dicParams setDictionary:[dicAps objectForKey:@"alert"]];
        if ([dicParams objectForKey:@"body"]) {
            message = [dicParams objectForKey:@"body"];
        }
        if ([dicParams objectForKey:@"loc-key"]) {
            message = [NCMBPush stringWithFormat:NSLocalizedString([dicParams objectForKey:@"loc-key"], @"loc-key") arrayArguments:[dicParams objectForKey:@"loc-args"]];
        }
        if ([dicParams objectForKey:@"action-loc-key"]) {
            actionButtonTitle = NSLocalizedString([dicParams objectForKey:@"action-loc-key"], @"action-loc-key");
        }
        alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:actionButtonTitle,nil];
    }
    
    if ([dicAps objectForKey:@"sound"]) {
        NSString *strSound = [dicAps objectForKey:@"sound"];
        if ([strSound isKindOfClass:[NSNull class]]) {
            
        }else{
            NSArray *ary = [strSound componentsSeparatedByString:@"."];
            if ([ary count]>2) {
                NSString *strSoundName = (NSString*)[ary objectAtIndex:0];
                NSString *strSoundType = (NSString*)[ary objectAtIndex:1];
                CFStringRef cfstr_sound_name = CFStringCreateWithCString(kCFAllocatorDefault, [strSoundName UTF8String],kCFStringEncodingUTF8 );
                CFStringRef cfstr_sound_type = CFStringCreateWithCString(kCFAllocatorDefault, [strSoundType UTF8String],kCFStringEncodingUTF8 );
                SystemSoundID mSound = 0;
                CFBundleRef mainBundle = CFBundleGetMainBundle();
                CFURLRef soundURL = CFBundleCopyResourceURL(mainBundle, cfstr_sound_name, cfstr_sound_type, NULL );
                AudioServicesCreateSystemSoundID( soundURL, &mSound );
                AudioServicesPlaySystemSound( mSound );
                CFRelease(soundURL);
                CFRelease(cfstr_sound_name);
                CFRelease(cfstr_sound_type);
            }
            
        }
    }
    if (![[dicAps objectForKey:@"badge"] isKindOfClass:[NSNull class]]) {
        
        if ([dicAps objectForKey:@"badge"]) {
            [UIApplication sharedApplication].applicationIconBadgeNumber= [[dicAps objectForKey:@"badge"] integerValue];
        }
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
            baseView = baseView.presentedViewController;
        }
        alertController = [UIAlertController alertControllerWithTitle:nil
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [baseView dismissViewControllerAnimated:YES completion:nil];
        }]];
        [baseView presentViewController:alertController animated:YES completion:nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:cancelButtonTitle
                                 otherButtonTitles:actionButtonTitle, nil];
        [alert show];
    }
}

+ (void) handleRichPush:(NSDictionary *)userInfo {
    NSString *url = [userInfo objectForKey:@"com.nifty.RichUrl"];
    
    if ([url isKindOfClass:[NSString class]]) {
        NCMBRichPushView *rv = [[NCMBRichPushView alloc]init];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
        [rv appearWebView:orientation url:url];
    }
}

#pragma mark - push notification configuration

- (void)setUserSettingValue:(NSDictionary *)userSettingValue{
    [self setObject:userSettingValue forKey:@"userSettingValue"];
}

- (void)setChannel:(NSString *)channel{
    [_searchCondition whereKey:@"channnels" containedIn:@[channel]];
}

- (void)setChannels:(NSArray *)channels{
    [_searchCondition whereKey:@"channels" containedIn:channels];
}

- (void)setPushToAndroid:(BOOL)pushToAndroid{
    NSMutableArray *sendDeviceType;
    if ([[estimatedData allKeys] containsObject:@"target"]){
        sendDeviceType = [NSMutableArray arrayWithObject:[estimatedData objectForKey:@"target"]];
    } else {
        sendDeviceType = [NSMutableArray array];
    }
    if (pushToAndroid){
        if ([sendDeviceType indexOfObject:@"android"] == NSNotFound){
            [sendDeviceType addObject:@"android"];
        }
    } else {
        NSUInteger index = [sendDeviceType indexOfObject:@"android"];
        if (index != NSNotFound){
            [sendDeviceType removeObjectAtIndex:index];
        }
    }
    [super setObject:sendDeviceType forKey:@"target"];
}

- (void)setPushToIOS:(BOOL)pushToIOS{
    NSMutableArray *sendDeviceType;
    if ([[estimatedData allKeys] containsObject:@"target"]){
        sendDeviceType = [NSMutableArray arrayWithObject:[estimatedData objectForKey:@"target"]];
    } else {
        sendDeviceType = [NSMutableArray array];
    }
    if (pushToIOS){
        if ([sendDeviceType indexOfObject:@"ios"] == NSNotFound){
            [sendDeviceType addObject:@"ios"];
        }
    } else {
        NSUInteger index = [sendDeviceType indexOfObject:@"ios"];
        if (index != NSNotFound){
            [sendDeviceType removeObjectAtIndex:index];
        }
    }
    [super setObject:sendDeviceType forKey:@"target"];
}

- (void)setDialog:(BOOL)dialog{
    [super setObject:[NSNumber numberWithBool:dialog] forKey:@"dialog"];
}

- (void)setImmediateDeliveryFlag:(BOOL)immediateDeliveryFlag{
    [super setObject:[NSNumber numberWithBool:immediateDeliveryFlag] forKey:@"immediateDeliveryFlag"];
    [self removeObjectForKey:@"deliveryTime"];
}

- (void)setDeliveryTime:(NSDate *)date{
    [super setObject:date forKey:@"deliveryTime"];
    [self removeObjectForKey:@"immediateDeliveryFlag"];
}

- (void)setMessage:(NSString *)message{
    [super setObject:message forKey:@"message"];
}

- (void)setQuery:(NCMBQuery *)query{
    if ([query.ncmbClassName isEqualToString:@"push"]){
        _searchCondition = query;
    }
}

- (void)setRichUrl:(NSString *)url{
    [super setObject:url forKey:@"richUrl"];
}

- (void)setTitle:(NSString *)title{
    [super setObject:title forKey:@"title"];
}

- (void)setAction:(NSString *)actionName{
    [super setObject:actionName forKey:@"action"];
}

- (void)setContentAvailable:(BOOL)contenteAvailable{
    [super setObject:[NSNumber numberWithBool:contenteAvailable] forKey:@"contentAvailable"];
    [self removeObjectForKey:@"contentAvailable"];
}

- (void)setBadgeIncrementFlag:(BOOL)badgeIncrementFlag{
    [super setObject:[NSNumber numberWithBool:badgeIncrementFlag] forKey:@"badgeIncrementFlag"];
    [self removeObjectForKey:@"contentAvailable"];
}

- (void)setBadgeNumber:(int)badgeNumber{
    if (![self objectForKey:@""] && ![self objectForKey:@"badgeIncrementFlag"]){
        [super setObject:[NSNumber numberWithInt:badgeNumber] forKey:@"badgeSetting"];
    }
}

- (void)setSound:(NSString *)soundFileName{
    [super setObject:soundFileName forKey:@"sound"];
}

- (void)expireAtDate:(NSDate *)date{
    [super setObject:date forKey:@"deliveryExpirationDate"];
}

- (void)expireAfterTimeInterval:(NSString *)timeInterval{
    [super setObject:timeInterval forKey:@"deliveryExpirationTime"];
}

- (void)clearExpiration{
    [self removeObjectForKey:@"deliveryExpirationDate"];
    [self removeObjectForKey:@"deliveryExpirationTime"];
}

- (void)setData:(NSDictionary*)dic{
    for (NSString *key in [[dic allKeys] objectEnumerator]){
        [super setObject:[dic objectForKey:key] forKey:key];
    }
}

#pragma mark - sendPush

- (BOOL)sendPush:(NSError **)error{
    return [self save:error];
}

- (void)sendPushInBackgroundWithBlock:(NCMBBooleanResultBlock)block{
    [self saveInBackgroundWithBlock:block];
}

- (void)sendPushInBackgroundWithTarget:(id)target selector:(SEL)selector{
    [self saveInBackgroundWithTarget:target selector:selector];
}

+ (BOOL)sendPushDataToChannel:(NSString *)channel
                     withData:(NSDictionary *)data
                        error:(NSError **)error{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setChannel:channel];
    [push setData:data];
    return [push sendPush:error];
    
}

+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                    block:(NCMBBooleanResultBlock)block{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setChannel:channel];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:block];
}

+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                   target:(id)target
                                 selector:(SEL)selector{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setChannel:channel];
    [push setData:data];
    [push sendPushInBackgroundWithTarget:target selector:selector];
    
}

+ (BOOL)sendPushDataToQuery:(NCMBQuery *)query
                   withData:(NSDictionary *)data
                      error:(NSError **)error{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setQuery:query];
    [push setData:data];
    return [push sendPush:error];
}

+ (void)sendPushDataToQueryInBackground:(NCMBQuery *)query
                               withData:(NSDictionary *)data
                                  block:(NCMBBooleanResultBlock)block{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setQuery:query];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:block];
}

+ (BOOL)sendPushMessageToChannel:(NSString *)channel
                     withMessage:(NSString *)message
                           error:(NSError **)error{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setChannel:channel];
    [push setMessage:message];
    return [push sendPush:error];
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                       block:(NCMBBooleanResultBlock)block{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setChannel:channel];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:block];
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                      target:(id)target
                                    selector:(SEL)selector{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setChannel:channel];
    [push setMessage:message];
    [push sendPushInBackgroundWithTarget:target selector:selector];
}

+ (BOOL)sendPushMessageToQuery:(NCMBQuery *)query
                   withMessage:(NSString *)message
                         error:(NSError **)error{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    return [push sendPush:error];
}

+ (void)sendPushMessageToQueryInBackground:(NCMBQuery *)query
                               withMessage:(NSString *)message
                                     block:(NCMBBooleanResultBlock)block{
    NCMBPush *push = [[NCMBPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:block];
}

#pragma mark - override

- (BOOL)save:(NSError **)error{
    BOOL result = NO;
    [super setObject:[_searchCondition getQueryDictionary] forKey:@"searchCondition"];
    NSString *url = [NSString stringWithFormat:@"push"];
    result = [self save:url error:error];
    return result;
}

- (void)saveInBackgroundWithBlock:(NCMBSaveResultBlock)userBlock{
    [super setObject:[_searchCondition getQueryDictionary] forKey:@"searchCondition"];
    NSString *url = [NSString stringWithFormat:@"push"];
    [self saveInBackgroundWithBlock:url block:userBlock];
}

- (BOOL)fetch:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"push"];
        [self fetch:url error:error isRefresh:NO];
        result = YES;
    }
    return result;
}

- (void)fetchInBackgroundWithBlock:(NCMBFetchResultBlock)block{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"push"];
        [self fetchInBackgroundWithBlock:url block:block isRefresh:NO];
    }
}

- (BOOL)refresh:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"push"];
        [self fetch:url error:error isRefresh:YES];
        result = YES;
    }
    return result;
}

- (void)refreshInBackgroundWithBlock:(NCMBFetchResultBlock)block{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"push"];
        [self fetchInBackgroundWithBlock:url block:block isRefresh:YES];
    }
}

- (BOOL)delete:(NSError **)error{
    BOOL result = NO;
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"push"];
        [self delete:url error:error];
        result = YES;
    }
    return result;
}

- (void)deleteInBackgroundWithBlock:(NCMBDeleteResultBlock)userBlock{
    if (self.objectId){
        NSString *url = [NSString stringWithFormat:@"push"];
        [self deleteInBackgroundWithBlock:url block:userBlock];
    }
}

- (void)setObject:(id)object forKey:(NSString *)key{
    //NCMBPushクラスは任意フィールドを設定できない
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"UnsupportedOperation." userInfo:nil] raise];
}

@end
