/*
 Copyright 2014 NIFTY Corporation All Rights Reserved.
 
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
    if (self.value != nil){
        return self.value;
    } else {
        return [NSNull null];
    }
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
