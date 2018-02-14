/*
 Copyright 2017-2018 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMBRelationOperation.h"
#import "NCMBObject.h"
#import "NCMBRelation.h"
#import "NCMBDeleteOperation.h"
#import "NCMBRelation+Private.h"

@implementation NCMBRelationOperation

- (id)init:(NSMutableSet *)newRelationsToAdd newRelationsToRemove:(NSMutableSet *)newRelationsToRemove{
    self = [super init];
    if( self ) {
        //子のクラス名
        self.tagetClass = nil;
        //add対象のobjectID
        self.relationToAdd = [NSMutableSet set];
        //remove対象のobjectID
        self.relationToRemove = [NSMutableSet set];
        
        //add操作時
        if (newRelationsToAdd != nil) {
            for (NCMBObject *object in newRelationsToAdd) {
                //objectId判定
                if ([object objectId] == nil) {
                    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"must need object ids" userInfo:nil] raise];
                }else{
                    [self.relationToAdd addObject:[object objectId]];
                }
                //対象のクラス判定
                if (self.tagetClass == nil) {
                    self.tagetClass = object.ncmbClassName;
                }else{
                    NSString *str = [NSString stringWithFormat:@"relation class is %@",self.tagetClass];
                    [[NSException exceptionWithName:NSInternalInconsistencyException reason:str userInfo:nil] raise];
                }
            }
        }
        
        //remove操作時
        if (newRelationsToRemove != nil) {
            for (NCMBObject *object in newRelationsToRemove) {
                //objectId判定
                if ([object objectId] == nil) {
                    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"must need object ids" userInfo:nil] raise];
                }else{
                    [self.relationToRemove addObject:[object objectId]];
                }
                //対象のクラス判定
                if (self.tagetClass == nil) {
                    self.tagetClass = object.ncmbClassName;
                }else{
                    NSString *str = [NSString stringWithFormat:@"relation class is %@",self.tagetClass];
                    [[NSException exceptionWithName:NSInternalInconsistencyException reason:str userInfo:nil] raise];
                }
            }
        }
        if (self.tagetClass == nil) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"All objects in a relation must be of the same class." userInfo:nil] raise];
        }
        
    }
    return self;
}

//merge用コンストラクタ
- (id)initWithClassName:(NSString *)newTargetClass newRelationsToAdd:(NSMutableSet *)newRelationsToAdd newRelationsToRemove:(NSMutableSet *)newRelationsToRemove{
    self = [super init];
    if( self ) {
        //子のクラス名
        self.tagetClass = newTargetClass;
        //add対象のobjectID
        self.relationToAdd = [NSMutableSet setWithSet:newRelationsToAdd];
        //remove対象のobjectID
        self.relationToRemove = [NSMutableSet setWithSet:newRelationsToRemove];
    }
    return self;
}

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    //relationクラスのparent(NCMBObject)とkeyとクラス名の更新
    if (oldValue == nil || ([oldValue isKindOfClass:[NSArray class]] && [oldValue count] == 0)) {
        NCMBRelation *relation = [[NCMBRelation alloc]initWithClassName:object key:key];
        relation.targetClass = self.tagetClass;
        return relation;
    }
    
    //relationクラスのクラス名の更新
    if ([oldValue isKindOfClass:[NCMBRelation class]]) {
        NCMBRelation *relation = oldValue;
        //関連付けするオブジェクトのクラス判定
        if (self.tagetClass != nil && [relation targetClass] != nil) {
            if (![[relation targetClass] isEqual:self.tagetClass]) {
                NSString * str = [NSString stringWithFormat:@"Related object object must be of class %@, but %@ esd passed in.",[relation targetClass],self.tagetClass];
                [[NSException exceptionWithName:NSInternalInconsistencyException reason:str userInfo:nil] raise];
            }
            relation.targetClass = self.tagetClass;
        }
        return relation;
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}

//encode実行時の__opとobjectsのオペレーション作成
- (id)mergeWithPrevious:(id)previous{
    
    if (previous==nil) {
        return self;
    }
    
    if ([previous isKindOfClass:[NCMBDeleteOperation class]]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You can't modify a relation after deleting it." userInfo:nil] raise];
    }
    
    if ([previous isKindOfClass:[NCMBRelationOperation class]]) {
        NCMBRelationOperation *previousOperation = previous;
        if ([previousOperation tagetClass] != nil && ![[previousOperation tagetClass] isEqual:self.tagetClass]) {
            NSString * str = [NSString stringWithFormat:@"Related object object must be of class %@, but %@ esd passed in.",[previousOperation tagetClass],self.tagetClass];
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:str userInfo:nil] raise];
        }
        
        NSMutableSet *newRelationsToAdd = [NSMutableSet setWithSet:[previousOperation relationToAdd]];
        NSMutableSet *newRelationsToRemove = [NSMutableSet setWithSet:[previousOperation relationToRemove]];
        
        //addデータ操作時 addするobjectIdをすべて追加する
        if (self.relationToAdd != nil) {
            NSMutableSet *SelfRelationsToAdd = [NSMutableSet setWithSet:self.relationToAdd];
            for (NSString *str in SelfRelationsToAdd) {
                [newRelationsToAdd addObject:str];
            }
            
            for (NSString *str in self.relationToAdd) {
                [newRelationsToRemove removeObject:str];
            }
        }
        
        //removeデータ操作時 removeするobjectIdをすべて追加する
        if (self.relationToRemove != nil) {
            for (NSString *str in self.relationToRemove) {
                [newRelationsToAdd removeObject:str];
            }
            NSMutableSet *SelfRelationsToRemove = [NSMutableSet setWithSet:self.relationToRemove];
            for (NSString *str in SelfRelationsToRemove) {
                [newRelationsToRemove addObject:str];
            }
            
        }
        return [[NCMBRelationOperation alloc]initWithClassName:self.tagetClass newRelationsToAdd:newRelationsToAdd newRelationsToRemove:newRelationsToRemove];
    }
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}

-(id)encode{
    NSMutableDictionary *addJson = nil;
    NSMutableDictionary *removeJson = nil;
    
    if ([self.relationToAdd count]>0) {
        addJson = [[NSMutableDictionary alloc]init];
        [addJson setObject:@"AddRelation" forKey:@"__op"];
        [addJson setObject:[self convertSetToArray:self.relationToAdd] forKey:@"objects"];
    }
    
    if ([self.relationToRemove count]>0) {
        removeJson = [[NSMutableDictionary alloc]init];
        [removeJson setObject:@"RemoveRelation" forKey:@"__op"];
        [removeJson setObject:[self convertSetToArray:self.relationToRemove] forKey:@"objects"];
    }
    
    if (addJson != nil) {
        return addJson;
    }
    
    if (removeJson != nil) {
        return removeJson;
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"A NCMBRelationOperation was created without any data." userInfo:nil] raise];
    return nil;
}

//encodeメソッド内で使用。キー(objects)の値を作成
-(NSMutableArray *)convertSetToArray:(NSMutableSet*)set{
    NSMutableArray *convertArray = [[NSMutableArray alloc]init];
    for (NSString *objectId in set) {
        NSMutableDictionary *pointer = [[NSMutableDictionary alloc]init];
        [pointer setObject:@"Pointer" forKey:@"__type"];
        [pointer setObject:self.tagetClass forKey:@"className"];
        [pointer setObject:objectId forKey:@"objectId"];
        [convertArray addObject:pointer];
    }
    return convertArray;
}

@end
