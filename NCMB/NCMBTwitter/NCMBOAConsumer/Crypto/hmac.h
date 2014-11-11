//
//  hmac.h
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#ifndef HMAC_H
#define HMAC_H 1

extern void hmac_sha1(const u_int8_t *inText, size_t inTextLength, u_int8_t* inKey, const size_t inKeyLength, u_int8_t *outDigest);

#endif /* HMAC_H */