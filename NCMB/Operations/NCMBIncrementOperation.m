/*
 Copyright 2017-2020 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import "NCMBIncrementOperation.h"
#import "NCMBDeleteOperation.h"
#import "NCMBSetOperation.h"

@implementation NCMBIncrementOperation

- (NCMBIncrementOperation *)initWithClassName:(NSNumber *)newAmount{
    self = [super init];
    if( self ) {
        self.amount = newAmount;
    }
    return self;
}

-(NSMutableDictionary *)encode{
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [json setObject:@"Increment" forKey:@"__op"];
    [json setObject:self.amount forKey:@"amount"];
    return json;
}

-(NSNumber *)apply:(id)oldValue NCMBObject:(id)object forkey:(NSString *)key{
    
    if(oldValue == nil){
        return self.amount;
    }
    
    if([oldValue isKindOfClass:[NSNumber class]]){
        float newValue = [oldValue floatValue] + [self.amount floatValue];
        return [NSNumber numberWithFloat:newValue];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You cannot increment a non-number." userInfo:nil] raise];
    return nil;
}



- (id)mergeWithPrevious:(id)previous{
    
    if (previous==nil) {
        return self;
    }
    
    
    if ([previous isKindOfClass:[NCMBDeleteOperation class]]) {
        return [[NCMBSetOperation alloc]initWithClassName:self.amount];
    }
    
    
    if ([previous isKindOfClass:[NCMBSetOperation class]]) {
        id oldValue = [((NCMBSetOperation *)previous) getValue];
        
        if ([oldValue isKindOfClass:[NSNumber class]]) {
            float newValue = [oldValue floatValue] + [self.amount floatValue];
            return [[NCMBSetOperation alloc] initWithClassName:[NSNumber numberWithFloat:newValue]];
        }
        
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"You cannot increment a non-number." userInfo:nil] raise];
    }
    
    if ([previous isKindOfClass:[NCMBIncrementOperation class]]) {
        NSNumber *oldAmount = ((NCMBIncrementOperation *)previous).amount;
        float newValue = [oldAmount floatValue] + [self.amount floatValue];
        return [[NCMBIncrementOperation alloc] initWithClassName:[NSNumber numberWithFloat:newValue]];
    }
    
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Operation is invalid after previous operation." userInfo:nil] raise];
    return nil;
}


@end
