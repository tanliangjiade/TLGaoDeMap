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
#import "PullDownTableView.h"
#import "PlaceResultViewController.h"
#import "PathPlanningViewController.h"
#import "DetailsViewController.h"

@interface ViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SelectedPlaceDelegate>//UISearchResultsUpdating
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
/// 搜索结果数组
@property (nonatomic, strong) NSMutableArray *searchResultArr;
// 全局的位置坐标二维对象
@property(nonatomic,assign) CLLocationCoordinate2D coordinate;
@property(nonnull,strong)AMapPOI *pPoi;
@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;
// 路线规划类
@property (nonatomic, strong) AMapRoute *route;
/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
@property (nonatomic,strong) DetailsViewController* details;
@property (nonatomic,strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic,strong) MAUserLocation *userLocation;
@property (nonatomic,strong) MAAnnotationView* view;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:17/255.0 green:137/255.0 blue:232/255.0 alpha:1];
    self.mapView.touchPOIEnabled = YES;
    // 初始化导航栏UI
    [self initNavigationUI];
    // 设置地图视图
    [self setupMapView];
    // 初始化搜索表格
    //[self initSearchTableView];
    // 初始化搜索栏
    //[self initSearch];
    // 解析接口
    [self ParseInterface];
    // 搜索服务对象
    self.searchAPI = [[AMapSearchAPI alloc] init];
    // 遵守代理
    self.searchAPI.delegate = self;
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
//    _coordinate.latitude = 30.26405277;
//    _coordinate.longitude = 120.12346029;
    _coordinate.latitude = 34.297561;
    _coordinate.longitude = 117.139711;
    //120.123077,30.263842
    //_coordinate.latitude = 34.2958525025;   // 0.0070905094
    //_coordinate.longitude = 117.1382474899; // 0.0085830689
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(_coordinate.latitude, _coordinate.longitude) animated:YES];
    // 30.31011561  120.08065224;
    // 设置指南针的位置
    self.mapView.compassOrigin = CGPointMake(self.mapView.compassOrigin.x-10, 70);
    // 定义表示上下文1
    self.definesPresentationContext = YES;
    // 变焦显示器视图
    UIView* zoomPannelView = [self makeZoomPannelView];
    //zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10, self.view.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10, self.view.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 80);
    zoomPannelView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:zoomPannelView];
    // gps按钮
    self.gpsButton = [self makeGPSButtonView];
    //self.gpsButton.center = CGPointMake(CGRectGetMidX(self.gpsButton.bounds) + 10,
                                        //self.view.bounds.size.height -  CGRectGetMidY(self.gpsButton.bounds) - 20);
    self.gpsButton.center = CGPointMake(self.view.frame.origin.x+30, 160);
    [self.view addSubview:self.gpsButton];
    self.gpsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
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
    // http://zsxy.xzcit.cn:7979/zftal-mobile/newmobile/MobileLoginServlet/getMapList
    //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://portal.zfsoft.com:9090/zftal-mobile/newmobile/MobileLoginServlet/getMapList"]];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://zsxy.xzcit.cn:7979/zftal-mobile/newmobile/MobileLoginServlet/getMapList"]];
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
#pragma mark - leftBarButton 点击事件方法
- (void)showView
{
    if (self.isOpen == NO)
    {
        self.campusTableView = [[UITableView alloc] init];
        [self.view addSubview:_campusTableView];
        //self.campusTableView.frame = CGRectMake(5, 70, 200, 180);
        self.campusTableView.frame = CGRectMake(5, 70, 150, 44);
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
-(void)changeButtonStatus{
    self.rightItem.enabled = YES;
}
#pragma mark - RightBarButton 点击事件方法
- (void)searchButton;
{
    self.rightItem.enabled = NO;
    [self performSelector:@selector(changeButtonStatus) withObject:nil afterDelay:1.0f];//防止用户重复点击
    
    [self.searchTxt endEditing:YES];
    self.campusTableView.hidden=YES;
    self.isOpen = NO;
    // 周边检索
    AMapPOIAroundSearchRequest* request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
    request.keywords = self.searchTxt.text;
    /* 按照距离排序. */
    //request.sortrule            = 0;
    // 是否返回扩展信息，默认为 NO。
    //request.requireExtension    = YES;
    // 发起周边检索
    [self.searchAPI AMapPOIAroundSearch:request];
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
//        // 玉泉校区
//        //CLLocationCoordinate2D coordinate;
//        _coordinate.latitude = 30.26405277;
//        _coordinate.longitude = 120.12346029;
//        MACoordinateSpan span;
//        span.latitudeDelta = 0.01393703;
//        span.longitudeDelta = 0.01281023;
//        [_mapView showAppointRegionCoordinate:_coordinate andSpan:span];
//        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.27044654, 120.13240814)];
//        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.25595341, 120.11296749) animated:YES];
        _coordinate.latitude = 34.299529;
        _coordinate.longitude = 117.142651;
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(34.299529, 117.142651) animated:YES];
    }
    else if (indexPath.row == 1)
    {
        // 之江校区
        //CLLocationCoordinate2D coordinate;
        _coordinate.latitude = 30.19258113;
        _coordinate.longitude = 120.12537224;
        MACoordinateSpan span;
        span.latitudeDelta = 0.00763204;
        span.longitudeDelta = 0.0102675;
        [_mapView showAppointRegionCoordinate:_coordinate andSpan:span];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.19514054, 120.1307559)];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.18855642, 120.12116432)];
    }
    else if (indexPath.row == 2)
    {
        //紫金港校区
        //显示指定区域
        //需要一个中心点，和纵向跨度、横向跨度
        //CLLocationCoordinate2D coordinate;
        _coordinate.latitude = 30.30446546;
        _coordinate.longitude = 120.08666039;
        MACoordinateSpan span;
        span.latitudeDelta = 0.02154799;
        span.longitudeDelta = 0.001202924;
        [_mapView showAppointRegionCoordinate:_coordinate andSpan:span];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.31439469, 120.09236813)];
        //[self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(30.29497989, 120.08103848)];
    }
    else if (indexPath.row == 3)
    {
        // 华家池校区
        //CLLocationCoordinate2D coordinate;
        _coordinate.latitude = 30.26979791;
        _coordinate.longitude = 120.19596577;
        MACoordinateSpan span;
        span.latitudeDelta = 0.01367672;
        span.longitudeDelta = 0.00989199;
        [_mapView showAppointRegionCoordinate:_coordinate andSpan:span];
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"返回"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:nil];
    NSString *strPoi = @"";
    self.searchResultArr = [NSMutableArray array];
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
        [self.searchResultArr addObject:p];
    }
    // 跳转到搜索结果界面
    PlaceResultViewController *VC = [[PlaceResultViewController alloc] init];
    VC.delegate = self;
    [self.navigationController pushViewController:VC animated:YES];
    VC.dataSourceArr = self.searchResultArr;
}
/**
 *  添加大头针
 */
