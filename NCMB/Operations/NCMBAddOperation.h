//
//  NCMBAddOperation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/05.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBAddOperation : NSObject

@property (nonatomic,retain)NSMutableArray *objects;

- (NCMBAddOperation *)initWithClassName:(id)newValue;

- (NSMutableDictionary *)encode;

- (id)mergeWithPrevious:(id)previous;

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key;


@end
