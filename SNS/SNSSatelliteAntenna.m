//
//  SNSSatelliteAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteAntenna.h"


@interface SNSSatelliteAntenna ()

@end


@implementation SNSSatelliteAntenna

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _dpcSendingTaskQueue = [[SNSSGDPCTTaskExecutionQueue alloc] init];
        _dpcReceivingTaskQueue = [[SNSSGDPCTTaskExecutionQueue alloc] init];
    }
    
    return self;
}

- (void)addSendingTransmissionTask:(SNSSGDPCTTaskExecution *)task
{
    task.fromAntenna = self;
    task.state = SNSSGDPCTTaskExecutionStateQueueing;
    [self.dpcSendingTaskQueue addTransmissionTask:task];
}

- (void)continueAction
{
    if (_type == SNSSatelliteAntennaFunctionTypeSendData) {
        [self sendDataBehavior];
        //NSLog(@"continue sending data action");
    }
    else if (_type == SNSSatelliteAntennaFunctionTypeReceiveData) {
        [self receiveDataBehavior];
    }
    else if (_type == SNSSatelliteAntennaFunctionTypeSendAndReceiveData) {
        [self receiveDataBehavior];
        [self sendDataBehavior];
    }
}

- (void)receiveDataBehavior
{
    
}

- (void)sendDataBehavior
{
    //NSLog(@"go into sending data behavior");
}

@end
