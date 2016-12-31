//
//  SNSDetailDetectSatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDetailDetectSatellite.h"


#import "SNSSatelliteGraphicTaskExecution.h"
#import "SNSSatelliteGraphicDataPackage.h"
#import "SNSSGDPCTTaskExecution.h"

#import "SNSSGTaskExecutionQueue.h"
#import "SNSSGDPBufferedQueue.h"
#import "SNSSGDPCTTaskExecutionQueue.h"

#import "SNSSatelliteAntenna.h"
#import "SNSUserSatelliteAntenna.h"

@interface SNSDetailDetectSatellite ()

@property (nonatomic, strong, nonnull) SNSSGTaskExecutionQueue *taskExecutionQueue;
@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecutionQueue *transmissionTaskQueue;

@property (nonatomic, strong, nullable) SNSSatelliteGraphicTaskExecution *taskExecuting; // 正在执行中的成像任务

@end



@implementation SNSDetailDetectSatellite

- (void)updateState
{
    [super updateState];
    
    [self executeTaskBehavior];
    [self sendDataBehavior];
}

- (void)executeTaskBehavior
{
    if (_taskExecuting != nil) {
        if (_taskExecuting.state == SNSSatelliteGraphicTaskExecutionStateCompleted) {
            SNSSatelliteGraphicDataPackage *dataPackage = [[SNSSatelliteGraphicDataPackage alloc] init];
            dataPackage.taskExecution = _taskExecuting;
            [self.dataPackageBufferedQueue addDataPackage:dataPackage];
            self.bufferedDataSize += dataPackage.size;
            [self recordTaskExecution:_taskExecuting];
            _taskExecuting = nil;
        }
        else {
            [_taskExecuting continueAction];
        }
    }
    else {
        _taskExecuting = [self.taskExecutionQueue pop];
        if (_taskExecuting == nil) {
            __weak typeof(self) weakSelf = self;
            NSArray *newTasks = [self.taskQueueDataSource newTaskExecutionQueueForSatellite:weakSelf];
            [self.taskExecutionQueue add:newTasks];
        }
    }
}

- (void)sendDataBehavior
{
    SNSUserSatelliteAntenna *sendingAntenna = nil;
    for (SNSUserSatelliteAntenna *antenna in self.antennas) {
        if (antenna.type == SNSSatelliteAntennaFunctionTypeSendData) {
            sendingAntenna = antenna;
            break;
        }
    }
    
    if (sendingAntenna == nil) {
        return;
    }
    
    // 如果有正在传输的dpct，就继续传输
    if (sendingAntenna.isSending) {
        [sendingAntenna continueAction];
    }
    else if (self.dataPackageBufferedQueue.bufferedFlowSize > MINIMUM_DATA_PACKAGE_COLLECTION_SIZE) {
        SNSSGDPCTTaskExecution *dpct = [self.flowTransportDelegate schedualDataTransmissionForSatellite:self];
        if (dpct != nil) {
            [self.dataPackageBufferedQueue removeDataPackage:dpct.dpc.dataPackageCollection];
            [sendingAntenna schedualSendingTransmissionTask:dpct];
        }
    }
    
}

- (SNSSGTaskExecutionQueue *)taskExecutionQueue
{
    if (_taskExecutionQueue == nil) {
        _taskExecutionQueue = [[SNSSGTaskExecutionQueue alloc] init];
    }
    
    return _taskExecutionQueue;
}



@end
