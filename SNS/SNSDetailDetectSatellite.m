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
{
    SNSSatelliteTime _connectionWaitingTime;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _connectionWaitingTime = 0;
    }
    
    return self;
}

- (void)executeTaskBehavior
{
    if (_taskExecuting != nil) {
        if (_taskExecuting.state == SNSSatelliteGraphicTaskExecutionStateCompleted) {
            SNSSatelliteGraphicDataPackage *dataPackage = [[SNSSatelliteGraphicDataPackage alloc] init];
            dataPackage.uniqueID = [self.flowTransportDelegate newDpTag];
            dataPackage.taskExecution = _taskExecuting;
            [self.dataPackageBufferedQueue addDataPackage:dataPackage];
            self.bufferedDataSize += dataPackage.size;
//            if (self.uniqueID == 1) {
//                NSLog(@"satellite-%d buffured data-%lf after execute task-%d", self.uniqueID, self.bufferedDataSize, _taskExecuting.uniqueID);
//            }
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
    [super sendDataBehavior];
    
    SNSUserSatelliteAntenna *sendingAntenna = nil;
    for (SNSUserSatelliteAntenna *antenna in self.antennas) {
        if (antenna.functionType == SNSAntennaFunctionTypeSendData) {
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
    else if (self.bufferedDataSize > MINIMUM_DATA_PACKAGE_COLLECTION_SIZE) {
//        if (self.uniqueID == 1) {
//            NSLog(@"satellite-1 require network connection at time %lf", SYSTEM_TIME);
//        }
        SNSSGDPCTTaskExecution *dpct = [self.flowTransportDelegate schedualDataTransmissionForSatellite:self withSendingAntenna:sendingAntenna];
        if (dpct != nil) {
            if (_connectionWaitingTime > 0) {
                --_connectionWaitingTime;
            }
            else {
                [self.dataPackageBufferedQueue removeDataPackageIn:dpct.dpc.dataPackageCollection];
                //NSLog(@"satellite-%d buffered %lf data success request connection between %@-%d and %@-%d at time %lf",self.uniqueID, self.bufferedDataSize, [dpct.fromAntenna class], dpct.fromAntenna.uniqueID, [dpct.toAntenna class], dpct.toAntenna.uniqueID, SYSTEM_TIME);
                [sendingAntenna schedualSendingTransmissionTask:dpct];
            }
//            if (self.uniqueID == 1) {
//                NSLog(@"satellite-1 successfully require network connection at time %lf", SYSTEM_TIME);
//            }
        }
        else {
            _connectionWaitingTime = NETWORK_CONNECTION_REQUIREMENT_TIME_INTERVEL;
//            if (self.uniqueID == 1) {
//                NSLog(@"satellite-1 fail to require network connection at time %lf", SYSTEM_TIME);
//            }
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
