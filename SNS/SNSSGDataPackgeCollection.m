//
//  SNSSGDataPackgeCollection.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDataPackgeCollection.h"

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

@end
