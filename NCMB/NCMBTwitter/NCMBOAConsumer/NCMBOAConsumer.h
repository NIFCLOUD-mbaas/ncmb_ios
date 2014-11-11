//
//  NCMBOAConsumer.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NCMBOAConsumer : NSObject {
@protected
	NSString *key;
	NSString *secret;
}
@property(copy, readwrite) NSString *key;
@property(copy, readwrite) NSString *secret;

- (id)initWithKey:(const NSString *)aKey secret:(const NSString *)aSecret;

- (BOOL)isEqualToConsumer:(NCMBOAConsumer *)aConsumer;

@end
