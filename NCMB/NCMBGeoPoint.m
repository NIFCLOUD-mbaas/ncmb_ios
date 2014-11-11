//
//  NCMBGeoPoint.m
//  NCMB
//
//  Created by SCI01433 on 2014/10/01.
//  Copyright (c) 2014年 NIFTY Corporation. All rights reserved.
//

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
    
    NSLog(@"before geoPointForCurrentLocation");
    //dispatch_queue_t sub = dispatch_queue_create("geoPointForCurrentLocationInBackground", NULL);
    
    //dispatch_async(sub, ^{
        
    if([CLLocationManager locationServicesEnabled]){
        NSLog(@"LocationService is enable...");
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = currentPoint;
        // 測位開始
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"LocationService is disable...");
    }
    //});
    //dispatch_release(sub);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"didUpdateLocations");
    CLLocation *location = locations[0];
    currentPoint.latitude = location.coordinate.latitude;
    currentPoint.longitude = location.coordinate.longitude;
    [locationManager stopUpdatingLocation];
    handler(currentPoint, nil);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
    [locationManager stopUpdatingLocation];
    handler(currentPoint, error);
}

@end
