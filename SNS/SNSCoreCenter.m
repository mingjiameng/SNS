//
//  SNSCoreCenter.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSCoreCenter.h"

#import "SNSNetworkManageCenter.h"
#import "SNSTaskDistributionCenter.h"

#import "SNSDetailDetectSatellite.h"
#import "SNSDelaySatellite.h"

@interface SNSCoreCenter ()

@property (nonatomic, strong, nonnull) SNSTaskDistributionCenter *taskDistributionCenter;
@property (nonatomic, strong, nonnull) SNSNetworkManageCenter *networkManageCenter;

@property (nonatomic) SNSSatelliteTime systemTime;

@property (nonatomic, strong, nonnull) NSArray<SNSDetailDetectSatellite *> *detailDetectSatellites;
@property (nonatomic, strong, nonnull) NSArray<SNSDelaySatellite *> *delaySatellites;

@end


@implementation SNSCoreCenter

+ (instancetype)sharedCoreCenter
{
    dispatch_once_t onceToken;
    static SNSCoreCenter *coreCenter = nil;
    
    dispatch_once(&onceToken, ^{
        coreCenter = [[SNSCoreCenter alloc] init];
    });
    
    return coreCenter;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _taskDistributionCenter = [SNSTaskDistributionCenter sharedTaskDistributionCenter];
        _networkManageCenter = [SNSNetworkManageCenter sharedNetworkManageCenter];
    }
    
    return self;
}

- (void)fire
{
    _systemTime = 0;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    while (_systemTime < EXPECTED_SIMULATION_TIME) {
        _systemTime += SIMULATION_TIME_STEP;
        dispatch_sync(globalQueue, ^{
            for (SNSSatellite *satellite in self.detailDetectSatellites) {
                [satellite updateState];
            }
            
            for (SNSSatellite *satellite in self.delaySatellites) {
                [satellite updateState];
            }
        });
    }
}

//- (NSArray<SNSDetailDetectSatellite *> *)detailDetectSatellites
//{
//    
//}
//
//- (NSArray<SNSDelaySatellite *> *)delaySatellites
//{
//    
//}

@end
