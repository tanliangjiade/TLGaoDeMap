//
//  AMapSearchObject+SearchObject.m
//  TLGaodeMap
//
//  Created by TAN on 2017/6/13.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import "AMapSearchObject+SearchObject.h"

@implementation AMapSearchObject (SearchObject)
//周边搜索（多边形范围搜索）
+ (void)searchPolygon:(NSString *)keywords andPiontsArray:(NSArray *)array andSearchApi:(AMapSearchAPI *)searchAPI
{
    AMapPOIPolygonSearchRequest *polygon = [[AMapPOIPolygonSearchRequest alloc]init];
    
    AMapGeoPolygon *polygonS = [[AMapGeoPolygon alloc]init];
    polygonS.points = array;
    polygon.polygon = polygonS;
    polygon.keywords = keywords;
    [searchAPI AMapPOIPolygonSearch:polygon];
}

/**
 *输入提示搜索
 */
//输入提示搜索
+ (void)searchKeywords:(NSString *)keywords andCity:(NSString *)city andSearchApi:(AMapSearchAPI *)searchAPI
{
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = keywords;
    tipsRequest.city = city;
    //    发起输入提示搜索
    [searchAPI AMapInputTipsSearch: tipsRequest];
}

@end
