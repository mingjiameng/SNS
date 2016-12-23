//
//  SNSTaskDistributionCenter.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSTaskDistributionCenter.h"

#import "SNSDetailDetectSatellite.h"

@implementation SNSTaskDistributionCenter

+ (instancetype)sharedTaskDistributionCenter
{
    dispatch_once_t onceToken;
    static SNSTaskDistributionCenter *taskDistributionCenter = nil;
    
    dispatch_once(&onceToken, ^{
        taskDistributionCenter = [[SNSTaskDistributionCenter alloc] init];
    });
    
    return taskDistributionCenter;
}

- (instancetype)init
{
    self = [super init];
    
    
    
    return self;
}

- (NSArray<SNSSatelliteGraphicTaskExecution *> *)newTaskExecutionQueueForSatellite:(SNSUserSatellite *)userSatellite
{
    if (![userSatellite isKindOfClass:[SNSDetailDetectSatellite class]]) {
        return [[NSArray alloc] init];
    }
    
    
    // TODO 任务分配算法
    return [[NSArray alloc] init];
}



@end
