//
//  PathPlanningViewController.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/19.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "PathPlanningViewController.h"
#import <Masonry.h>
#import <MAMapKit/MAMapKit.h>
@interface PathPlanningViewController ()<MAMapViewDelegate>
@property(nonatomic,strong) MAMapView* mapView; // 地图视图
@end

@implementation PathPlanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化导航栏
    [self initNavi];
    // 初始化视图
    [self initView];
}
#pragma mark - 初始化视图
- (void)initView
{
    // 0.初始化地图视图
    self.mapView = [[MAMapView alloc]init];
    self.mapView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [AMapServices sharedServices].enableHTTPS = YES;
    //self.mapView.frame = self.view.bounds;
    // 添加地图视图到当前View中
    [self.view addSubview:_mapView];
    // 指定代理
    self.mapView.delegate=self;
    // 显示用户位置
    self.mapView.showsUserLocation=YES;
    // 设置地图的缩放级别 范围3-19
    [self.mapView setZoomLevel:13 animated:YES];//17.5
    // ✨设置此 用户跟踪模式 属性地图正常铺开显示
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;// MAUserTrackingModeFollow 1
    // 隐藏比例尺
    self.mapView.showsScale= NO;
    // 添加变焦显示器视图
    UIView* zoomPannelView = [self makeZoomPannelView];
    zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10, self.view.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    zoomPannelView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:zoomPannelView];

}
#pragma mark - 变焦显示器视图
- (UIView *)makeZoomPannelView
{
    UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 53, 98)];
    UIButton *incBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 49)];
    [incBtn setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
    [incBtn sizeToFit];
    [incBtn addTarget:self action:@selector(zoomPlusAction) forControlEvents:UIControlEventTouchUpInside];
    UIButton *decBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 49, 53, 49)];
    [decBtn setImage:[UIImage imageNamed:@"decrease"] forState:UIControlStateNormal];
    [decBtn sizeToFit];
    [decBtn addTarget:self action:@selector(zoomMinusAction) forControlEvents:UIControlEventTouchUpInside];
    [ret addSubview:incBtn];
    [ret addSubview:decBtn];
    return ret;
}
#pragma mark - Action Handlers
- (void)zoomPlusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom + 1) animated:YES];
}
- (void)zoomMinusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom - 1) animated:YES];
}
#pragma mark - 初始化导航栏
- (void)initNavi
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    UIView* baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,200,44)];
    
    UIButton* centerBtn = [[UIButton alloc] init];
    [baseView addSubview:centerBtn];
    [centerBtn setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
    [centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(baseView.mas_centerX);
        make.centerY.equalTo(baseView.mas_centerY);
    }];
    UIButton* leftBtn = [[UIButton alloc] init];
    [baseView addSubview:leftBtn];
    [leftBtn setImage:[UIImage imageNamed:@"walk"] forState:UIControlStateNormal];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(baseView.mas_centerY);
        make.right.equalTo(centerBtn.mas_left).offset(-30);
    }];
    
    UIButton* rightBtn = [[UIButton alloc] init];
    [baseView addSubview:rightBtn];
    [rightBtn setImage:[UIImage imageNamed:@"walk"] forState:UIControlStateNormal];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(baseView.mas_centerY);
        make.left.equalTo(centerBtn.mas_right).offset(30);
    }];
    self.navigationItem.titleView = baseView;
}
@end
