//
//  ResultPlaceCell.m
//  DaChe
//
//  Created by 张森明 on 16/8/22.
//  Copyright © 2016年 666GPS. All rights reserved.
//

#import "ResultPlaceCell.h"

@interface ResultPlaceCell ()
@property (strong, nonatomic) UILabel *name_lbl;
@property (strong, nonatomic) UILabel *adress_lbl;

@end

@implementation ResultPlaceCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-mark"]];//map-mark fuwu_biaozhudian_lan
        self.name_lbl = [[UILabel alloc] init];
        self.name_lbl.font = [UIFont systemFontOfSize:14];
        self.adress_lbl = [[UILabel alloc] init];
        self.adress_lbl.font = [UIFont systemFontOfSize:13];
        self.adress_lbl.textColor = [UIColor grayColor];
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:iconView];
        [self.contentView addSubview:self.name_lbl];
        [self.contentView addSubview:self.adress_lbl];
        [self.contentView addSubview:bottomLine];
        
        // 设置约束
        self.translatesAutoresizingMaskIntoConstraints = NO;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.name_lbl.translatesAutoresizingMaskIntoConstraints = NO;
        self.adress_lbl.translatesAutoresizingMaskIntoConstraints = NO;
        bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(10);
            make.size.mas_equalTo(CGSizeMake(16, 22));
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.name_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(8);
            make.leading.equalTo(iconView.mas_trailing).offset(15);
            make.trailing.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView.mas_centerY).offset(-4);
        }];
        [self.adress_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_centerY).offset(4);
            make.leading.equalTo(iconView.mas_trailing).offset(15);
            make.trailing.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView).offset(-8);
        }];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.equalTo(self.contentView);
            make.height.mas_equalTo(0.3);
        }];

    }
    return self;
}


- (void)setPlace:(AMapPOI *)place {
    _place = place;
    self.name_lbl.text = _place.name;
    self.adress_lbl.text = _place.address;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
