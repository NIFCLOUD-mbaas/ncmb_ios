//
//  NCMBObject+Subclass.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2013/06/12.
//  Copyright 2013 NIFTY Corporation All Rights Reserved.
//

#import "NCMBObject.h"

@class NCMBQuery;

@interface NCMBObject (Subclass)

/*! @name Methods */

- (id)init;

+ (id)object;

+ (id)objectWithoutDataWithObjectId:(NSString *)objectId;

+ (void)registerSubclass;

+ (NCMBQuery *)query;

@end
