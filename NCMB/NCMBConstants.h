//
//  NCMBConstants.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on  2014/10/22.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NCMBUser;
@class NCMBObject;


#pragma mark - error
#define ERRORDOMAIN @"NCMBErrorDomain"


/// コールバックブロック
typedef void (^NCMBBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^NCMBIntegerResultBlock)(int number, NSError *error);
typedef void (^NCMBObjectResultBlock)(NCMBObject *object, NSError *error);
typedef void (^NCMBArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^NCMBSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^NCMBUserResultBlock)(NCMBUser *user, NSError *error);

typedef void (^NCMBDataResultBlock)(NSData *data, NSError *error);
typedef void (^NCMBDataStreamResultBlock)(NSInputStream *stream, NSError *error);
typedef void (^NCMBProgressBlock)(int percentDone);

typedef void (^NCMBFetchResultBlock)(BOOL succeeded, NSError *error);
typedef void (^NCMBSaveResultBlock)(BOOL succeeded, NSError *error);
typedef void (^NCMBDeleteResultBlock)(BOOL succeeded, NSError *error);
typedef void (^NCMBSaveAllResultBlock)(BOOL succeeded, NSArray *results, NSError *error);
typedef void (^NCMBFetchAllResultBlock)(BOOL succeeded, NSArray *results, NSError *error);