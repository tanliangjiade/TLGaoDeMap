//
//  ViewController.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/6.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@interface ViewController : UIViewController<MAMapViewDelegate,AMapSearchDelegate>

@property(nonatomic,strong) MAMapView* mapView;        // 地图视图

@property(nonatomic,strong) NSMutableArray* searchList;// 搜索列表数组

@property(nonatomic, strong) AMapSearchAPI * searchAPI;// 搜索API

@property(nonatomic, strong) UISearchController * search;//搜索框
@end

