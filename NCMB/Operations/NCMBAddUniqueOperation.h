//
//  NCMBAddUniqueOperation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/05.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBAddUniqueOperation : NSObject

@property (nonatomic,retain)NSMutableSet *objects;

- (NCMBAddUniqueOperation *)initWithClassName:(id)newValue;

- (NSMutableDictionary *)encode;

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key;

- (id)mergeWithPrevious:(id)previous;

@end