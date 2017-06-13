//
//  SearchViewController.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/13.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "SearchViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "ViewController.h"
#import "MAMapView+MapView.h"
@interface SearchViewController ()

@end

@implementation SearchViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self == nil)
    {
        return nil;
    }
    self.view.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 200);
    self.mapView = [[MAMapView alloc] init];
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    self.searchList = [NSMutableArray array];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchList count])
    {
        return [self.searchList count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* searchStr = @"search";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:searchStr];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchStr];
    }
    AMapAOI* pio = [self.searchList objectAtIndex:indexPath.row];
    cell.textLabel.text = pio.name;
    cell.detailTextLabel.text = pio.adcode;
//    cell.detailTextLabel.text = pio.address;
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
