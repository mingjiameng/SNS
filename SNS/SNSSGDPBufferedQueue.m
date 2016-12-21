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
@property (nonatomic, strong, nonnull) NSMutableArray<SNSSatelliteGraphicDataPackage *> *bufferedDataPackage;

@end


@implementation SNSSGDPBufferedQueue

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _bufferedFlowSize = 0;
        _bufferedDataPackage = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

- (void)addDataPackage:(SNSSatelliteGraphicDataPackage *)dataPackage
{
    _bufferedFlowSize += dataPackage.size;
    [_bufferedDataPackage addObject:dataPackage];
}

- (NSArray<SNSSatelliteGraphicDataPackage *> *)productDataPackageCollection
{
    NSArray *dpCollection = [NSArray arrayWithArray:_bufferedDataPackage];
    
    [_bufferedDataPackage removeAllObjects];
    _bufferedFlowSize = 0;
    
    return dpCollection;
}

@end
