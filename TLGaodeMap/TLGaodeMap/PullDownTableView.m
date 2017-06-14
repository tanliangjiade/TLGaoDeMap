//
//  PullDownTableView.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/14.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "PullDownTableView.h"
#import <Masonry.h>
#import "SearchReultCell.h"

#define KRowHeight 32 // 行高

@interface PullDownTableView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation PullDownTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    [self addSubview:self.tableView];
    // 添加约束
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        //        make.height.equalTo(@0);
    }];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.tableView.mas_bottom);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchReultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    cell.tipModel = self.dataSourceArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedPullDownCellCallback) {
        self.selectedPullDownCellCallback(indexPath, self.dataSourceArr[indexPath.row]);
    }
}

- (void)setDataSourceArr:(NSMutableArray *)dataSourceArr {
    _dataSourceArr = dataSourceArr;
    CGFloat height = 0;
    if (dataSourceArr.count < 8) {
        height = (CGFloat)dataSourceArr.count * KRowHeight;
    }
    else {
        height = 8 * KRowHeight;
    }
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
        [self.tableView reloadData];
    }];
    
    
}

#pragma mark - Lazy Loading
-(UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.rowHeight = KRowHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[SearchReultCell class] forCellReuseIdentifier:@"MyCell"];
    }
    return _tableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
