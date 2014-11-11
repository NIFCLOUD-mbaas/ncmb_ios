//
//  NCMBDeleteOperation.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/05.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCMBDeleteOperation : NSObject

- (id)getValue;

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key;

- (id)encode;

- (id)mergeWithPrevious:(id)previous;

@end