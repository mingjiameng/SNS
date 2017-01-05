//
//  SNSSGDPBufferedQueue.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDPBufferedQueue.h"

#import "SNSSGDataPackgeCollection.h"

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

- (void)removeDataPackageIn:(NSArray<SNSSatelliteGraphicDataPackage *> *)dataPackages
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
    for (SNSSatelliteGraphicDataPackage *dp in dataPackage) {
        [self.bufferedDataPackages insertObject:dp atIndex:0];
    }
}

- (SNSNetworkFlowSize)dataCanBePackagedWithInLimit:(SNSNetworkFlowSize)flowLimit
{
    SNSNetworkFlowSize size = 0;
    SNSNetworkFlowSize toBeSize = 0;
    for (SNSSatelliteGraphicDataPackage *dp in self.bufferedDataPackages) {
        toBeSize = size + dp.size;
        if (toBeSize < flowLimit && toBeSize < MAXIMUM_DATA_PACKAGE_COLLECTION_SIZE) {
            size = toBeSize;
        }
        else {
            break;
        }
    }
    
    return size;
}

- (nonnull SNSSGDataPackgeCollection *)produceDpcWithInLimit:(SNSNetworkFlowSize)flowLimit
{
    SNSNetworkFlowSize size = 0;
    SNSNetworkFlowSize toBeSize = 0;
    NSMutableArray *dps = [[NSMutableArray alloc] init];
    for (SNSSatelliteGraphicDataPackage *dp in self.bufferedDataPackages) {
        toBeSize = size + dp.size;
        if (toBeSize < flowLimit && toBeSize < MAXIMUM_DATA_PACKAGE_COLLECTION_SIZE) {
            size = toBeSize;
            [dps addObject:dp];
        }
        else {
            break;
        }
    }
    
    SNSSGDataPackgeCollection *dpc = [[SNSSGDataPackgeCollection alloc] init];
    dpc.dataPackageCollection = dps;
    
    return dpc;
}

@end
