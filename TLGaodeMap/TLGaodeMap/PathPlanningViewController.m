//
//  PathPlanningViewController.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/19.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "PathPlanningViewController.h"
#import <Masonry.h>
// 路线规划需引入的头文件
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "MANaviAnnotation.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviRoute.h"
#import "CommonUtility.h"
static const NSInteger RoutePlanningPaddingEdge                    = 20;
static const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
@interface PathPlanningViewController ()<MAMapViewDelegate,AMapSearchDelegate>
/*
    驾车路线
 */
@property(nonatomic,strong) MAMapView* mapView;    // 地图视图
@property(nonatomic,strong) AMapSearchAPI* search; // 搜索API


/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic, strong) UIBarButtonItem *previousItem;
@property (nonatomic, strong) UIBarButtonItem *nextItem;
/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;
@property (nonatomic, strong) AMapRoute *route;
@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;
@property(nonatomic,strong)UIButton* centerBtn;// car按钮
@property(nonatomic,strong)UIButton* leftBtn;// walk按钮
@property(nonatomic,strong)UIButton* rightBtn;// bUS按钮
@property(nonatomic,assign)BOOL isBus; //布尔值
@property(nonatomic,strong) MAUserLocation *userLocation;
@end

@implementation PathPlanningViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 显示用户位置
    self.mapView.showsUserLocation=YES;
    // 开启步行规划
    [self walkNavi];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
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
    [self.mapView setZoomLevel:12 animated:YES];//17.5
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
    //self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    UIView* baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,200,44)];
    
    self.centerBtn = [[UIButton alloc] init];
    [baseView addSubview:_centerBtn];
    [self.centerBtn setImage:[UIImage imageNamed:@"car_h"] forState:UIControlStateNormal];
    [self.centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(baseView.mas_centerX);
        make.centerY.equalTo(baseView.mas_centerY);
    }];
    self.leftBtn = [[UIButton alloc] init];
    [baseView addSubview:_leftBtn];
    [self.leftBtn setImage:[UIImage imageNamed:@"walk"] forState:UIControlStateNormal];
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(baseView.mas_centerY);
        make.right.equalTo(self.centerBtn.mas_left).offset(-30);
    }];
    
    self.rightBtn = [[UIButton alloc] init];
    [baseView addSubview:_rightBtn];
    [self.rightBtn setImage:[UIImage imageNamed:@"bus_h"] forState:UIControlStateNormal];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(baseView.mas_centerY);
        make.left.equalTo(self.centerBtn.mas_right).offset(30);
    }];
    self.rightBtn.tag = 300;
    self.navigationItem.titleView = baseView;
    
    [self.leftBtn addTarget:self action:@selector(walkNavi) forControlEvents:UIControlEventTouchUpInside];
    [self.centerBtn addTarget:self action:@selector(carNavi) forControlEvents:UIControlEventTouchUpInside];
    [self.rightBtn addTarget:self action:@selector(busNavi) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 公交路线规划
- (void)busNavi
{
    [self.rightBtn setImage:[UIImage imageNamed:@"bus"] forState:UIControlStateNormal];
    [self.centerBtn setImage:[UIImage imageNamed:@"car_h"] forState:UIControlStateNormal];
    [self.leftBtn setImage:[UIImage imageNamed:@"walk_h"] forState:UIControlStateNormal];
    self.isBus = YES;
    //self.startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888);
    //self.destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956);
//    self.startCoordinate        = CLLocationCoordinate2DMake(34.299445,117.142589);
    self.startCoordinate = self.mapView.userLocation.location.coordinate;
    self.destinationCoordinate = _endPoint;
    [self initToolBar];
    [self addDefaultAnnotations];
    [self updateCourseUI];
    //[self updateDetailUI];
    
    [self searchRoutePlanningBus];

}
#pragma mark - do search
- (void)searchRoutePlanningBus
{
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapTransitRouteSearchRequest *navi = [[AMapTransitRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    //navi.city             = @"beijing";
//    navi.city = @"徐州";
    //navi.city             = @"北京";
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapTransitRouteSearch:navi];
}
/* 展示当前路线方案. */
- (void)presentCurrentCourses
{
    self.naviRoute = [MANaviRoute naviRouteForTransit:self.route.transits[self.currentCourse] startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
    [self.naviRoute addToMapView:self.mapView];
    
    /* 缩放地图使其适应polylines的展示. */
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                           animated:YES];
}

#pragma mark - 步行路线规划
- (void)walkNavi
{
    [self.leftBtn setImage:[UIImage imageNamed:@"walk"] forState:UIControlStateNormal];
    [self.centerBtn setImage:[UIImage imageNamed:@"car_h"] forState:UIControlStateNormal];
    [self.rightBtn setImage:[UIImage imageNamed:@"bus_h"] forState:UIControlStateNormal];
    self.isBus = NO;
    //self.startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888);
    //self.destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956);
    //self.startCoordinate = self.mapView.userLocation.location.coordinate;
    self.startCoordinate = _currentPoint;
//    self.startCoordinate        = CLLocationCoordinate2DMake(34.299445,117.142589);
    self.loca = _locations;
//    MAUserLocation
//    self.startCoordinate = self.userLocation.location.coordinate;
//    self.startCoordinate        = CLLocationCoordinate2DMake(34.299445,117.142589);
    self.destinationCoordinate = _endPoint;
    [self initToolBar];
    
    [self addDefaultAnnotations];
    
    [self updateCourseUI];
    
    //[self updateDetailUI];
    
    [self searchRoutePlanningWalk];
}
#pragma mark - do search
- (void)searchRoutePlanningWalk
{
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    
    /* 提供备选方案*/
    //navi.multipath = 1;
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapWalkingRouteSearch:navi];
}

#pragma mark - 汽车导航
- (void)carNavi
{
    [self.leftBtn setImage:[UIImage imageNamed:@"walk_h"] forState:UIControlStateNormal];
    [self.centerBtn setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
    [self.rightBtn setImage:[UIImage imageNamed:@"bus_h"] forState:UIControlStateNormal];
    self.isBus = NO;
    //self.startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888);
    //self.destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956);
//    self.startCoordinate        = CLLocationCoordinate2DMake(34.299445,117.142589);
    self.startCoordinate        = self.mapView.userLocation.location.coordinate;
    self.destinationCoordinate  = _endPoint;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self initToolBar];
    [self addDefaultAnnotations];
    [self updateCourseUI];
    //[self updateDetailUI];
    [self searchRoutePlanningDrive];
}
#pragma mark - Initialization
- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    /* 上一个. */
    UIBarButtonItem *previousItem = [[UIBarButtonItem alloc] initWithTitle:@"上一个"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(previousCourseAction)];
    self.previousItem = previousItem;
    
    /* 下一个. */
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"下一个"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(nextCourseAction)];
    self.nextItem = nextItem;
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, previousItem, flexbleItem, nextItem, flexbleItem, nil];
}
/* 切到上一个方案路线. */
- (void)previousCourseAction
{
    if ([self decreaseCurrentCourse])
    {
        [self clear];
        
        [self updateCourseUI];
        
        [self presentCurrentCourse];
    }
}
- (BOOL)decreaseCurrentCourse
{
    BOOL result = NO;
    
    if (self.currentCourse > 0)
    {
        self.currentCourse--;
        
        result = YES;
    }
    
    return result;
}
/* 清空地图上已有的路线. */
- (void)clear
{
    [self.naviRoute removeFromMapView];
}
#pragma mark - Utility
/* 更新"上一个", "下一个"按钮状态. */
- (void)updateCourseUI
{
    /* 上一个. */
    self.previousItem.enabled = (self.currentCourse > 0);
    
    /* 下一个. */
    self.nextItem.enabled = (self.currentCourse < self.totalCourse - 1);
}
/* 展示当前路线方案. */
- (void)presentCurrentCourse
{
    MANaviAnnotationType type = MANaviAnnotationTypeDrive;
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentCourse] withNaviType:type showTraffic:YES startPoint:[AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude] endPoint:[AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude]];
    [self.naviRoute addToMapView:self.mapView];
    
    /* 缩放地图使其适应polylines的展示. */
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                           animated:YES];
}


