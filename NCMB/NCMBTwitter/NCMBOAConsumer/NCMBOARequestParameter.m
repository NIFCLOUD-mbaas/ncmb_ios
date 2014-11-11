//
//  NCMBOARequestParameter.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import "NCMBOARequestParameter.h"


@implementation NCMBOARequestParameter
@synthesize name, value;

- (id)initWithName:(NSString *)aName value:(NSString *)aValue {
    if ((self = [super init])) {
		self.name = aName;
		self.value = aValue;
	}
    return self;
}

- (NSString *)URLEncodedName {
	return self.name;
//    return [self.name encodedURLParameterString];
}

- (NSString *)URLEncodedValue {
    return [NSStringOAURLEncodingAdditions encodedURLParameterStringWithString:self.value];
}

- (NSString *)URLEncodedNameValuePair {
    return [NSString stringWithFormat:@"%@=%@", [self URLEncodedName], [self URLEncodedValue]];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		return [self isEqualToRequestParameter:(NCMBOARequestParameter *)object];
	}
	
	return NO;
}

- (BOOL)isEqualToRequestParameter:(NCMBOARequestParameter *)parameter {
	return ([self.name isEqualToString:parameter.name] &&
			[self.value isEqualToString:parameter.value]);
}


+ (id)requestParameter:(NSString *)aName value:(NSString *)aValue
{
	return [[self alloc] initWithName:aName value:aValue];
}

@end
