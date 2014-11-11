//
//  NCMBIncrementOperation.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/05.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBIncrementOperation.h"
#import "NCMBDeleteOperation.h"
#import "NCMBSetOperation.h"

@implementation NCMBIncrementOperation

- (NCMBIncrementOperation *)initWithClassName:(NSNumber *)newAmount{
    self = [super init];
    if( self ) {
        self.amount = newAmount;
    }
    return self;
}

-(NSMutableDictionary *)encode{
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [json setObject:@"Increment" forKey:@"__op"];
    [json setObject:self.amount forKey:@"amount"];
    return json;
}

-(NSNumber *)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    
    if(oldValue == nil){
        return self.amount;
    }
    
    if([oldValue isKindOfClass:[NSNumber class]]){
        float newValue = [oldValue floatValue] + [self.amount floatValue];
        return [NSNumber numberWithFloat:newValue];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You cannot increment a non-number." userInfo:nil] raise];
    return nil;
}



- (id)mergeWithPrevious:(id)previous{
    
    if (previous==nil) {
        return self;
    }
    
    
    if ([previous isKindOfClass:[NCMBDeleteOperation class]]) {
        return [[NCMBSetOperation alloc]initWithClassName:self.amount];
    }
    
    
    if ([previous isKindOfClass:[NCMBSetOperation class]]) {
        id oldValue = [((NCMBSetOperation *)previous) getValue];
        
        if ([oldValue isKindOfClass:[NSNumber class]]) {
            float newValue = [oldValue floatValue] + [self.amount floatValue];
            return [[NCMBSetOperation alloc] initWithClassName:[NSNumber numberWithFloat:newValue]];
        }
        
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You cannot increment a non-number." userInfo:nil] raise];
    }
    
    if ([previous isKindOfClass:[NCMBIncrementOperation class]]) {
        NSNumber *oldAmount = ((NCMBIncrementOperation *)previous).amount;
        float newValue = [oldAmount floatValue] + [self.amount floatValue];
        return [[NCMBIncrementOperation alloc] initWithClassName:[NSNumber numberWithFloat:newValue]];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}


@end