/* 切到下一个方案路线. */
- (void)nextCourseAction
{
    if ([self increaseCurrentCourse])
    {
        [self clear];
        
        [self updateCourseUI];
        
        [self presentCurrentCourse];
    }
}
- (BOOL)increaseCurrentCourse
{
    BOOL result = NO;
    
    if (self.currentCourse < self.totalCourse - 1)
    {
        self.currentCourse++;
        
        result = YES;
    }
    
    return result;
}
- (void)addDefaultAnnotations
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}
#pragma mark - do search
- (void)searchRoutePlanningDrive
{
    self.startAnnotation.coordinate = self.startCoordinate;
    self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.strategy = 5;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapDrivingRouteSearch:navi];
}
#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    //NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
}

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil)
    {
        return;
    }
    
    self.route = response.route;
    [self updateTotal];
    self.currentCourse = 0;
    
    [self updateCourseUI];
    //[self updateDetailUI];
    
    if (response.count > 0 && self.isBus == NO)
    {
        [self presentCurrentCourse];
        
    }
    if (response.count > 0 && self.isBus == YES)
    {
        [self presentCurrentCourses];
    }
}
- (void)updateTotal
{
    self.totalCourse = self.route.paths.count;
}
#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 8;
        polylineRenderer.lineDash = YES;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]])
    {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 8;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking)
        {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway)
        {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else
        {
            polylineRenderer.strokeColor = self.naviRoute.routeColor;
        }
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:routePlanningCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        
        if ([annotation isKindOfClass:[MANaviAnnotation class]])
        {
            switch (((MANaviAnnotation*)annotation).type)
            {
                case MANaviAnnotationTypeRailway:
                    poiAnnotationView.image = [UIImage imageNamed:@"railway_station"];
                    break;
                    
                case MANaviAnnotationTypeBus:
                    poiAnnotationView.image = [UIImage imageNamed:@"bus"];
                    break;
                    
                case MANaviAnnotationTypeDrive:
                    poiAnnotationView.image = [UIImage imageNamed:@"car"];
                    break;
                    
                case MANaviAnnotationTypeWalking:
//                    poiAnnotationView.image = [UIImage imageNamed:@"man"];
                    poiAnnotationView.image = [UIImage imageNamed:@"walk_h"];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            /* 起点. */
            if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"bubble_start"];
            }
            /* 终点. */
            else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle])
            {
                poiAnnotationView.image = [UIImage imageNamed:@"bubble_end"];
            }
            
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    self.userLocation = [[MAUserLocation alloc] init];
    self.userLocation = userLocation;
}
@end
