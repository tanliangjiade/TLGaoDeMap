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
@interface ViewController : UIViewController<MAMapViewDelegate>

@property(nonatomic,strong) MAMapView* mapView;
@end

