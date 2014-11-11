//
//  SubClassHandler.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2013/09/10.
//  Copyright 2013 NIFTY Corporation All Rights Reserved.
//

#import <Foundation/Foundation.h>
#define Subclass_Handler [SubClassHandler sharedInstance]
@interface SubClassHandler : NSObject

-(NSString *)className:(NSString *)ncmbClassName;
-(void)setSubClassName:(NSString *)className ncmbClassName:(NSString *)ncmbClassName;
+(SubClassHandler*)sharedInstance;
@end
