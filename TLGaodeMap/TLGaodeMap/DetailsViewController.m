//
//  DetailsViewController.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/20.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "DetailsViewController.h"
#import <Masonry.h>
#import "ViewController.h"
@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    [self.view setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1]];
    UIImageView* poiImageView = [[UIImageView alloc] init];
    [self.view addSubview:poiImageView];
    poiImageView.frame = CGRectMake(0, 0, self.view.frame.size.width,300);
    if (self.imageView)
    {
        poiImageView.image = _imageView.image;
    }
    else
    {
        poiImageView.image = [UIImage imageNamed:@"timg"];
    }
    UIView* poiNameView = [[UIView alloc] init];
    poiNameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:poiNameView];
    [poiNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(poiImageView.mas_bottom).offset(0);
        make.width.equalTo(self.view.mas_width);
        make.height.offset(50);
    }];
    UILabel* poiNameLab = [[UILabel alloc] init];
    [poiNameView addSubview:poiNameLab];
    //poiNameLab.text = @"好食堂(东山弄店)";
    poiNameLab.text = _name;
    [poiNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(poiNameView.mas_left).offset(10);
        make.centerY.equalTo(poiNameView.mas_centerY);
    }];
    
    UIView* poiAddressView = [[UIView alloc] init];
    poiAddressView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:poiAddressView];
    [poiAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(poiNameView.mas_bottom).offset(5);
        make.width.equalTo(self.view.mas_width);
        make.height.offset(40);
    }];
    
    UIImageView* mapMark = [[UIImageView alloc] init];
    [poiAddressView addSubview:mapMark];
    mapMark.image = [UIImage imageNamed:@"map-mark"];
    [mapMark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(poiAddressView.mas_left).offset(10);
        make.centerY.equalTo(poiAddressView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(16, 22));
    }];
    
    UILabel* poiAddressLab = [[UILabel alloc] init];
    [poiAddressView addSubview:poiAddressLab];
    //poiAddressLab.text = @"玉古路137号(玉泉饭店后门)";
    poiAddressLab.text = _address;
    poiAddressLab.font = [UIFont systemFontOfSize:13];
    [poiAddressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mapMark.mas_right).offset(15);
        make.centerY.equalTo(poiAddressView.mas_centerY);
    }];

}
@end
