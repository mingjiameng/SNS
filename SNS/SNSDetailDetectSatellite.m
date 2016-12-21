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



@interface SNSDetailDetectSatellite ()

@property (nonatomic, strong, nonnull) SNSSGTaskExecutionQueue *taskExecutionQueue;
@property (nonatomic, strong, nonnull) SNSSGDPBufferedQueue *dataPackageBufferedQueue;
@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecutionQueue *transmissionTaskQueue;

@property (nonatomic, strong, nullable) SNSSatelliteGraphicTaskExecution *taskExecuting; // 正在执行中的成像任务
@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecution *dpcSending;


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
    if (_dataPackageBufferedQueue.bufferedFlowSize > MINIMUM_DATA_PACKAGE_COLLECTION_SIZE) {
        SNSSGDPCTTaskExecution *newTask = [[SNSSGDPCTTaskExecution alloc] init];
        newTask.dataPackageCollection = [_dataPackageBufferedQueue productDataPackageCollection];
        [_transmissionTaskQueue addTransmissionTask:newTask];
    }
    
    if (_dpcSending == nil) {
        _dpcSending = [_transmissionTaskQueue pop];
    }
    else {
        if (_dpcSending.state == SNSSGDPCTTaskExecutionStateCompleted) {
            _dpcSending = [_transmissionTaskQueue pop];
        }
        else {
            [_dpcSending continueAction];
        }
    }
    
}


- (SNSSGDPBufferedQueue *)dataPackageBufferedQueue
{
    if (!_dataPackageBufferedQueue) {
        _dataPackageBufferedQueue = [[SNSSGDPBufferedQueue alloc] init];
    }
    
    return _dataPackageBufferedQueue;
}



@end
