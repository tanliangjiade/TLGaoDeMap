//
//  AMapSearchObject+SearchObject.h
//  TLGaodeMap
//
//  Created by TAN on 2017/6/13.
//  Copyright © 2017年 zfsoft.com. All rights reserved.
//

#import <AMapSearchKit/AMapSearchKit.h>

@interface AMapSearchObject (SearchObject)
/**
 *POI搜索
 */
//周边搜索（多边形范围搜索）
+ (void)searchPolygon:(NSString *)keywords andPiontsArray:(NSArray *)array andSearchApi:(AMapSearchAPI *)searchAPI;
/**
 *输入提示搜索
 */
//关键字搜索
+ (void)searchKeywords:(NSString *)keywords andCity:(NSString *)city andSearchApi:(AMapSearchAPI *)Api;

@end
