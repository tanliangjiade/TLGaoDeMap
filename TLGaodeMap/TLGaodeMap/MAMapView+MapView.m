//
//  MAMapView+MapView.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/13.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "MAMapView+MapView.h"

@implementation MAMapView (MapView)
//显示指定区域
- (void)showAppointRegionCoordinate:(CLLocationCoordinate2D)coordinate andSpan:(MACoordinateSpan)span
{
    MACoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    [self setRegion:region animated:YES];
}
//清除大头针
- (void)removeAnnotationsFun
{
    if([self annotations])
    {
        [self removeAnnotations:self.annotations];
    }
}

//清除遮罩
- (void)removeOverlaysFun
{
    if([self overlays])
    {
        [self removeOverlays:self.overlays];
    }
}

//清除大头针和路线
- (void)removeAnnotationsAndOverlays
{
    [self removeAnnotationsFun];
    [self removeOverlaysFun];
}
//添加大头针
- (void)addPointAnnotation:(AMapPOI *)poi;
{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    pointAnnotation.title = poi.name;
//    pointAnnotation.subtitle = poi.address;
    [self addAnnotation:pointAnnotation];
}

@end
