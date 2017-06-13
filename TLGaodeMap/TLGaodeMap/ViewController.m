//
//  ViewController.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/6.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "ViewController.h"
#import <AMapLocationKit/AMapLocationKit.h>     // 导入头文件
#import <Masonry.h>
#import "TLTextField.h"
#import "SearchViewController.h"
#import "MAMapView+MapView.h"
#import "AMapSearchObject+SearchObject.h"
@interface ViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>
// 初始化AMapLocationManager对象,设置代理。
@property(nonatomic,strong) AMapLocationManager* locationManager;
// 可变的字典
@property(nonatomic,strong) NSMutableDictionary* dicData;
// 可变的数组数据
@property(nonatomic,strong) NSMutableArray* arrayData;
// TableView Row 数组
@property(nonatomic,strong) NSArray* rowCountArray;
// 校区名字
@property(nonatomic,strong) NSString* campusName;
// 经度Str
@property(nonatomic,strong) NSString* strLongitude;
// pointList Array
@property(nonatomic,strong) NSArray* arrayPointList;
// gps按钮
@property(nonatomic,strong) UIButton* gpsButton;
// 校区表格视图
@property(nonatomic,strong) UITableView* campusTableView;
// 左边条
@property(nonatomic,strong) UIBarButtonItem* leftItem;
// 右边条
@property(nonatomic,strong) UIBarButtonItem* rightItem;
/// 用手势添加的标注点
@property (nonatomic, strong) MAPointAnnotation *touchAnnotation;
// 搜索文本框
@property (nonatomic, weak) TLTextField *searchTxt;
/// 搜索提示数组
@property (nonatomic, strong) NSMutableArray *searchTipArr;
// 协调区域
@property(nonatomic,assign) MACoordinateRegion boundary;
// BOOL 判断
@property(nonatomic,assign) BOOL isOpen;
// 搜索控制器
@property(nonatomic,strong) SearchViewController* tableVC;
// 搜索表格视图
@property(nonatomic,strong) UITableView* searchTableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化导航栏UI
    [self initNavigationUI];
    // 设置地图视图
    [self setupMapView];
    // 解析接口
    [self ParseInterface];
    // 搜索服务
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
    //self.mapView.screenAnchor = CGPointMake(0.5, 0.5);
    //[self initSearchTableView];
    
}
#pragma mark - 初始化地图
- (void)setupMapView
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
    [self.mapView setZoomLevel:15.5 animated:YES];//17.5
    // ✨设置此 用户跟踪模式 属性地图正常铺开显示
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;// MAUserTrackingModeFollow 1
    // 设置中心坐标
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.26405277, 120.12346029) animated:YES];
    // 设置指南针的位置
    self.mapView.compassOrigin = CGPointMake(self.mapView.compassOrigin.x-10, 70);
    // 定义表示上下文1
    self.definesPresentationContext = YES;
    // 变焦显示器视图
    UIView* zoomPannelView = [self makeZoomPannelView];
    zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10, self.view.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    zoomPannelView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:zoomPannelView];
    // gps按钮
    self.gpsButton = [self makeGPSButtonView];
    self.gpsButton.center = CGPointMake(CGRectGetMidX(self.gpsButton.bounds) + 10,
                                        self.view.bounds.size.height -  CGRectGetMidY(self.gpsButton.bounds) - 20);
    [self.view addSubview:self.gpsButton];
    self.gpsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
}
#pragma mark - 初始化搜索表格视图
- (void)initSearchTableView
{
    self.tableVC = [[SearchViewController alloc]initWithStyle:UITableViewStylePlain];
    self.tableVC.mapView = _mapView;
}
#pragma mark - 初始化导航栏UI
- (void)initNavigationUI
{
    // 指定导航栏左边条按钮
    self.leftItem=[[UIBarButtonItem alloc] initWithTitle:@"切换校区" style:UIBarButtonItemStylePlain target:self action:@selector(showView)];
    self.navigationItem.leftBarButtonItem=_leftItem;
    // 指定导航栏右边条按钮
    self.rightItem=[[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchButton)];
    self.navigationItem.rightBarButtonItem=_rightItem;
    // 添加搜索文本框
    TLTextField* searchTxt = [[TLTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.7, 30)];
    searchTxt.delegate=self;
    self.navigationItem.titleView=searchTxt;
    self.searchTxt = searchTxt;
}
#pragma mark -  解析校园地图接口
- (void)ParseInterface
{
    // 0.指定URL请求
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://portal.zfsoft.com:9090/zftal-mobile/newmobile/MobileLoginServlet/getMapList"]];
    // 1.使用NSURLSession会话获取网络返回的JSON并处理
    NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.arrayData = [NSMutableArray array];
        self.arrayData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"arrayData = %@",_arrayData);
        self.rowCountArray = [self.arrayData valueForKey:@"name"];
        NSLog(@"行数数组 = %@",_rowCountArray);
        self.dicData = [self.arrayData valueForKey:@"pointList"];
        NSLog(@"点列表 = %@",_dicData);
        self.campusName = [self.dicData valueForKey:@"x"];
        NSLog(@"x = %@",_campusName);
        self.strLongitude = [self.arrayData valueForKey:@"longitude"];
        NSLog(@"经度 = %@",_strLongitude);
        self.arrayPointList = [self.arrayData valueForKey:@"pointList"];
        NSLog(@"arrayPointList = %@",_arrayPointList);
        // 刷新TableView
        [self.campusTableView reloadData];
    }];
    // 2.调用任务
    [dataTask resume];
    [self.campusTableView reloadData];
}
#pragma mark leftBarButton 点击事件方法
- (void)showView
{
    if (self.isOpen == NO)
    {
        self.campusTableView = [[UITableView alloc] init];
        [self.view addSubview:_campusTableView];
        self.campusTableView.frame = CGRectMake(5, 70, 200, 180);
        self.campusTableView.delegate=self;
        self.campusTableView.dataSource=self;
        [self.searchTxt endEditing:YES];
        self.isOpen = YES;
    }
    else
    {
        return;
    }
}
#pragma mark RightBarButton 点击事件方法
- (void)searchButton;
{
    [self.searchTxt endEditing:YES];
    self.campusTableView.hidden=YES;
    self.isOpen = NO;
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 200)];
    [self.view addSubview:_searchTableView];
    [self.searchTableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    self.searchList = [NSMutableArray array];

    NSString *keywords = _searchTxt.text;
    if(!keywords.length)
    {
        return;
    }
    [AMapSearchObject searchPolygon:keywords andPiontsArray:[self returnZheDaPoint] andSearchApi:_searchAPI];
//    //发起输入提示搜索
//    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
//    //关键字
//    tipsRequest.keywords = _searchTxt.text;
//    //城市
//    tipsRequest.city = @"杭州";
//    //执行搜索
//    [_searchAPI AMapInputTipsSearch: tipsRequest];

}
/*  返回浙大的轮廓点  多边形 */
- (NSArray *)returnZheDaPoint
{
    AMapGeoPoint *Point1 = [[AMapGeoPoint alloc]init];
    Point1.latitude = 30.31011561;
    Point1.longitude = 120.08065224;
    AMapGeoPoint *Point2 = [[AMapGeoPoint alloc]init];
    Point2.latitude = 30.29509105;
    Point2.longitude = 120.08273363;
    AMapGeoPoint *Point3 = [[AMapGeoPoint alloc]init];
    Point3.latitude = 30.30937463;
    Point3.longitude = 120.08902073;
    AMapGeoPoint *Point4 = [[AMapGeoPoint alloc]init];
    Point4.latitude = 30.29477609;
    Point4.longitude = 120.09251833;
    
    NSArray *piontArr = [NSArray arrayWithObjects:Point1, Point2, Point3, Point4, nil];
    
    return piontArr;
}