- (void)addAnnotationWith:(id)place {
    // 每添加一个大头针之前先清空之前已经添加的大头针
    [self removePreviousAnnotation];

    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    if ([place isKindOfClass:[AMapPOI class]]) {
        self.pPoi = (AMapPOI *)place;
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(self.pPoi.location.latitude, self.pPoi.location.longitude);
        pointAnnotation.title = self.pPoi.name;
        pointAnnotation.subtitle = self.pPoi.address;
        
    }else if ([place isKindOfClass:[AMapTip class]]) {
        AMapTip *pTip = (AMapTip *)place;
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(pTip.location.latitude, pTip.location.longitude);
        pointAnnotation.title = pTip.name;
        pointAnnotation.subtitle = pTip.address;
    }
    // 1.刷新地图
    self.mapView.centerCoordinate = pointAnnotation.coordinate;
    // 2.添加大头针
    [self.mapView addAnnotation:pointAnnotation];
    // 3.选中 ===>默认弹出气泡
    [self.mapView selectAnnotation:pointAnnotation animated:YES];
}
/**
 *  移除上一个已经添加大头针
 */
- (void)removePreviousAnnotation {
    // 移除之前已经添加的大头针
    NSArray *annotationArray = self.mapView.annotations;
    for (int i = 0; i < annotationArray.count; ++i) {
        // 将不是用户位置信息的标注点移除掉
        if (![annotationArray[i] isKindOfClass:[MAUserLocation class]]) {
            [self.mapView removeAnnotation:annotationArray[i]];
        }
    }
}
#pragma mark - 实现 <MAMapViewDelegate> 协议中的 mapView:viewForAnnotation:回调函数，设置标注样式。
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString* pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView* annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple; // 紫色大头针
        return annotationView;
    }
    return nil;
}
#pragma mark - 弹出视图
- (void)PopUpView
{
    // 弹出视图
    CGFloat wth = self.view.frame.size.width / 2;
    UIButton* detailsBtn = [[UIButton alloc] init];
    [detailsBtn setTitle:@"详情" forState:UIControlStateNormal];
    detailsBtn.backgroundColor = [UIColor whiteColor];
    [detailsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.mapView addSubview:detailsBtn];
    [detailsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mapView.mas_bottom).offset(0);
        make.left.equalTo(self.mapView.mas_left).offset(0);
        make.width.offset(wth);
        make.height.offset(60);
    }];
    UIButton* goHereBtn = [[UIButton alloc] init];
    [goHereBtn setTitle:@"去这里" forState:UIControlStateNormal];
    goHereBtn.backgroundColor = [UIColor whiteColor];
    [goHereBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.mapView addSubview:goHereBtn];
    [goHereBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mapView.mas_bottom).offset(0);
        make.right.equalTo(self.mapView.mas_right).offset(0);
        make.width.offset(wth);
        make.height.offset(60);
    }];
    [detailsBtn addTarget:self action:@selector(goDetails) forControlEvents:UIControlEventTouchUpInside];
    [goHereBtn addTarget:self action:@selector(goHere) forControlEvents:UIControlEventTouchUpInside];
}
- (void)PopUpViewSearch
{
    // 弹出视图
    CGFloat wth = self.view.frame.size.width / 2;
    UIButton* detailsBtn = [[UIButton alloc] init];
    [detailsBtn setTitle:@"详情" forState:UIControlStateNormal];
    detailsBtn.backgroundColor = [UIColor whiteColor];
    [detailsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.mapView addSubview:detailsBtn];
    [detailsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mapView.mas_bottom).offset(0);
        make.left.equalTo(self.mapView.mas_left).offset(0);
        make.width.offset(wth);
        make.height.offset(60);
    }];
    UIButton* goHereBtn = [[UIButton alloc] init];
    [goHereBtn setTitle:@"去这里" forState:UIControlStateNormal];
    goHereBtn.backgroundColor = [UIColor whiteColor];
    [goHereBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.mapView addSubview:goHereBtn];
    [goHereBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mapView.mas_bottom).offset(0);
        make.right.equalTo(self.mapView.mas_right).offset(0);
        make.width.offset(wth);
        make.height.offset(60);
    }];
    [detailsBtn addTarget:self action:@selector(goDetailsSearch) forControlEvents:UIControlEventTouchUpInside];
    [goHereBtn addTarget:self action:@selector(goHereSearch) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - SelectedPlaceDelegate
// 实现选中地点的回调方法
- (void)cellDidClickCallbackWith:(AMapPOI *)place
{
    self.pPoi = place;
    // 添加大头针
    [self addAnnotationWith:place];
    // 弹出视图
    [self PopUpViewSearch];
}
#pragma mark - 跳转详情界面
- (void)goDetails
{
    DetailsViewController* tl = [[DetailsViewController alloc] init];
    [self.navigationController pushViewController:tl animated:YES];
    // 类属性传值
    tl.name = self.pointAnnotation.title;
}
- (void)goDetailsSearch
{
    DetailsViewController* tl = [[DetailsViewController alloc] init];
    [self.navigationController pushViewController:tl animated:YES];
    // 类属性传值
    tl.name = self.pPoi.name;
    tl.address = self.pPoi.address;
    tl.imageView = (UIImageView *)self.pPoi.images[0];
//    tl.imageView.image = self.view.image;
}
#pragma mark - 去这里
- (void)goHere
{
    // 步行路径规划
    //[self pathPlanning];
    PathPlanningViewController* pathPlanning = [[PathPlanningViewController alloc] init];
    [self.navigationController pushViewController:pathPlanning animated:YES];
}
- (void)goHereSearch
{
    // 步行路径规划
    //[self pathPlanning];
    PathPlanningViewController* pathPlanning = [[PathPlanningViewController alloc] init];
    [self.navigationController pushViewController:pathPlanning animated:YES];
}
#pragma mark - 单击地图时显示出点击位置名称
- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois
{
    MATouchPoi* p = [[MATouchPoi alloc] init];
    p = pois[0];
    // 每添加一个大头针之前先清空之前已经添加的大头针
    [self removePreviousAnnotation];
    AMapPOI* poi = [[AMapPOI alloc] init];
    poi = [pois firstObject];
    //[self.mapView addPointAnnotation:poi];
    self.pPoi = [pois firstObject];
    self.pointAnnotation = [[MAPointAnnotation alloc] init];
    self.pointAnnotation.coordinate = CLLocationCoordinate2DMake(p.coordinate.latitude, p.coordinate.longitude);
    self.pointAnnotation.title = poi.name;
    // 1.刷新地图
    self.mapView.centerCoordinate = _pointAnnotation.coordinate;
    // 2.添加大头针
    [self.mapView addAnnotation:_pointAnnotation];
    // 3.选中 ===>默认弹出气泡
    [self.mapView selectAnnotation:_pointAnnotation animated:YES];
    // 弹出视图
    [self PopUpView];
}
#pragma mark - 路径规划
- (void)pathPlanning
{
    // 设置步行线路规划参数
    // 步行路线规划的搜索参数类为 AMapWalkingRouteSearchRequest，origin（起点坐标）和destination（终点坐标）为必设参数。
    // 地图行走路线搜索请求类
    AMapWalkingRouteSearchRequest* navi = [[AMapWalkingRouteSearchRequest alloc] init];
    /* 出发点. */
    self.startAnnotation = [[MAPointAnnotation alloc] init];
    self.startAnnotation.coordinate = self.mapView.userLocation.location.coordinate;
    //self.startAnnotation.coordinate = self.mapView.userLocation.coordinate;
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    // 调用 AMapSearchAPI 的 AMapWalkingRouteSearch 并发起步行路线规划。
    [self.searchAPI AMapWalkingRouteSearch:navi];
}
#pragma mark - 当检索成功时，会进到 onRouteSearchDone 回调函数中，在该回调中，通过解析 AMapRouteSearchResponse 获取将步行规划路线的数据显示在地图上。
//- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
//{
  //  if (response.route == nil)
    //{
      //  return;
    //}
    // 解析response获取路径信息，具体解析见 Demo
    //self.route = response.route;
    //self.navigationItem.titleView
//}
//实现路径搜索的回调函数
//- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
//{
//    if(response.route == nil)
//    {
//        return;
//    }
//    
//    //通过AMapNavigationSearchResponse对象处理搜索结果
//    NSString *route = [NSString stringWithFormat:@"Navi: %@", response.route];
//    
//    AMapPath *path = response.route.paths[0]; //选择一条路径
//    AMapStep *step = path.steps[0]; //这个路径上的导航路段数组
//    NSLog(@"%@",step.polyline);   //此路段坐标点字符串
//    
//    if (response.count > 0)
//    {
//        //移除地图原本的遮盖
//        //[_mapView removeOverlays:_pathPolylines];
//        //_pathPolylines = nil;
//        
//        // 只显⽰示第⼀条 规划的路径
//        //_pathPolylines = [self polylinesForPath:response.route.paths[0]];
//        NSLog(@"%@",response.route.paths[0]);
//        //添加新的遮盖，然后会触发代理方法进行绘制
//        //[_mapView addOverlays:_pathPolylines];
//    }
//}
- (void)findWayAction:(id)sender {
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc] init];
    //设置起点，我选择了当前位置，mapView有这个属性
    request.origin = [AMapGeoPoint locationWithLatitude:30.26405277 longitude:120.12346029];
    //设置终点，可以选择手点
    request.destination = [AMapGeoPoint locationWithLatitude:30.30446546 longitude:120.08666039];
    //    request.strategy = 2;//距离优先
    //    request.requireExtension = YES;
    //发起路径搜索，发起后会执行代理方法
    //这里使用的是步行路径
    [_searchAPI AMapWalkingRouteSearch:request];
}

@end
