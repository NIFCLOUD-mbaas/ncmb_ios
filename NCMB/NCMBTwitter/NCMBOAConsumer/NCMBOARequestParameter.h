//
//  NCMBOARequestParameter.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NSStringURLEncoding.h"


@interface NCMBOARequestParameter : NSObject {
@protected
    NSString *name;
    NSString *value;
}
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *value;

- (id)initWithName:(NSString *)aName value:(NSString *)aValue;
- (NSString *)URLEncodedName;
- (NSString *)URLEncodedValue;
- (NSString *)URLEncodedNameValuePair;

- (BOOL)isEqualToRequestParameter:(NCMBOARequestParameter *)parameter;

+ (id)requestParameter:(NSString *)aName value:(NSString *)aValue;

@end
