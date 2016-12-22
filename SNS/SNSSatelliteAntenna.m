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

- (void)addSendingTransmissionTask:(SNSSGDPCTTaskExecution *)task
{
    task.fromAntenna = self;
    [self.dpcSendingTaskQueue addTransmissionTask:task];
}

- (void)continueAction
{
    if (_type == SNSSatelliteAntennaFunctionTypeSendData) {
        [self sendDataBehavior];
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
    
}

@end
