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
// 路线规划需引入的头文件
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviAnnotation.h"

@interface PathPlanningViewController ()<MAMapViewDelegate,AMapSearchDelegate>
@property(nonatomic,strong) MAMapView* mapView;    // 地图视图
@property(nonatomic,strong) AMapSearchAPI* search; // 搜索API
@property (nonatomic,retain) NSArray *pathPolylines;
@property (nonatomic,retain) MAPointAnnotation *destinationPoint;//目标点
@end

@implementation PathPlanningViewController
- (NSArray *)pathPolylines
{
    if (!_pathPolylines) {
        _pathPolylines = [NSArray array];
    }
    return _pathPolylines;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    // 初始化导航栏
    [self initNavi];
    // 初始化视图
    [self initView];
    // 设置步行线路规划
    //[self setupLinePlanning];
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
#pragma mark - 设置步行线路规划参数
- (void)setupLinePlanning
{
    // 设置步行线路规划参数
    //self.startAnnotation = [[MAPointAnnotation alloc] init];
//    self.startAnnotation.coordinate.latitude = (CLLocationDegrees)30.26405277;
    //self.startAnnotation.coordinate = self.startCoordinate;
    //self.destinationAnnotation.coordinate = self.destinationCoordinate;
    
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    
    /* 出发点. */
    //navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           //longitude:self.startCoordinate.longitude];
    navi.origin = [AMapGeoPoint locationWithLatitude:30.26405277 longitude:120.12346029];
    /* 目的地. */
    //navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                //longitude:self.destinationCoordinate.longitude];
    navi.destination = [AMapGeoPoint locationWithLatitude:30.30446546 longitude:120.08666039];
    //调用 AMapSearchAPI 的 AMapWalkingRouteSearch 并发起步行路线规划。
    [self.search AMapWalkingRouteSearch:navi];
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
    [rightBtn setImage:[UIImage imageNamed:@"bus"] forState:UIControlStateNormal];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(baseView.mas_centerY);
        make.left.equalTo(centerBtn.mas_right).offset(30);
    }];
    self.navigationItem.titleView = baseView;
    
    [centerBtn addTarget:self action:@selector(carNavi) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 汽车导航
- (void)carNavi
{
    //CLLocationCoordinate2D coordinate = [_mapView convertPoint:[gesture locationInView:_mapView] toCoordinateFromView:_mapView];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(34.294021, 117.14231);
    // 添加标注
    if (_destinationPoint != nil) {
        // 清理
        [_mapView removeAnnotation:_destinationPoint];
        _destinationPoint = nil;
    }
    _destinationPoint = [[MAPointAnnotation alloc] init];
    _destinationPoint.coordinate = coordinate;
    _destinationPoint.title = @"目标点";
    [_mapView addAnnotation:_destinationPoint];

}
//实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response.route == nil)
    {
        return;
    }
    
    //通过AMapNavigationSearchResponse对象处理搜索结果
    NSString *route = [NSString stringWithFormat:@"Navi: %@", response.route];
    
    NSLog(@"%@", route);
    AMapPath *path = response.route.paths[0];
    AMapStep *step = path.steps[0];
    NSLog(@"%@",step.polyline);
    NSLog(@"%@",response.route.paths[0]);
    
    
    if (response.count > 0)
    {
        [_mapView removeOverlays:_pathPolylines];
        _pathPolylines = nil;
        
        // 只显⽰示第⼀条 规划的路径
        _pathPolylines = [self polylinesForPath:response.route.paths[0]];
        NSLog(@"%@",response.route.paths[0]);
        
        [_mapView addOverlays:_pathPolylines];
        
        //        解析第一条返回结果
        //        搜索路线
        MAPointAnnotation *currentAnnotation = [[MAPointAnnotation alloc]init];
        currentAnnotation.coordinate = _mapView.userLocation.coordinate;
        [_mapView showAnnotations:@[_destinationPoint, currentAnnotation] animated:YES];
        [_mapView addAnnotation:currentAnnotation];
    }
    
    
    //    [self drawPolygonWith:response.route.origin dest:response.route.destination];
}
//路线解析
- (NSArray *)polylinesForPath:(AMapPath *)path
{
    if (path == nil || path.steps.count == 0)
    {
        return nil;
    }
    NSMutableArray *polylines = [NSMutableArray array];
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline
                                                         coordinateCount:&count
                                                              parseToken:@";"];
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        
        //          MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:count];
        
        [polylines addObject:polyline];
        free(coordinates), coordinates = NULL;
    }];
    return polylines;
}
//解析经纬度
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token
{
    if (string == nil)
    {
        return NULL;
    }
    
    if (token == nil)
    {
        token = @",";
    }
    
    NSString *str = @"";
    if (![token isEqualToString:@","])
    {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    
    else
    {
        str = [NSString stringWithString:string];
    }
    
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    
    return coordinates;
}
@end
