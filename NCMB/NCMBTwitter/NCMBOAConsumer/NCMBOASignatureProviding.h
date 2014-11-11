//
//  NCMBOASignatureProviding.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NCMBOASignatureProviding <NSObject>

- (NSString *)name;
- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret;

@end
