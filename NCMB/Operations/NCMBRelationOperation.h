//
//  NCMBRelationOperation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/09.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBRelationOperation : NSObject

@property (nonatomic,retain)NSString *tagetClass;
@property (nonatomic,retain)NSMutableSet *relationToAdd;
@property (nonatomic,retain)NSMutableSet *relationToRemove;


- (id)init:(NSMutableSet *)newRelationsToAdd newRelationsToRemove:(NSMutableSet *)newRelationsToRemove;

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key;

- (id)mergeWithPrevious:(id)previous;

- (id)encode;

@end
