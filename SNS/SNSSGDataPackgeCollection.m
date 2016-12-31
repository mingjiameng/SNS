//
//  SNSSGDataPackgeCollection.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDataPackgeCollection.h"

@interface SNSSGDataPackgeCollection ()

@property (nonatomic, nonnull, strong) NSMutableArray<SNSRouteRecord *> *routeRecords;

@end

@implementation SNSSGDataPackgeCollection

- (void)setDataPackageCollection:(NSArray<SNSSatelliteGraphicDataPackage *> *)dataPackageCollection
{
    _dataPackageCollection = dataPackageCollection;
    
    double flowSize = 0;
    for (SNSSatelliteGraphicDataPackage *dp in _dataPackageCollection) {
        flowSize += dp.size;
    }
    
    _size = flowSize;
}

- (NSMutableArray <SNSRouteRecord *> *)routeRecords
{
    if (_routeRecords == nil) {
        _routeRecords = [[NSMutableArray alloc] init];
    }
    
    return _routeRecords;
}

- (void)clearRouteRecord
{
    [self.routeRecords removeAllObjects];
}

- (void)addRouteRecord:(SNSRouteRecord *)record
{
    [self.routeRecords addObject:record];
}

@end
