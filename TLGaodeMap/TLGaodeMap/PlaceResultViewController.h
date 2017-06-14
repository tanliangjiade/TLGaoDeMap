//
//  PlaceResultViewController.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/14.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMapSearchObject+SearchObject.h"
/// 选择地点后的代理
@protocol SelectedPlaceDelegate<NSObject>

- (void)cellDidClickCallbackWith:(AMapPOI *)place;

@end

@interface PlaceResultViewController : UITableViewController
@property (nonatomic, weak) id<SelectedPlaceDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@end
