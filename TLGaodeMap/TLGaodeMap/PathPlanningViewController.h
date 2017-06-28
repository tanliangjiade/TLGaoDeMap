//
//  PathPlanningViewController.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/19.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@interface PathPlanningViewController : UIViewController
/**
    属性接收终点值
 */
@property(nonatomic) CLLocationCoordinate2D endPoint;
@property(nonatomic) CLLocationCoordinate2D currentPoint;

@property (nonatomic, copy)   AMapGeoPoint *locations;

@property (nonatomic, copy)   AMapGeoPoint *loca;
@end
