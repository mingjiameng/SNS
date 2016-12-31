//
//  SNSSGDPBufferedQueue.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDPBufferedQueue.h"

@interface SNSSGDPBufferedQueue ()

@property (nonatomic) SNSNetworkFlowSize bufferedFlowSize;
@property (nonatomic, strong, nonnull) NSMutableArray<SNSSatelliteGraphicDataPackage *> *bufferedDataPackages;

@end


@implementation SNSSGDPBufferedQueue

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _bufferedFlowSize = 0;
        _bufferedDataPackages = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

- (void)addDataPackage:(SNSSatelliteGraphicDataPackage *)dataPackage
{
    _bufferedFlowSize += dataPackage.size;
    [_bufferedDataPackages addObject:dataPackage];
}


- (NSArray<SNSSatelliteGraphicDataPackage *> *)productDataPackageCollection
{
    NSArray *dpCollection = [NSArray arrayWithArray:_bufferedDataPackages];
    
    [_bufferedDataPackages removeAllObjects];
    _bufferedFlowSize = 0;
    
    return dpCollection;
}

- (void)removeDataPackage:(NSArray<SNSSatelliteGraphicDataPackage *> *)dataPackages
{
    NSUInteger index;
    SNSSatelliteGraphicDataPackage *dp_to_remove = nil;
    for (SNSSatelliteGraphicDataPackage *dp in self.bufferedDataPackages) {
        for (index = 0; index < self.bufferedDataPackages.count; ++index) {
            dp_to_remove = [self.bufferedDataPackages objectAtIndex:index];
            if (dp_to_remove.uniqueID == dp.uniqueID) {
                break;
            }
        }
        
        if (index < self.bufferedDataPackages.count) {
            [self.bufferedDataPackages removeObjectAtIndex:index];
        }
    }
    
}

- (void)insertDataPackage:(NSArray<SNSSatelliteGraphicDataPackage *> *)dataPackage
{
    
}

@end
