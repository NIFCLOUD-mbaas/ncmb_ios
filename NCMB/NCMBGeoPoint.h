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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 NCMBGeoPointクラスは、位置情報をmobile backendで管理するためのクラスです。
 */
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
 @param latitude 緯度
 @param longitude 軽度
 @return geoPoint NCMBGeoPointクラスのインスタンス
 */
+ (NCMBGeoPoint*)geoPointWithLatitude:(double)latitude longitude:(double)longitude;

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には引数のCLLocationが示す値が設定される。
 @param location CCLocation型の位置情報
 @return NCMBGeoPoint型のインスタンス
 */
+ (NCMBGeoPoint *)geoPointWithLocation:(CLLocation *) location;

/**
 NCMBGeoPointオブジェクトを非同期で作成。緯度、経度にはGPS等で取得した端末の現在位置が設定される。
 @param geoPointHandler geoPointとerrorのHandler
 */
+ (void)geoPointForCurrentLocationInBackground:(NCMBGeoPointHandler)geoPointHandler;


@end
