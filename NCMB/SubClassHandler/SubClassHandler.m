/*
 Copyright 2017-2018 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **********/

#import "SubClassHandler.h"

@interface SubClassHandler()
@property (strong ,nonatomic) NSMutableDictionary *dicSubclass;

@end

@implementation SubClassHandler
static SubClassHandler *subClassHandler= nil;

#pragma mark - 取得

-(NSString *)className:(NSString *)ncmbClassName{
    return [self.dicSubclass objectForKey:ncmbClassName];
}
#pragma mark - 登録

-(void)setSubClassName:(NSString *)className ncmbClassName:(NSString *)ncmbClassName{
    [self.dicSubclass setObject:className forKey:ncmbClassName];
}

#pragma mark = init

-(id)init{
    if((self = [super init])){
        self.dicSubclass = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - shared

+(SubClassHandler*)sharedInstance{
    if(!subClassHandler) subClassHandler = [[SubClassHandler alloc] init];
    return subClassHandler;
}

@end
