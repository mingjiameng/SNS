//
//  SNSSGDPCTTaskExecutionQueue.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDPCTTaskExecutionQueue.h"

@interface SNSSGDPCTTaskExecutionQueue ()

@property (nonatomic, strong, nonnull) NSMutableArray<SNSSGDPCTTaskExecution *> *dpctArray;

@end


@implementation SNSSGDPCTTaskExecutionQueue

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _dpctArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (SNSSGDPCTTaskExecution *)pop
{
    SNSSGDPCTTaskExecution *task = [_dpctArray firstObject];
    
    if (task != nil) {
        [_dpctArray removeObjectAtIndex:0];
    }
    
    return task;
}

- (void)addTransmissionTask:(SNSSGDPCTTaskExecution *)task
{
    [_dpctArray addObject:task];
}

- (SNSSatelliteTime)expectedEndTime
{
    SNSSGDPCTTaskExecution *dpct = [_dpctArray lastObject];
    if (dpct == nil) {
        return SYSTEM_TIME;
    }
    
    return dpct.transportAction.ExpectedStartTime + dpct.transportAction.expectedTimeCost + 1.0f;
}

@end
