//
//  NCMBOAConsumer.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBOAConsumer.h"


@implementation NCMBOAConsumer
@synthesize key, secret;

#pragma mark init

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret {
	if ((self = [super init])) {
		self.key = aKey;
		self.secret = aSecret;
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		return [self isEqualToConsumer:(NCMBOAConsumer*)object];
	}
	return NO;
}

- (BOOL)isEqualToConsumer:(NCMBOAConsumer *)aConsumer {
	return ([self.key isEqualToString:aConsumer.key] &&
			[self.secret isEqualToString:aConsumer.secret]);
}

@end
