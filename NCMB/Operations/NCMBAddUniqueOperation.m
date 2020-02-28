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

#import "NCMBAddUniqueOperation.h"
#import "NCMBObject.h"
#import "NCMBDeleteOperation.h"
#import "NCMBSetOperation.h"

@implementation NCMBAddUniqueOperation

- (NCMBAddUniqueOperation *)initWithClassName:(id)newValue{
    self = [super init];
    if( self ) {
        self.objects =  [NSMutableArray array];
        if ([newValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *newArray = (NSMutableArray *)newValue;
            [self.objects addObjectsFromArray:newArray];
        }else{
            [self.objects addObject:newValue];
        }
    }
    return self;
}

-(NSMutableDictionary *)encode{
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [json setObject:@"AddUnique" forKey:@"__op"];
    [json setObject:self.objects forKey:@"objects"];
    return json;
}

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    if (oldValue == nil) {
        return self.objects;
    }
    
    if ([oldValue isKindOfClass:[NSArray class]]) {
        NSMutableArray *newValue = [NSMutableArray array];
        //oldValueの要素をすべてnewValueに挿入
        for(int i=0; i<[oldValue count]; i++){
            [newValue insertObject:[oldValue objectAtIndex:i] atIndex:i];
        }
        
        /** 以下NCMBObjectの重複処理　ObjectIdが同じものは上書き　違うものは末尾に追加*/
        
        //前回のオブジェクトのobjectIDを保管する。key:各objectID　value:NSNumber
        NSMutableDictionary *existingObjectIds = [NSMutableDictionary dictionary];
        for(int i=0; i<[newValue count]; i++){
            //前回のオブジェクトからNCMBObjectがあるか検索
            if ([[newValue objectAtIndex:i] isKindOfClass:[NCMBObject class]]) {
                //NCMBObjectがあればkeyにobjectID、valueにNSNumber追加
                if([((NCMBObject *)[newValue objectAtIndex:i]) objectId]){
                    [existingObjectIds setObject:[NSNumber numberWithInt:i] forKey:[((NCMBObject *)[newValue objectAtIndex:i]) objectId]];
                }else{
                    [existingObjectIds setObject:[NSNumber numberWithInt:i] forKey:[NSNull null]];
                }
            }
        }
        
        NSEnumerator* localEnumerator = [self.objects objectEnumerator];
        id NCMBObj;
        while (NCMBObj = [localEnumerator nextObject]) {
            if ([NCMBObj isKindOfClass:[NCMBObject class]]){
                //objectsのobjectIdと先ほど生成したexistingObjectIdsのobjectIdが一致した場合、existingObjectIdsのvalue:NSNumberを返す。なければnilを返す。
                NSNumber *index = [existingObjectIds objectForKey:[NCMBObj objectId]];
                if (index != nil) {
                    [newValue insertObject:NCMBObj atIndex:[index intValue]];//一致した場所にオブジェクト追加
                }
                else{
                    [newValue addObject:NCMBObj];//一致しなかった場合は末に追加
                }
            }
            else if (![newValue containsObject:NCMBObj]){
                [newValue addObject:NCMBObj];//NCMBObjectではなかった場合は末に追加
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
        return [[NCMBSetOperation alloc]initWithClassName:self.objects];
    }
    
    if ([previous isKindOfClass:[NCMBSetOperation class]]) {
        id oldValue = [((NCMBSetOperation *)previous) getValue];
        
        if ([oldValue isKindOfClass:[NSArray class]]) {
            //apply結果を元にインスタンス生成
            return [[NCMBSetOperation alloc] initWithClassName:[self apply:oldValue NCMBObject:nil forkey:nil]];
        }
        
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You can only add an item to a List." userInfo:nil] raise];
    }
    
    if ([previous isKindOfClass:[NCMBAddUniqueOperation class]]) {
        //オペレーション要素全てをresultに挿入(初期化)
        NSArray *oldValue = ((NCMBAddUniqueOperation *)previous).objects;
        //オペレーション要素に対してapply実行
        NSMutableArray * newValue = [self apply:oldValue NCMBObject:nil forkey:nil];
        //apply結果を元にインスタンスの生成
        return [[NCMBAddUniqueOperation alloc] initWithClassName:newValue];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You can only add an item to a List." userInfo:nil] raise];
    return nil;
}

@end