#pragma campusTableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.campusTableView)
    {
        return self.rowCountArray.count;
    }
    else
    {
        if ([self.searchList count])
        {
            return [self.searchList count];
        }
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* campusCell = @"campusCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:campusCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:campusCell];//Default
    }
    if (tableView == self.campusTableView)
    {
        cell.textLabel.text = self.rowCountArray[indexPath.row];
    }
    else
    {
        AMapAOI* pio = [self.searchList objectAtIndex:indexPath.row];
        cell.textLabel.text = pio.name;
        cell.detailTextLabel.text = pio.adcode;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        // 玉泉校区
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 30.26405277;
        coordinate.longitude = 120.12346029;
        MACoordinateSpan span;
        span.latitudeDelta = 0.01393703;
        span.longitudeDelta = 0.01281023;
        [_mapView showAppointRegionCoordinate:coordinate andSpan:span];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.27044654, 120.13240814)];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.25595341, 120.11296749) animated:YES];

    }
    else if (indexPath.row == 1)
    {
        // 之江校区
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 30.19258113;
        coordinate.longitude = 120.12537224;
        MACoordinateSpan span;
        span.latitudeDelta = 0.00763204;
        span.longitudeDelta = 0.0102675;
        [_mapView showAppointRegionCoordinate:coordinate andSpan:span];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.19514054, 120.1307559)];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.18855642, 120.12116432)];
    }
    else if (indexPath.row == 2)
    {
        //紫金港校区
        //显示指定区域
        //需要一个中心点，和纵向跨度、横向跨度
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 30.30446546;
        coordinate.longitude = 120.08666039;
        MACoordinateSpan span;
        span.latitudeDelta = 0.02154799;
        span.longitudeDelta = 0.001202924;
        [_mapView showAppointRegionCoordinate:coordinate andSpan:span];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.31439469, 120.09236813)];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.29497989, 120.08103848)];
    }
    else if (indexPath.row == 3)
    {
        // 华家池校区
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 30.26979791;
        coordinate.longitude = 120.19596577;
        MACoordinateSpan span;
        span.latitudeDelta = 0.01367672;
        span.longitudeDelta = 0.00989199;
        [_mapView showAppointRegionCoordinate:coordinate andSpan:span];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.27878562, 120.20270348)];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.26258864, 120.18922806)];
    }
    self.campusTableView.hidden = YES;
    self.isOpen = NO;
}
#pragma mark - 辞去第一响应者
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 隐藏tableView
    self.campusTableView.hidden=YES;
    [self.searchTxt endEditing:YES];
    self.isOpen = NO;
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
#pragma mark - 全球定位系统(GPS)按钮查看
- (UIButton *)makeGPSButtonView
{
    UIButton* ret = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    ret.backgroundColor = [UIColor whiteColor];
    ret.layer.cornerRadius = 4;
    
    [ret setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
    [ret addTarget:self action:@selector(gpsAction) forControlEvents:UIControlEventTouchUpInside];
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

- (void)gpsAction {
    if(self.mapView.userLocation.updating && self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
        [self.gpsButton setSelected:YES];
    }
}
/**
 *  POI查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
-(void)onPOISearchDone:(AMapPOISearchBaseRequest*)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    _tableVC.tableView.hidden = NO;
    // 通过 AMapPOISearchResponse 对象处理搜索结果
    NSString* strCount = [NSString stringWithFormat:@"count: %zd",response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois)
    {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);

    self.tableVC.searchList = response.pois;
    [self.tableVC.tableView reloadData];
}
#pragma mark - 单击地图时显示出点击位置名称
- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois
{
    if (pois)
    {
        [self.mapView removeAnnotationsAndOverlays];
        MATouchPoi* poi = [pois firstObject];
        [self.mapView addPointAnnotation:poi];
    }
}
/*
 //    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake
 //                                                                 (39.939577, 116.388331),CLLocationCoordinate2DMake(39.935029, 116.384377));
 //    MAGroundOverlay *groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"GWF"]];
 //    [_mapView addOverlay:groundOverlay];
 //    _mapView.visibleMapRect = groundOverlay.boundingMapRect;
 //    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(30.27044654, 120.13240814),CLLocationCoordinate2DMake(30.25595341, 120.11296749));
 //    MAGroundOverlay* groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:nil];
 //    [self.mapView addOverlay:groundOverlay];
 //    self.mapView.visibleMapRect = groundOverlay.boundingMapRect;
 
 //self.mapView = MACoordinateBoundsMake(CLLocationCoordinate2DMake(30.27044654, 120.13240814), CLLocationCoordinate2DMake(30.25595341, 120.11296749));
 //self.mapView setRegion:MACoordinateRegion
 
 //    MACoordinateBounds j = MACoordinateBoundsMake(CLLocationCoordinate2DMake(30.27044654, 120.13240814), CLLocationCoordinate2DMake(30.25595341, 120.13240814));
 //    CLLocationCoordinate2D cd[2];
 //    cd[0].latitude = 30.27044654;
 //    cd[0].longitude = 120.13240814;
 //    cd[1].latitude = 30.25595341;
 //    cd[1].longitude = 120.13240814;
 //    MAPolygon* polygon = [MAPolygon polygonWithPoints:cd count:2];
 //    [self.mapView addOverlay:polygon];
 
 //    NSURL *scheme = [NSURL URLWithString:@"iosamap://"];
 //    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:scheme];
 //    NSLog(@"可以打开 = %d",canOpen);
 //    NSURL *myLocationScheme = [NSURL URLWithString:@"iosamap://myLocation?sourceApplication=applicationName"]; if ([[UIDevice currentDevice].systemVersion integerValue] >= 10) {
 //        //iOS10以后,使用新API
 //        [[UIApplication sharedApplication] openURL:myLocationScheme options:@{} completionHandler:^(BOOL success) { NSLog(@"scheme调用结束"); }]; } else {
 //            //iOS10以前,使用旧API
 //            [[UIApplication sharedApplication] openURL:myLocationScheme]; }
 
 //    self.mapView
 //self.mapView.mapType = MAMapTypeStandard;//映射类型标准
 //self.mapView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 //self.mapView.showsScale=NO;//设置成NO表示不显示比例尺；YES表示显示比例尺
 //self.mapView.showsCompass=YES; // 设置成NO表示关闭指南针；YES表示显示指南针
 // 显示室内地图
 //self.mapView.showsIndoorMap=YES;
 //self.definesPresentationContext=YES;
 //显示指定区域
 //需要一个中心点，和纵向跨度、横向跨度
 //    CLLocationCoordinate2D coordinate;
 //    coordinate.latitude = 30.30446546;
 //    coordinate.longitude = 120.08666039;
 //    MACoordinateSpan span;
 //    span.latitudeDelta = 0.02154799;
 //    span.longitudeDelta = 0.001202924;
 
 // 初始化AMapLocationManager对象,设置代理。
 //    self.locationManager = [[AMapLocationManager alloc]init];
 //    self.locationManager.delegate=self;
 //    //1.设置期望定位精度
 //    // 带逆地理信息的一次定位（返回坐标和地址信息）
 //    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
 //    // 定位超时时间，最低2s，此处设置为2s
 //    self.locationManager.locationTimeout = 2;
 //    // 逆地理请求请求超时时间，最低2s，此处设置为2s
 //    self.locationManager.reGeocodeTimeout = 2;
 //2.请求定位并拿到结果
 //带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
 //    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
 //        if (error)
 //        {
 //            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
 //            if (error.code == AMapLocationErrorLocateFailed)
 //            {
 //                return;
 //            }
 //        }
 //        NSLog(@"location:%@", location);
 //        if (regeocode)
 //        {
 //
 //            NSLog(@"reGeocode:%@", regeocode);
 //        }
 //    }];
 // 调用AMaplocationManager提供的startUpdatingLocation方法开启持续定位。
 //    [self.locationManager startUpdatingLocation];
 //    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://portal.zfsoft.com:9090/zftal-mobile/newmobile/MobileLoginServlet/getMapList"]];
 //    NSURLSession* session=[NSURLSession sharedSession];
 //    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
 //        self.dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
 //        NSLog(@"dic = %@",_dic);
 //    }];
 //    [task resume];
 // 接收位置更新,实现AMapLocationManagerDelegate代理的amaplocationManager:didUpdateLocation方法,处理位置更新
 //- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
 //{
 //    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
 //    if (reGeocode)
 //    {
 //        NSLog(@"reGeocode:%@", reGeocode);
 //    }
 //}
 //- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
 //{
 //
 //}
 //- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
 //{
 //    
 //}

 */
@end
