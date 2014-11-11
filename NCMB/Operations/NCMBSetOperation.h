//
//  NCMBSetOperation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/04.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBSetOperation : NSObject

@property (nonatomic) id value;

- (id)initWithClassName:(id)newValue;

- (id)getValue;

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key;

- (id)encode;

- (id)mergeWithPrevious:(id)previous;
@end