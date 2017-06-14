//
//  SearchReultCell.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/14.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "SearchReultCell.h"

@interface SearchReultCell ()
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@end

@implementation SearchReultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self prepareUI];
    }
    return self;
}
- (void)prepareUI {
    self.backgroundColor = [UIColor whiteColor];
    self.leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-mark"]];//map-mark searchbar_textfield_search_icon
    self.centerLabel = [[UILabel alloc] init];
    self.centerLabel.textColor = [UIColor blackColor];
    self.centerLabel.font = [UIFont systemFontOfSize:14];
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.textColor = [UIColor grayColor];
    self.rightLabel.font = [UIFont systemFontOfSize:12];
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.leftImageView];
    [self.contentView addSubview:self.centerLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.bottomLine];
    
    // 设置约束
    self.leftImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.leading.equalTo(self.mas_leading).offset(8);
        make.centerY.equalTo(self);
    }];
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.leftImageView.mas_trailing).offset(10);
        make.centerY.equalTo(self);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.centerLabel.mas_trailing).offset(5);
        make.trailing.equalTo(self).offset(-8);
        make.centerY.equalTo(self);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.3);
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

- (void)setTipModel:(AMapTip *)tipModel {
    _tipModel = tipModel;
    self.centerLabel.text = _tipModel.name;
    self.rightLabel.text = _tipModel.district;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
