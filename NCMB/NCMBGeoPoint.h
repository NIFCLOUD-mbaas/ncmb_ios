//
//  NCMBGeoPoint.h
//  NCMB
//
//  Created by SCI01433 on 2014/10/01.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NCMBGeoPoint : NSObject <CLLocationManagerDelegate>

/// 緯度
@property (nonatomic, readwrite) double latitude;

/// 経度
@property (nonatomic, readwrite) double longitude;

typedef void (^NCMBGeoPointHandler)(NCMBGeoPoint *geoPoint, NSError *error);

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には0.0が設定される。
 @return geoPoint NCMBGeoPointクラスのインスタンス
 */
+ (NCMBGeoPoint *)geoPoint;

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には引数で指定したものが設定される。
 @param double latitude 緯度
 @param double longitude 軽度
 @return geoPoint NCMBGeoPointクラスのインスタンス
 */
+ (NCMBGeoPoint*)geoPointWithLatitude:(double)latitude longitude:(double)longitude;

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には引数のCLLocationが示す値が設定される。
 @param location 位置情報
 */
+ (NCMBGeoPoint *)geoPointWithLocation:(CLLocation *) location;

/**
 NCMBGeoPointオブジェクトを非同期で作成。緯度、経度にはGPS等で取得した端末の現在位置が設定される。
 @param geoPointHandler geoPointとerrorのHandler
 */
+ (void)geoPointForCurrentLocationInBackground:(NCMBGeoPointHandler)geoPointHandler;


@end
