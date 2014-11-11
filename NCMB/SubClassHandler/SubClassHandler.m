//
//  SubClassHandler.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2013/09/10.
//  Copyright 2013 NIFTY Corporation All Rights Reserved.
//

#import "SubClassHandler.h"

@interface SubClassHandler()
@property (retain ,nonatomic) NSMutableDictionary *dicSubclass;

@end

@implementation SubClassHandler
static SubClassHandler *subClassHandler= nil;

#pragma mark - 取得

-(NSString *)className:(NSString *)ncmbClassName{
    return [self.dicSubclass objectForKey:ncmbClassName];
}
#pragma mark - 登録

-(void)setSubClassName:(NSString *)className ncmbClassName:(NSString *)ncmbClassName{
    [self.dicSubclass setObject:className forKey:ncmbClassName];
}

#pragma mark = init

-(id)init{
    if((self = [super init])){
        self.dicSubclass = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - shared

+(SubClassHandler*)sharedInstance{
    if(!subClassHandler) subClassHandler = [[SubClassHandler alloc] init];
    return subClassHandler;
}

@end
