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

#import "NCMBRemoveOperation.h"
#import "NCMBDeleteOperation.h"
#import "NCMBSetOperation.h"
#import "NCMBObject.h"

@implementation NCMBRemoveOperation

- (NCMBRemoveOperation *)initWithClassName:(id)newValue{
    self = [super init];
    if( self ) {
        self.objects =  [NSMutableSet set];
        if ([newValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *newArray = (NSMutableArray *)newValue;
            [self.objects addObjectsFromArray:newArray];
        }else{
            self.objects = [NSMutableSet setWithSet:newValue];
        }
    }
    return self;
}

-(NSMutableDictionary *)encode{
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [json setObject:@"Remove" forKey:@"__op"];
    NSArray *objects = [self.objects allObjects];//NSSetの全ての要素をNSArray型で取得する
    [json setObject:objects forKey:@"objects"];
    return json;
}

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    
    if (oldValue == nil) {
        return [NSMutableArray array];
    }
    
    if ([oldValue isKindOfClass:[NSArray class]]) {
        //前回のキー要素から今回指定したobjectsの値削除
        NSMutableArray *newValue = [NSMutableArray array];
        [newValue setArray:oldValue];
        NSArray *removedList = [self.objects allObjects];
        [newValue removeObjectsInArray:removedList];
        
        /** 以下NCMBObjectの重複処理　ObjectIdが同じものを配列から削除*/
        NSMutableArray *objectsToBeRemoved = [NSMutableArray array];//remove対象のobject格納
        NSArray *objectsToBeRemovedList = [[NSArray alloc]init];//remove対象のobject格納
        NSMutableSet *objectIds = [NSMutableSet set];//remove対象(NCMBObject)のobjectId格納
        
        //NSSetからNSArrayに変換。NSArrayからNSMutableArrayに変換
        objectsToBeRemovedList = [self.objects allObjects];
        [objectsToBeRemoved addObjectsFromArray:objectsToBeRemovedList];
        
        //今回指定したobjectsからnewValueの値削除
        [objectsToBeRemoved removeObjectsInArray:newValue];
        
        //削除対象(NCMBOBject)のobjectIdを取得
        NSEnumerator *localEnumerator = [objectsToBeRemoved objectEnumerator];//
        id removeNCMBObject;
        while (removeNCMBObject = [localEnumerator nextObject]) {
            if ([removeNCMBObject isKindOfClass:[NCMBObject class]]){
                [objectIds addObject:[removeNCMBObject objectId]];
            }
        }
        
        //取得したobjectIdと同じNCMBObjectを削除
        id NCMBObj;
        for(int i=0; i<[newValue count]; i++){
            NCMBObj = [newValue objectAtIndex:i];
            if ([NCMBObj isKindOfClass:[NCMBObject class]] && [objectIds containsObject:[NCMBObj objectId]]){
                [newValue removeObjectAtIndex:i];
            }
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
        return [[NCMBSetOperation alloc]initWithClassName:[NSMutableArray array]];
    }
    
    if ([previous isKindOfClass:[NCMBSetOperation class]]) {
        id Value = [((NCMBSetOperation *)previous) getValue];
        if ([Value isKindOfClass:[NSArray class]]) {
            //apply結果を元にインスタンス生成
            return [[NCMBSetOperation alloc] initWithClassName:[self apply:Value NCMBObject:nil forkey:nil]];
        }
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You can only add an item to a List." userInfo:nil] raise];
    }
    if ([previous isKindOfClass:[NCMBRemoveOperation class]]) {
        //前回の値をresultに代入
        NSMutableSet *newValue = [NSMutableSet setWithSet:((NCMBRemoveOperation *)previous).objects];
        //今回引数の値(remove対象)をresultに代入
        for (id obj in self.objects) {
            [newValue addObject:obj];
        }
        return [[NCMBRemoveOperation alloc] initWithClassName:newValue];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}


@end
