//
//  NCMBError.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/21.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBError.h"

NSInteger const kNCMBErrorObjectNotFound = 100;

NSString const *kNCMBErrorInvalidJson = @"E400001";
NSString const *kNCMBErrorInvalidType = @"E400002";
NSString const *kNCMBErrorRequired = @"E400003";
NSString const *kNCMBErrorInvalidFormat = @"E400004";
NSString const *kNCMBErrorNotEfficientValue =@"E400005";
NSString const *kNCMBErrorMissingValue = @"E400006";
NSString const *kNCMBErrorNotCoexistValue = @"E400008";
NSString const *kNCMBErrorDigitTooLarge = @"E400009";


NSString const *kNCMBErrorInvalidAuthHeader =@"E401001";
NSString const *kNCMBErrorAuthFailure = @"E401002";
NSString const *kNCMBErrorOAuthFailure = @"E401003";


NSString const *kNCMBErrorOperationForbiddenByACL = @"E403001";
NSString const *kNCMBErrorOperationForbiddenByUserType = @"E403002";
NSString const *kNCMBErrorOperationForbidden = @"E403003";
NSString const *kNCMBErrorExpiredOnetimeKey = @"E403004";
NSString const *kNCMBErrorInvalidSettingName = @"E403005";


NSString const *kNCMBErrorDataNotFound = @"E404001";
NSString const *kNCMBErrorServiceNotFound = @"E404002";
NSString const *kNCMBErrorFieldNotFound = @"E404003";
NSString const *kNCMBErrorDeviceTokenNotFound = @"E404004";
NSString const *kNCMBErrorApplicationNotFound = @"E404005";

NSString const *kNCMBErrorMethodNotAllowed = @"E405001";


NSString const *kNCMBErrorDuplicateValue = @"E409001";


NSString const *kNCMBErrorFileTooLarge = @"E413001";
NSString const *kNCMBErrorEntityTooLarge = @"E413002";
NSString const *kNCMBErrorTooManyOperations = @"E413003";

NSString const *kNCMBErrorUnsupportedMediaType = @"E415001";

NSString const *kNCMBErrorRestricted = @"E429001";


NSString const *kNCMBErrorInternalServerError = @"E500001";


NSString const *kNCMBErrorStorageError = @"E502001";

