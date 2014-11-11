//
//  NCMBDeleteOperation.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/05.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBDeleteOperation.h"

@implementation NCMBDeleteOperation

-(id)encode{
    return [NSNull null];
}

- (id)getValue{
    return nil;
}

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    return nil;
}

- (id)mergeWithPrevious:(id)previous{
    return self;
}

@end