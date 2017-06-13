//
//  SearchViewController.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/13.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
@interface SearchViewController : UITableViewController
@property(nonatomic,strong) NSMutableArray * searchList;// 搜索列表数组
@property(nonatomic,strong) MAMapView      * mapView;   // 地图视图
@end
