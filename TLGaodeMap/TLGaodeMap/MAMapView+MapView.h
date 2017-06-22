//
//  MAMapView+MapView.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/13.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@interface MAMapView (MapView)
//显示指定区域
- (void)showAppointRegionCoordinate:(CLLocationCoordinate2D)coordinate andSpan:(MACoordinateSpan)span;
//清除大头针
- (void)removeAnnotationsFun;
//清除遮罩
- (void)removeOverlaysFun;
//清除大头针和路线
- (void)removeAnnotationsAndOverlays;
//添加大头针
- (void)addPointAnnotation:(AMapPOI *)poi;
@end
