/*
 Copyright 2017-2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMBRelation.h"
#import "NCMBRelationOperation.h"
#import "NCMBObject.h"
#import "NCMBObject+Private.h"
#import "NCMBQuery.h"

@implementation NCMBRelation

-(id)init{
    self = [super init];
    if (self) {
        self.parent = nil;
        self.key = nil;
        self.targetClass = nil;
    }
    return self;
}

//Relation初期化用
- (id)initWithClassName:(NCMBObject *)parentObj key:(NSString *)forKey{
    self = [super init];
    if (self) {
        self.parent = parentObj;
        self.key = forKey;
        self.targetClass = nil;
    }
    return self;
}

/**
 指定されたクラス名を設定したNCMBRelationのインスタンスを返却する
 @param className リレーション先のクラス名
 */
- (id)initWithClassName:(NSString *)className{
    self = [super init];
    if (self) {
        self.parent = nil;
        self.key = nil;
        self.targetClass = className;
    }
    return self;
}

//リレーションの検索
- (NCMBQuery *)query{
    NCMBQuery *query = [NCMBQuery queryWithClassName:_targetClass];
    [query relatedTo:_parent.ncmbClassName objectId:_parent.objectId key:_key];
    return query;
    //return nil;
}

//リレーションの追加
- (void)addObject:(NCMBObject *)object{
    [self addDuplicationCheck:object];
    NSMutableSet * addObject = [NSMutableSet set];
    [addObject addObject:object];
    NCMBRelationOperation *operation = [[NCMBRelationOperation alloc]init:addObject newRelationsToRemove:nil];
    self.targetClass = operation.tagetClass;
    [self.parent performOperation:self.key byOperation:operation];
}


//リレーションの削除
- (void)removeObject:(NCMBObject *)object{
    [self removeDuplicationCheck:object];
    NSMutableSet *removeObject = [NSMutableSet set];
    [removeObject addObject:object];
    NCMBRelationOperation *operation = [[NCMBRelationOperation alloc]init:nil newRelationsToRemove:removeObject];
    self.targetClass = operation.tagetClass;
    [self.parent performOperation:self.key byOperation:operation];
}

//前回Addしたオブジェクトと重複しなければエラー
-(void)addDuplicationCheck:(NCMBObject *)object{
    id value = [[self.parent currentOperations] objectForKey:self.key];
    if(value && [value isKindOfClass:[NCMBRelationOperation class]]){
        NCMBRelationOperation *relationOperation = (NCMBRelationOperation *)value;
        if(relationOperation.relationToRemove.count > 0){
            BOOL deplication = false;
            for (id objectId in relationOperation.relationToRemove){
                if(objectId == object.objectId){
                    deplication = true;
                }
            }
            if(!deplication){
                    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Add objects in a Remove Must be the same. Call SaveAsync() to send the data." userInfo:nil] raise];
            }
        }
    }
}

//前回Removeしたオブジェクトと重複しなければエラー
-(void)removeDuplicationCheck:(NCMBObject *)object{
    id value = [[self.parent currentOperations] objectForKey:self.key];
    if(value && [value isKindOfClass:[NCMBRelationOperation class]]){
        NCMBRelationOperation *relationOperation = (NCMBRelationOperation *)value;
        if(relationOperation.relationToAdd.count > 0){
            BOOL deplication = false;
            for (id objectId in relationOperation.relationToAdd){
                if(objectId == object.objectId){
                    deplication = true;
                }
            }
            if(!deplication){
                [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Remove objects in a Add Must be the same. Call SaveAsync() to send the data." userInfo:nil] raise];
            }
            
        }
    }
}

//get時の判定
-(void)ensureParentAndKey:(NCMBObject *)someParent key:(NSString *)someKey{
    if(self.parent == nil){
        self.parent = someParent;
    }
    if(self.key == nil){
        self.key = someKey;
    }
    if(self.parent != someParent){
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Internal error. One NCMBRelation retrieved from two different NCMBObjects." userInfo:nil] raise];
    }
    if(self.key == someKey){
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Internal error. One NCMBRelation retrieved from two different Keys." userInfo:nil] raise];
    }
}

-(NSMutableDictionary *)encodeToJson{
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [json setObject:@"__type" forKey:@"Relation"];
    [json setObject:@"className" forKey:self.targetClass];
    return json;
}

@end

