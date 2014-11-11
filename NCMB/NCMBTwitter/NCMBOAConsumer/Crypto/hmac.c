//
//  hmac.c
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/10/31.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//
/*
 * Implementation of HMAC-SHA1. Adapted from example at http://tools.ietf.org/html/rfc2104
 
 */

#include "sha1.h"

#include <stdlib.h>
#include <string.h>

void hmac_sha1(const u_int8_t *inText, size_t inTextLength, u_int8_t* inKey, size_t inKeyLength, u_int8_t *outDigest)
{
#define B 64
#define L 20
    
    SHA1_CTX theSHA1Context;
    u_int8_t k_ipad[B + 1]; /* inner padding - key XORd with ipad */
    u_int8_t k_opad[B + 1]; /* outer padding - key XORd with opad */
    
    /* if key is longer than 64 bytes reset it to key=SHA1 (key) */
    if (inKeyLength > B)
	{
        SHA1Init(&theSHA1Context);
        SHA1Update(&theSHA1Context, inKey, (u_int32_t)inKeyLength);
        SHA1Final(inKey, &theSHA1Context);
        inKeyLength = L;
	}
    
    /* start out by storing key in pads */
    memset(k_ipad, 0, sizeof k_ipad);
    memset(k_opad, 0, sizeof k_opad);
    memcpy(k_ipad, inKey, inKeyLength);
    memcpy(k_opad, inKey, inKeyLength);
    
    /* XOR key with ipad and opad values */
    int i;
    for (i = 0; i < B; i++)
	{
        k_ipad[i] ^= 0x36;
        k_opad[i] ^= 0x5c;
	}
	
    /*
     * perform inner SHA1
     */
    SHA1Init(&theSHA1Context);                 /* init context for 1st pass */
    SHA1Update(&theSHA1Context, k_ipad, B);     /* start with inner pad */
    SHA1Update(&theSHA1Context, (u_int8_t *)inText, (u_int32_t)inTextLength); /* then text of datagram */
    SHA1Final((u_int8_t *)outDigest, &theSHA1Context);                /* finish up 1st pass */
    
    /*
     * perform outer SHA1
     */
    SHA1Init(&theSHA1Context);                   /* init context for 2nd
                                                  * pass */
    SHA1Update(&theSHA1Context, k_opad, B);     /* start with outer pad */
    SHA1Update(&theSHA1Context, (u_int8_t *)outDigest, L);     /* then results of 1st
                                                                * hash */
    SHA1Final((u_int8_t *)outDigest, &theSHA1Context);          /* finish up 2nd pass */
    
}