//
//  NCMBRemoveOperation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/09.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBRemoveOperation : NSObject

@property (nonatomic,retain)NSMutableSet *objects;

- (NCMBRemoveOperation *)initWithClassName:(id)newValue;

- (NSMutableDictionary *)encode;

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key;

- (id)mergeWithPrevious:(id)previous;

@end