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

#import "NCMBGeoPoint.h"

static NCMBGeoPoint *currentPoint;
static NCMBGeoPointHandler handler;
static CLLocationManager *locationManager;

@implementation NCMBGeoPoint

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には0.0が設定される。
 @return geoPoint NCMBGeoPointクラスのインスタンス
 */
+ (NCMBGeoPoint *)geoPoint{
    return [NCMBGeoPoint geoPointWithLatitude:0 longitude:0];
}

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には引数で指定したものが設定される。
 @param double latitude 緯度
 @param double longitude 軽度
 @return geoPoint NCMBGeoPointクラスのインスタンス
 */
+ (NCMBGeoPoint*)geoPointWithLatitude:(double)latitude longitude:(double)longitude{
    NCMBGeoPoint *geoPoint = [[NCMBGeoPoint alloc] init];
    geoPoint.latitude = latitude;
    geoPoint.longitude = longitude;
    return geoPoint;
}

/**
 NCMBGeoPointオブジェクトを作成。緯度、経度には引数のCLLocationが示す値が設定される。
 @param location 位置情報
 @return NCMBGeoPointのインスタンス
 */
+ (NCMBGeoPoint *)geoPointWithLocation:(CLLocation *) location{
    CLLocationCoordinate2D coordinate = location.coordinate;
    return [NCMBGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}


/**
 NCMBGeoPointオブジェクトを非同期で作成。緯度、経度にはGPS等で取得した端末の現在位置が設定される。
 @param geoPointHandler geoPointとerrorのHandler
 */
+ (void)geoPointForCurrentLocationInBackground:(NCMBGeoPointHandler)geoPointHandler{
    
    currentPoint = [NCMBGeoPoint geoPoint];
    handler = geoPointHandler;
    locationManager = [[CLLocationManager alloc] init];
        
    if([CLLocationManager locationServicesEnabled]){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = currentPoint;
        // 測位開始
        [locationManager startUpdatingLocation];
    }
}

//iOS5.x
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    currentPoint.latitude = newLocation.coordinate.latitude;
    currentPoint.longitude = newLocation.coordinate.longitude;
    [locationManager stopUpdatingLocation];
    handler(currentPoint, nil);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = locations[0];
    currentPoint.latitude = location.coordinate.latitude;
    currentPoint.longitude = location.coordinate.longitude;
    [locationManager stopUpdatingLocation];
    handler(currentPoint, nil);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [locationManager stopUpdatingLocation];
    handler(currentPoint, error);
}

@end
