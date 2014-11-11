//
//  NCMBAddOperation.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/05.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBAddOperation.h"
#import "NCMBDeleteOperation.h"
#import "NCMBSetOperation.h"

@implementation NCMBAddOperation


- (NCMBAddOperation *)initWithClassName:(id)newValue{
    self = [super init];
    if( self ) {
        self.objects = [[NSMutableArray alloc]init];
        //配列はそのまま代入。配列以外は追加。
        if ([newValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *newArray = (NSMutableArray *)newValue;
            self.objects = newArray;
        }else{
            [self.objects addObject:newValue];
        }
    }
    return self;
}

-(NSMutableDictionary *)encode{
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [json setObject:@"Add" forKey:@"__op"];
    [json setObject:self.objects forKey:@"objects"];
    return json;
}

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    if (oldValue == nil) {
        return self.objects;
    }
    
    //前回の値に今回追加する値を追加
    if ([oldValue isKindOfClass:[NSArray class]]) {
        NSMutableArray *newValue = [NSMutableArray array];
        
        //前回の値をすべてnewValueに追加
        for(int i=0; i<[oldValue count]; i++){
            [newValue insertObject:[oldValue objectAtIndex:i] atIndex:i];
        }
        
        //objects(今回追加する値)の要素をすべてnewValueの末尾に追加
        for(int i=0; i<[self.objects count]; i++){
            [newValue addObject:[self.objects objectAtIndex:i]];
        }
        return newValue;
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}

- (id)mergeWithPrevious:(id)previous{
    if (previous==nil) {
        return self;
    }
    
    if ([previous isKindOfClass:[NCMBDeleteOperation class]]) {
        return [[NCMBSetOperation alloc]initWithClassName:self.objects];
    }
    
    if ([previous isKindOfClass:[NCMBSetOperation class]]) {
        id oldValue = [((NCMBSetOperation *)previous) getValue];
        if ([oldValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *newValue = [NSMutableArray array];
            //前回の値をすべてnewValueに追加
            for(int i=0; i<[oldValue count]; i++){
                [newValue insertObject:[oldValue objectAtIndex:i] atIndex:i];
            }
            
            //objects(今回追加する値)の要素をすべてnewValueの末尾に追加
            for(int i=0; i<[self.objects count]; i++){
                [newValue addObject:[self.objects objectAtIndex:i]];
            }
            return [[NCMBSetOperation alloc] initWithClassName:newValue];
        }
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You can only add an item to a List." userInfo:nil] raise];
    }
    
    if ([previous isKindOfClass:[NCMBAddOperation class]]) {
        //オペレーション(前回)の値をすべてnewValueに追加
        NSMutableArray *newValue = [NSMutableArray array];
        for(int i=0; i<[((NCMBAddOperation *)previous).objects count]; i++){
            [newValue addObject:[((NCMBAddOperation *)previous).objects objectAtIndex:i]];
        }
        
        //objects(今回追加する値)の要素をすべてnewValueの末尾に追加
        for(int i=0; i<[self.objects count]; i++){
            [newValue addObject:[self.objects objectAtIndex:i]];
        }
        return [[NCMBAddOperation alloc] initWithClassName:newValue];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}
@end
