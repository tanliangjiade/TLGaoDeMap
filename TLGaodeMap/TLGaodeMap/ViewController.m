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
@interface ViewController ()<AMapLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UITextFieldDelegate>
// 初始化AMapLocationManager对象,设置代理。
@property(nonatomic,strong) AMapLocationManager* locationManager;
// 可变的字典
@property(nonatomic,strong) NSMutableDictionary* dic;
// gps按钮
@property(nonatomic,strong) UIButton* gpsButton;
// 校区表格视图
@property(nonatomic,strong) UITableView* campusTableView;
// 左边条
@property(nonatomic,strong) UIBarButtonItem* leftItem;
// 右边条
@property(nonatomic,strong) UIBarButtonItem* rightItem;
// 搜索控制器
//@property(nonatomic,strong) UISearchController* campusSearch;
// 搜索文本框
//@property(nonatomic,strong) UITextField* searchTxt;
@property (nonatomic, weak) TLTextField *searchTxt;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 指定导航栏左边条按钮
    self.leftItem=[[UIBarButtonItem alloc] initWithTitle:@"切换校区" style:UIBarButtonItemStylePlain target:self action:@selector(showView)];
    self.navigationItem.leftBarButtonItem=_leftItem;
    // 指定导航栏右边条按钮
    self.rightItem=[[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem=_rightItem;
    
    TLTextField* searchTet = [[TLTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.7, 30)];
    searchTet.delegate=self;
    self.navigationItem.titleView=searchTet;
    self.searchTxt = searchTet;
    
//    [AMapServices sharedServices].enableHTTPS = YES;
    // 0.初始化地图视图
    self.mapView = [[MAMapView alloc]init];
    self.mapView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    //self.mapView.frame = self.view.bounds;
    [self.view addSubview:_mapView];
    // 指定代理
    self.mapView.delegate=self;
    // 显示用户位置
    self.mapView.showsUserLocation=YES;
    // 设置地图的缩放级别 范围3-19
    [self.mapView setZoomLevel:17.5 animated:YES];
    // ✨设置此 用户跟踪模式 属性地图正常铺开显示
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;// MAUserTrackingModeFollow 1
    // 设置指南针的位置
    self.mapView.compassOrigin = CGPointMake(self.mapView.compassOrigin.x-10, 70);
    
    // 添加搜索
    //self.campusSearch = [[UISearchController alloc] init];
    //self.campusSearch.delegate=self;
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
    
    
}
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

#pragma mark leftBarButton 点击事件方法
- (void)showView
{
    self.campusTableView = [[UITableView alloc] init];
    [self.view addSubview:_campusTableView];
    self.campusTableView.frame = CGRectMake(5, 70, 200, 200);
//    [self.campusTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//    }];
    self.campusTableView.delegate=self;
    self.campusTableView.dataSource=self;
    [self.searchTxt endEditing:YES];
}
#pragma mark RightBarButton 点击事件方法
- (void)search
{
    [self.searchTxt endEditing:YES];
    self.campusTableView.hidden=YES;
}
#pragma campusTableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    return cell;
}
// 辞去第一响应者
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 隐藏tableView
    self.campusTableView.hidden=YES;
    [self.searchTxt endEditing:YES];
}
#pragma SearchControllerDelegate
//- (void)didPresentSearchController:(UISearchController *)searchController
//{
//    searchController.searchBar.showsCancelButton = NO;
//}
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

@end
