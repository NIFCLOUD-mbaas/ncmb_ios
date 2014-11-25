/*******
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
 **********/

#import "NCMB.h"

#import "NCMBURLConnection.h"

#import "NCMBObject+Private.h"
#import "NCMBObject+Subclass.h"
#import "NCMBRelationOperation.h"

#import "SubClassHandler.h"
#import <objc/runtime.h>

@interface NCMBQuery ()

@property (nonatomic)NSMutableDictionary *query;
@property (nonatomic)NSMutableArray *orderFieldsAry;
@property (nonatomic)NCMBURLConnection *connection;
@property (nonatomic)NSURLRequestCachePolicy cachePolicy;

@end

@implementation NCMBQuery

#pragma mark - init

- (id)init {
    self = [super init];
    if (self){
        _query = [NSMutableDictionary dictionary];
        _orderFieldsAry = [NSMutableArray array];
        _includeKey = nil;
        _cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }
    return self;
}

- (id)initWithClassName:(NSString*)className{
    self = [self init];
    if (self){
        _ncmbClassName = className;
        _query = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 クラス名を指定してクエリを作成する
 @param className 指定するクラス名
 */
+ (NCMBQuery*)queryWithClassName:(NSString*)className{
    return [[NCMBQuery alloc] initWithClassName:className];
}

#pragma mark - description

- (NSString*)description{
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:_query
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

#pragma mark - Query configuration

/**
 「親クエリに指定したキーの値の中から指定したオブジェクト(第二引数)と等しいものを検索する」という検索条件を設定
 @param key 検索条件に使用するキー
 @param object 検索条件に使用する値
 */
- (void)whereKey:(NSString*)key equalTo:(id)object{
    [_query setObject:[self convertToJSONFromNCMBObject:object] forKey:key];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object{
    [_query setObject:@{@"$ne":object} forKey:key];
}

/**
 「親クエリに指定したキーの値の中から指定したオブジェクト(第二引数)の値より大きいものを検索」という検索条件を設定
 @param key 検索条件に使用するキー
 @param object 検索条件に使用する値
 */
- (void)whereKey:(NSString *)key greaterThan:(id)object{
    [_query setObject:@{@"$gt":[self convertToJSONFromNCMBObject:object]} forKey:key];
}

/**
 「親クエリに指定したキーの値の中から指定したオブジェクト(第二引数)の値以上を検索」という検索条件を設定
 @param key 検索条件に使用するキー
 @param object 検索条件に使用する値
 */
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object{
    [_query setObject:@{@"$gte":[self convertToJSONFromNCMBObject:object]} forKey:key];
}

/**
 「親クエリに指定したキーの値の中から指定したオブジェクト(第二引数)より小さいものを検索」という検索条件を設定
 @param key 検索条件に使用するキー
 @param object 検索条件に使用する値
 */
- (void)whereKey:(NSString *)key lessThan:(id)object{
    [_query setObject:@{@"$lt":[self convertToJSONFromNCMBObject:object]} forKey:key];
}

/**
 「親クエリに指定したキーの値の中から指定したオブジェクト(第二引数)以下を検索」という検索条件を設定
 @param key 検索条件に使用するキー
 @param object 検索条件に使用する値
 */
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object{
    [_query setObject:@{@"$lte":[self convertToJSONFromNCMBObject:object]} forKey:key];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array{
    [_query setObject:@{@"$in":[self convertToJSONFromNCMBObject:array]} forKey:key];
}

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array{
    [_query setObject:@{@"$nin":[self convertToJSONFromNCMBObject:array]} forKey:key];
}

- (void)whereKey:(NSString *)key containedInArray:(NSArray *)array{
    [_query setObject:@{@"$inArray":[self convertToJSONFromNCMBObject:array]} forKey:key];
}

- (void)whereKey:(NSString *)key notContainedInArray:(NSArray *)array{
    [_query setObject:@{@"$ninArray":[self convertToJSONFromNCMBObject:array]} forKey:key];
}

- (void)whereKey:(NSString *)key containsAllObjectsInArray:(NSArray *)array{
    [_query setObject:@{@"$all":[self convertToJSONFromNCMBObject:array]} forKey:key];
}

- (void)whereKey:(NSString *)key matchesKey:(NSString *)otherKey inQuery:(NCMBQuery *)query{
    [_query setObject:@{@"$select":@{@"query":[self convertToJSONFromNCMBObject:query],@"key":otherKey}} forKey:key];
}

- (void)whereKey:(NSString *)key matchesQuery:(NCMBQuery *)query{
    [_query setObject:@{@"$inQuery":[self convertToJSONFromNCMBObject:query]} forKey:key];
}

- (void)whereKeyExists:(NSString *)key{
    [_query setObject:@{@"$exists":[NSNumber numberWithBool:YES]} forKey:key];
}

- (void)whereKeyDoesNotExist:(NSString *)key{
    [_query setObject:@{@"$exists":[NSNumber numberWithBool:NO]} forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(NCMBGeoPoint *)geoPoint{
    [_query setObject:@{@"$nearSphere":[self convertToJSONFromNCMBObject:geoPoint]}
               forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(NCMBGeoPoint *)geoPoint withinKilometers:(double)maxDistance{
    [_query setObject:@{@"$nearSphere":[self convertToJSONFromNCMBObject:geoPoint],
                        @"$maxDistanceInKilometers":[NSNumber numberWithDouble:maxDistance]}
               forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(NCMBGeoPoint *)geoPoint withinMiles:(double)maxDistance{
    [_query setObject:@{@"$nearSphere":[self convertToJSONFromNCMBObject:geoPoint],
                        @"$maxDistanceInMiles":[NSNumber numberWithDouble:maxDistance]}
               forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(NCMBGeoPoint *)geoPoint withinRadians:(double)maxDistance{
    [_query setObject:@{@"$nearSphere":[self convertToJSONFromNCMBObject:geoPoint],
                        @"$maxDistanceInRadians":[NSNumber numberWithDouble:maxDistance]}
               forKey:key];
}

- (void)whereKey:(NSString *)key
withinGeoBoxFromSouthwest:(NCMBGeoPoint *)southwest
     toNortheast:(NCMBGeoPoint *)northeast{
    [_query setObject:@{@"$within":@{@"$box":@[[self convertToJSONFromNCMBObject:southwest],
                                               [self convertToJSONFromNCMBObject:northeast]
                                               ]
                                     }
                        }
               forKey:key];
}

+(NCMBQuery*)orQueryWithSubqueries:(NSArray *)queries{
    NSString *className = @"";
    NSMutableArray *jsonQueries = [NSMutableArray array];
    for (NCMBQuery *aQuery in [queries objectEnumerator]){
        if ([className isEqualToString:@""]){
            className = aQuery.ncmbClassName;
            [jsonQueries addObject:[aQuery convertToJSONFromNCMBObject:aQuery.query]];
        } else {
            if (![className isEqualToString:aQuery.ncmbClassName]){
                //@throw @"Sub queries className must be same.";
                return nil;
            }
            [jsonQueries addObject:[aQuery convertToJSONFromNCMBObject:aQuery.query]];
        }
    }
    NCMBQuery *query = [NCMBQuery queryWithClassName:className];
    [query.query setObject:jsonQueries forKey:@"$or"];
    
    return query;
}


- (void)relatedTo:(NSString*)targetClassName objectId:(NSString*)objectId key:(NSString*)key{
    [_query setObject:@{@"object":@{@"__type":@"Pointer",
                                    @"className":targetClassName,
                                    @"objectId":objectId,
                                    },
                        @"key":key}
               forKey:@"$relatedTo"];
}

- (void)includeKey:(NSString *)key{
    self.includeKey = key;
}


#pragma mark - Order

//昇順
- (void)orderByAscending:(NSString *)key{
    self.orderFieldsAry = [NSMutableArray arrayWithObject:key];
}

//昇順(追加)
- (void)addAscendingOrder:(NSString *)key{
    //初設定の場合
    if(!self.orderFieldsAry){
        self.orderFieldsAry = [NSMutableArray arrayWithCapacity:0];
    }
    //設定追加
    [self.orderFieldsAry addObject:key];
}

//降順
- (void)orderByDescending:(NSString *)key{
    NSString *descendingKey = [NSString stringWithFormat:@"-%@",key];
    self.orderFieldsAry = [NSMutableArray arrayWithObject:descendingKey];
}

//降順(追加)
- (void)addDescendingOrder:(NSString *)key{
    //初設定の場合
    if(!self.orderFieldsAry){
        self.orderFieldsAry = [NSMutableArray arrayWithCapacity:0];
    }
    //設定追加
    NSString *descendingKey = [NSString stringWithFormat:@"-%@",key];
    [self.orderFieldsAry addObject:descendingKey];
}

//SortDescriptorによるソート指定
- (void)orderBySortDescriptor:(NSSortDescriptor *)sortDescriptor{
    NSString *key = sortDescriptor.key;
    BOOL isAscending = sortDescriptor.ascending;
    if(isAscending){
        self.orderFieldsAry = [NSMutableArray arrayWithObject:key];
    }else{
        NSString *descendingKey = [NSString stringWithFormat:@"-%@",key];
        self.orderFieldsAry = [NSMutableArray arrayWithObject:descendingKey];
    }
}

//SortDescriptorによるソート指定
- (void)orderBySortDescriptors:(NSArray *)sortDescriptors{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for(NSSortDescriptor *sortDescriptor in sortDescriptors){
        NSString *key = sortDescriptor.key;
        BOOL isAscending = sortDescriptor.ascending;
        if(isAscending){
            [array addObject:key];
        }else{
            NSString *descendingKey = [NSString stringWithFormat:@"-%@",key];
            [array addObject:descendingKey];
        }
    }
    self.orderFieldsAry = array;
}

#pragma mark - findObject

/**
 指定された条件でオブジェクト検索を実行する。
 @param error エラーを保持するポインタ
 @return 検索結果をNSArray型で返却する
 */
- (NSArray*)findObjects:(NSError**)error{
    //NCMBURLConnectionを用意
    NCMBURLConnection *connect = [self createConnectionForSearch:_query countEnableFlag:NO getFirst:NO];
    
    //同期通信を実行
    NSDictionary *response = [connect syncConnection:error];
    NSMutableArray *results = [NSMutableArray arrayWithArray:[response objectForKey:@"results"]];
    NSMutableArray *objects = [NSMutableArray array];
    for (NSDictionary *jsonObj in [results objectEnumerator]){
        [objects addObject:[NCMBObject convertClass:[NSMutableDictionary dictionaryWithDictionary:jsonObj] ncmbClassName:_ncmbClassName]];
    }
    return objects;
    //return [self convertToNCMBObjectFromJSON:[response objectForKey:@"results"]];
}

- (void)findObjectsInBackgroundWithBlock:(NCMBArrayResultBlock)block{
    _connection = [self createConnectionForSearch:_query countEnableFlag:NO getFirst:NO];
    
    [_connection asyncConnectionWithBlock:^(id response, NSError *error) {
        NSDictionary *responseDic = response;
        NSMutableArray *results = [NSMutableArray arrayWithArray:[responseDic objectForKey:@"results"]];
        NSMutableArray *objects = [NSMutableArray array];
        for (NSDictionary *jsonObj in [results objectEnumerator]){
            [objects addObject:[NCMBObject convertClass:[NSMutableDictionary dictionaryWithDictionary:jsonObj] ncmbClassName:_ncmbClassName]];
        }
        if (block){
            block(objects, error);
        }
    }];
}

- (void)findObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target or selector must not be nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&objects atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

- (NCMBURLConnection*)createConnectionForSearch:queryDic countEnableFlag:(BOOL)countEnableFlag getFirst:(BOOL)getFirstFlag{
    NSDictionary *endpoint = @{@"user":@"users",
                               @"role":@"roles",
                               @"installation":@"installations",
                               @"push":@"push",
                               @"file":@"files"};
    NSMutableString *baseUrl = [NSMutableString string];
    if ([_ncmbClassName isEqualToString:@"user"] || [_ncmbClassName isEqualToString:@"role"] ||
        [_ncmbClassName isEqualToString:@"installation"] || [_ncmbClassName isEqualToString:@"push"] ||
        [_ncmbClassName isEqualToString:@"file"]) {
        baseUrl = [NSMutableString stringWithFormat:@"%@", [endpoint objectForKey:_ncmbClassName]];
    } else {
        baseUrl = [NSMutableString stringWithFormat:@"classes/%@", _ncmbClassName];
    }
    NSArray *queryArray = [self queryToArray:queryDic countEnableFlag:countEnableFlag getFirstFlag:getFirstFlag];
    NSString *queryStr = @"";
    for (int i = 0; i < [queryArray count]; i++){
        if (i == 0){
            queryStr = [NSString stringWithFormat:@"%@",queryArray[i]];
        } else {
            queryStr = [queryStr stringByAppendingString:[NSString stringWithFormat:@"&%@",queryArray[i]]];
        }
    }
    [baseUrl appendString:[NSString stringWithFormat:@"?%@", queryStr]];
    return [[NCMBURLConnection alloc] initWithPath:baseUrl method:@"GET" data:[queryStr dataUsingEncoding:NSUTF8StringEncoding] cachePolicy:_cachePolicy];
}

#pragma mark - getFirstObject

- (id)getFirstObject:(NSError **)error{
    //NCMBURLConnectionを用意
    NCMBURLConnection *connect = [self createConnectionForSearch:_query countEnableFlag:NO getFirst:YES];
    //同期通信を実行
    NSDictionary *response = [connect syncConnection:error];
    NSMutableArray *results = [NSMutableArray arrayWithArray:[response objectForKey:@"results"]];
    //NSMutableDictionary *converted = [NSMutableDictionary dictionary];
    /*
    for (NSString *key in [[results[0] allKeys] objectEnumerator]){
        [converted setObject:[self convertToNCMBObjectFromJSON:[results[0] objectForKey:key] convertKey:key] forKey:key];
    }*/
    id obj = [NCMBObject convertClass:results[0] ncmbClassName:_ncmbClassName];
    return obj;
}



- (void)getFirstObjectInBackgroundWithBlock:(NCMBObjectResultBlock)block{
    //NCMBURLConnectionを用意
    _connection = [self createConnectionForSearch:_query countEnableFlag:NO getFirst:YES];
    
    [_connection asyncConnectionWithBlock:^(id response, NSError *error) {
        NSDictionary *responseDic = response;
        NSMutableArray *results = [NSMutableArray arrayWithArray:[responseDic objectForKey:@"results"]];
        if (block){
            block([NCMBObject convertClass:results[0] ncmbClassName:_ncmbClassName], error);
        }
    }];
}

- (void)getFirstObjectInBackgroundWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target or selector must not nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self getFirstObjectInBackgroundWithBlock:^(NCMBObject *object, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&object atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

#pragma mark - countObject

- (NSInteger)countObjects:(NSError **)error{
    //NCMBURLConnectionを用意
    NCMBURLConnection *connect = [self createConnectionForSearch:_query countEnableFlag:YES getFirst:NO];
    
    //同期通信を実行
    NSDictionary *response = [connect syncConnection:error];
    if ([[response allKeys] containsObject:@"count"]){
        return [[response objectForKey:@"count"] intValue];
    }
    return 0;
}

- (void)countObjectsInBackgroundWithBlock:(NCMBIntegerResultBlock)block{
    //NCMBURLConnectionを用意
    _connection = [self createConnectionForSearch:_query countEnableFlag:YES getFirst:NO];
    
    [_connection asyncConnectionWithBlock:^(id response, NSError *error) {
        NSDictionary *responseDic = response;
        if ([[responseDic allKeys] containsObject:@"count"]){
            block([[response objectForKey:@"count"] intValue], error);
        }
    }];
}

- (void)countObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target or selector must not nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&number atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

#pragma mark - getObjectWithId

-(NCMBObject*)getObjectWithId:(NSString *)objectId error:(NSError **)error{
    NSDictionary *queryDic = @{@"objectId":objectId};
    NCMBURLConnection *connect = [self createConnectionForSearch:queryDic countEnableFlag:NO getFirst:YES];
    
    //同期通信を実行
    NSDictionary *response = [connect syncConnection:error];
    NSMutableArray *results = [NSMutableArray arrayWithArray:[response objectForKey:@"results"]];
    return [NCMBObject objectWithClassName:_ncmbClassName data:results[0]];
}

- (void)getObjectInBackgroundWithId:(NSString *)objectId block:(NCMBObjectResultBlock)block{
    NSDictionary *queryDic = @{@"objectId":objectId};
    _connection = [self createConnectionForSearch:queryDic countEnableFlag:NO getFirst:YES];
    
    [_connection asyncConnectionWithBlock:^(id response, NSError *error) {
        NSDictionary *responseDic = response;
        NSMutableArray *results = [NSMutableArray arrayWithArray:[responseDic objectForKey:@"results"]];
        if (block){
            block([NCMBObject objectWithClassName:_ncmbClassName data:results[0]], error);
        }
    }];
}

- (void)getObjectInBackgroundWithId:(NSString *)objectId target:(id)target selector:(SEL)selector{
    if (!target || !selector){
        [NSException raise:@"NCMBInvalidValueException" format:@"target or selector must not nil."];
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [self getObjectInBackgroundWithId:objectId block:^(NCMBObject *object, NSError *error) {
        [invocation retainArguments];
        [invocation setArgument:&object atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation invoke];
    }];
}

#pragma mark - getObjectWithClass/User

+(NCMBObject*)getObjectOfClass:(NSString *)objectClass objectId:(NSString *)objectId error:(NSError **)error{
    NCMBQuery *query = [NCMBQuery queryWithClassName:objectClass];
    return [query getObjectWithId:objectId error:error];
}

+(NCMBUser*)getUserObjectWithId:(NSString *)objectId error:(NSError **)error{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"user"];
    NCMBObject *userObj = [query getObjectWithId:objectId error:error];
    NCMBUser *user = [NCMBUser user];
    if ([[userObj allKeys] containsObject:@"userName"]){
        user.userName = [userObj objectForKey:@"userName"];
    }
    if ([[userObj allKeys] containsObject:@"mailAddress"]){
        user.mailAddress = [userObj objectForKey:@"mailAddress"];
    }
    return user;
}

#pragma mark - cancel

- (void)cancel{
    [_connection cancel];
    _connection = nil;
}

#pragma mark - Cache Configuration

/**
 データ検索時のcachePolicyを設定する
 */
- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy{
    _cachePolicy = cachePolicy;
}

+(void)clearAllCachedResults{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)clearCachedResult{
    NCMBURLConnection *connection = [self createConnectionForSearch:_query countEnableFlag:NO getFirst:NO];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:connection.request];
}

-(BOOL)hasCachedResult{
    BOOL result = NO;
    NCMBURLConnection *connection = [self createConnectionForSearch:_query countEnableFlag:NO getFirst:NO];
    if([[NSURLCache sharedURLCache] cachedResponseForRequest:connection.request] != nil){
        result = YES;
    }
    return result;
}



#pragma mark - utility

/**
 クエリの内容を配列で返却する
 @param queryDic 配列に変換するクエリが格納されたNSDictionary
 @param countEnableFlag YESが指定されている場合にカウントを行う
 @param getFirstFlag YESが指定されている場合にlimit=1を指定する
 */
- (NSArray*)queryToArray:(NSDictionary*)queryDic countEnableFlag:(BOOL)countEnableFlag getFirstFlag:(BOOL)getFirstFlag{
    //queryStrを作成する
    NSMutableArray *queryArray = [NSMutableArray array];
    
    NSMutableDictionary *jsonDic = [self convertToJSONFromNCMBObject:queryDic];
    NSError *convertError = nil;
    if ([jsonDic count] != 0){
        NSData *json = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:&convertError];
        if (convertError){
            return nil;
        }
        NSString *jsonParamStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        [queryArray addObject:[NSString stringWithFormat:@"where=%@", jsonParamStr]];
    }
    if ([_orderFieldsAry count] != 0){
        NSMutableString *orderStr = [NSMutableString stringWithString:@"order="];
        for (int i = 0; i < [_orderFieldsAry count]; i++){
            if (i == 0){
                [orderStr appendString:_orderFieldsAry[i]];
            } else {
                [orderStr appendFormat:@",%@", _orderFieldsAry[i]];
            }
        }
        [queryArray addObject:orderStr];
    }
    if (countEnableFlag == YES || getFirstFlag == YES){
        [queryArray addObject:[NSString stringWithFormat:@"limit=%d", 1]];
    } else if (_limit > 0) {
        [queryArray addObject:[NSString stringWithFormat:@"limit=%d", _limit]];
    }
    if (_skip > 0){
        [queryArray addObject:[NSString stringWithFormat:@"skip=%d", _skip]];
    }
    if (_includeKey != nil){
        [queryArray addObject:[NSString stringWithFormat:@"include=%@", _includeKey]];
    }
    if (countEnableFlag){
        [queryArray addObject:@"count=1"];
    }
    if (convertError){
        return nil;
    }
    return [queryArray sortedArrayUsingSelector:@selector(compare:)];
}

/**
 NCMB形式の日付型NSDateFormatterオブジェクトを返す
 */
-(NSDateFormatter*)createNCMBDateFormatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //和暦表示と12時間表示対策
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    return dateFormatter;
}

/**
 NCMBObjectをJSONに変換する
 @param obj NCMBオブジェクト
 */
- (id)convertToJSONFromNCMBObject:(id)obj{
    if (obj == NULL){
        //objがNULLだったら
        return [NSNull null];
    } else if ([obj isKindOfClass:[NSDate class]]){
        //objが日付型だったら
        NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];
        [jsonObj setObject:@"Date" forKey:@"__type"];
        NSDateFormatter *dateFormatter = [self createNCMBDateFormatter];
        NSString *dateStr = [dateFormatter stringFromDate:obj];
        [jsonObj setObject:dateStr forKey:@"iso"];
        return jsonObj;
    } else if ([obj isKindOfClass:[NCMBGeoPoint class]]){
        //objが位置情報だったら
        NCMBGeoPoint *geoPoint = obj;
        NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];
        [jsonObj setObject:@"GeoPoint" forKey:@"__type"];
        [jsonObj setObject:[NSNumber numberWithDouble:geoPoint.latitude] forKey:@"latitude"];
        [jsonObj setObject:[NSNumber numberWithDouble:geoPoint.longitude] forKey:@"longitude"];
        return jsonObj;
        
    } else if ([obj isKindOfClass:[NCMBObject class]]){
        //objがポインタだったら
        NCMBObject *ncmbObj = obj;
        NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];
        [jsonObj setObject:@"Pointer" forKey:@"__type"];
        [jsonObj setObject:[ncmbObj ncmbClassName] forKey:@"className"];
        [jsonObj setObject:[ncmbObj objectId] forKey:@"objectId"];
        return jsonObj;
        
    } else if ([obj isKindOfClass:[NCMBRelation class]]){
        //objがリレーションだったら
        NCMBRelation *relation = obj;
        NCMBObject *parentObj = relation.parent;
        id convertObj = [self convertToJSONDicFromOperation:[parentObj currentOperations]];
        return convertObj;
        
    } else if ([obj isKindOfClass:[NCMBACL class]]){
        //objがACLだったら
        NCMBACL *acl = obj;
        if ([[acl dicACL] count] == 0){
            return [NSNull null];
        } else {
            return [acl dicACL];
        }
    } else if ([obj isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];
        //objがNSDictionaryだったら再帰呼び出し
        for (id Key in [obj keyEnumerator]){
            id convertedObj = [self convertToJSONFromNCMBObject:[obj objectForKey:Key]];
            [jsonObj setObject:convertedObj forKey:Key];
        }
        return jsonObj;
    } else if ([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [NSMutableArray array];//[NSMutableArray arrayWithObject:obj];
        for (int i = 0; i < [obj count]; i++){
            //objがNSArrayだったら再帰呼び出し
            array[i] = [self convertToJSONFromNCMBObject:obj[i]];
        }
        return array;
    } else if ([obj isKindOfClass:[NSSet class]]){
        NSMutableSet *currentSet = [NSMutableSet setWithObject:obj];
        NSMutableSet *set = [NSMutableSet set];
        for (id value in [currentSet objectEnumerator]){
            //objがNSSetだったら再帰呼び出し
            [set addObject:[self convertToJSONFromNCMBObject:value]];
        }
        return set;
        
    } else if ([obj isKindOfClass:[NCMBQuery class]]){
        NCMBQuery *query = (NCMBQuery*)obj;
        NSMutableDictionary *jsonQuery = [NSMutableDictionary dictionary];
        NSMutableDictionary *subQuery = [NSMutableDictionary dictionary];
        for (NSString *queryKey in [[query.query allKeys] objectEnumerator]){
            //セットされたサブクエリの内容をすべてJSONに変換
            [subQuery setObject:[self convertToJSONFromNCMBObject:[query.query objectForKey:queryKey]]
                        forKey:queryKey];
        }
        [jsonQuery setObject:subQuery forKey:@"where"];
        [jsonQuery setObject:query.ncmbClassName forKey:@"className"];
        if (query.limit > 0){
            [jsonQuery setObject:[NSNumber numberWithInt:query.limit] forKey:@"limit"];
        }
        if (query.skip > 0){
            [jsonQuery setObject:[NSNumber numberWithInt:query.skip] forKey:@"skip"];
        }
        return jsonQuery;
    }
    //その他の型(文字列、数値、真偽値)はそのまま返却
    return obj;
}

/**
 操作履歴からDictionary作成
 @param operations オブジェクトの操作履歴を保持するNSMutableDictionaryオブジェクト
 */
-(NSMutableDictionary *)convertToJSONDicFromOperation:(NSMutableDictionary*)operations{
    
    NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc]init];
    for (id key in [operations keyEnumerator]) {
        //各操作をREST APIの形式に変換してセットする
        [jsonDic setObject:[[operations valueForKey:key] encode] forKey:key];
    }
    return jsonDic;
}

/**
 JSONオブジェクトをNCMBObjectに変換する
 @param jsonData JSON形式のデータ
 */
- (id)convertToNCMBObjectFromJSON:(id)jsonData convertKey:(NSString *)convertKey{
    if (jsonData == NULL){
        //objがNULLだったら
        return nil;
    } else if ([jsonData isKindOfClass:[NSDictionary class]]){
        if ([jsonData objectForKey:@"__type"]){
            NSString *typeStr = [jsonData objectForKey:@"__type"];
            if ([typeStr isEqualToString:@"Date"]){
                //objが日付型だったら
                NSString *iso = [jsonData objectForKey:@"iso"];
                NSDateFormatter *dateFormatter = [self createNCMBDateFormatter];
                NSDate *date = [dateFormatter dateFromString:iso];
                return date;
            } else if ([typeStr isEqualToString:@"GeoPoint"]){
                //objが位置情報だったら
                NCMBGeoPoint *geoPoint = [[NCMBGeoPoint alloc] init];
                geoPoint.latitude = [[jsonData objectForKey:@"latitude"] doubleValue];
                geoPoint.longitude = [[jsonData objectForKey:@"longitude"] doubleValue];
                return geoPoint;
            } else if ([typeStr isEqualToString:@"Pointer"]){
                //objがポインタだったら
                id obj = [NCMBObject convertClass:jsonData
                              ncmbClassName:[jsonData objectForKey:@"className"]];
                
                /*
                NCMBObject *obj = [NCMBObject objectWithClassName:[jsonData objectForKey:@"className"]
                                                         objectId:[jsonData objectForKey:@"objectId"]];
                 */
                return obj;
            } else if ([typeStr isEqualToString:@"Relation"]){
                //objがリレーションだったら
                NCMBRelation *relation = [[NCMBRelation alloc] initWithClassName:self key:convertKey];
                relation.targetClass = [jsonData objectForKey:@"className"];
                //NCMBRelation *relation = [[NCMBRelation alloc] initWithClassName:[jsonData objectForKey:@"className"]];
                return relation;
            } else if ([typeStr isEqualToString:@"Object"]){
                id obj = [NCMBObject convertClass:jsonData ncmbClassName:[jsonData objectForKey:@"className"]];
                return obj;
            }
        } else if ([jsonData objectForKey:@"acl"]){
            //objがACLだったら
            NCMBACL *acl = [[NCMBACL alloc] init];
            acl.dicACL = [jsonData objectForKey:@"acl"];
            return acl;
        } else {
            //objがNSDictionaryだったら再帰呼び出し
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (NSString *key in [jsonData keyEnumerator]){
                id convertedObj = [self convertToNCMBObjectFromJSON:[jsonData objectForKey:key] convertKey:key];
                [dic setObject:convertedObj forKey:key];
            }
            return dic;
        }
    } else if ([jsonData isKindOfClass:[NSArray class]]){
        //NSMutableArray *jsonArray = [NSMutableArray arrayWithObject:jsonData];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [jsonData count]; i++){
            //objがNSArrayだったら再帰呼び出し
            array[i] = [self convertToNCMBObjectFromJSON:jsonData[i] convertKey:nil];
        }
        return array;
    } else if ([jsonData isKindOfClass:[NSSet class]]){
        NSMutableSet *currentSet = [NSMutableSet setWithObject:jsonData];
        NSMutableSet *set = [NSMutableSet set];
        for (id value in [currentSet objectEnumerator]){
            //objがNSSetだったら再帰呼び出し
            [set addObject:[self convertToNCMBObjectFromJSON:value convertKey:nil]];
        }
        return set;
        
    }
    //その他の型(文字列、数値、真偽値)はそのまま返却
    return jsonData;
}

- (NSDictionary*)getQueryDictionary{
    return _query;
}

@end
