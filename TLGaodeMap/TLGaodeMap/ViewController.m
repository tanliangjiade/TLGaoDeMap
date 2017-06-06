//
//  ViewController.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/6.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "ViewController.h"
#import <AMapLocationKit/AMapLocationKit.h>     // 导入头文件
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <Masonry.h>
@interface ViewController ()<AMapLocationManagerDelegate>
// 初始化AMapLocationManager对象,设置代理。
@property(nonatomic,strong) AMapLocationManager* locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc] initWithTitle:@"切换校区" style:UIBarButtonItemStylePlain target:self action:@selector(showView)];
    self.navigationItem.leftBarButtonItem=leftItem;
    // 0.初始化地图视图
    self.mapView = [[MAMapView alloc]init];
    [self.view addSubview:_mapView];
    self.mapView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    // 显示用户位置
    self.mapView.showsUserLocation=YES;
    // 显示室内地图
    self.mapView.showsIndoorMap=YES;
    self.mapView.delegate=self;
    self.definesPresentationContext=YES;
    // 初始化AMapLocationManager对象,设置代理。
    self.locationManager = [[AMapLocationManager alloc]init];
    self.locationManager.delegate=self;
    //1.设置期望定位精度
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    // 定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout = 2;
    // 逆地理请求请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 2;
    //2.请求定位并拿到结果
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
    }];
    // 调用AMaplocationManager提供的startUpdatingLocation方法开启持续定位。
//    [self.locationManager startUpdatingLocation];
    
}
// 接收位置更新,实现AMapLocationManagerDelegate代理的amaplocationManager:didUpdateLocation方法,处理位置更新
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    if (reGeocode)
    {
        NSLog(@"reGeocode:%@", reGeocode);
    }
}
//- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
//{
//    
//}
#pragma mark leftBarButton 点击事件方法
- (void)showView
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
