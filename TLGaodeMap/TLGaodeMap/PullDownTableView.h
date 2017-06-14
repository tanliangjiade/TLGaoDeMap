//
//  PullDownTableView.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/14.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedPullDownCellCallback)(NSIndexPath *indexPath, id selectedObj) ;
@interface PullDownTableView : UIView
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (nonatomic, copy) SelectedPullDownCellCallback selectedPullDownCellCallback;

@end
