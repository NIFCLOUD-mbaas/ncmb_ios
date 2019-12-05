/*
 Copyright 2017-2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "NCMBError.h"


NSString * const kNCMBErrorDomain = @"com.nifcloud.mbaas";

NSInteger const NCMBErrorFacebookLoginCancelled = 401004;

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

