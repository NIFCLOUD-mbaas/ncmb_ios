//
//  NCMBSetOperation.m
//  NIFTY Cloud mobile backend
//
//  Created by NIFTY Corporation on 2014/09/04.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import "NCMBSetOperation.h"

@implementation NCMBSetOperation

- (id)initWithClassName:(id)newValue{
    self = [super init];
    if( self ) {
        self.value=newValue;
    }
    return self;
}

-(id)encode{
    return self.value;
}


- (id)getValue{
    return self.value;
}

- (id)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    return self.value;
}

- (id)mergeWithPrevious:(id)previous{
    return self;
}
@end