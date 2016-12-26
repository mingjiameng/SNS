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

@interface SNSDetailDetectSatellite ()

@property (nonatomic, strong, nonnull) SNSSGTaskExecutionQueue *taskExecutionQueue;
@property (nonatomic, strong, nonnull) SNSSGDPBufferedQueue *dataPackageBufferedQueue;
@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecutionQueue *transmissionTaskQueue;

@property (nonatomic, strong, nullable) SNSSatelliteGraphicTaskExecution *taskExecuting; // 正在执行中的成像任务

@property (nonatomic) FILE *taskExecutionLog;
@property (nonatomic) FILE *dataSendingLog;

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
            [_dataPackageBufferedQueue addDataPackage:dataPackage];
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
    if (_dataPackageBufferedQueue.bufferedFlowSize > MINIMUM_DATA_PACKAGE_COLLECTION_SIZE) {
        SNSSGDPCTTaskExecution *newTask = [[SNSSGDPCTTaskExecution alloc] init];
        SNSSGDataPackgeCollection *newDPC = [[SNSSGDataPackgeCollection alloc] init];
        newDPC.dataPackageCollection = [_dataPackageBufferedQueue productDataPackageCollection];
        newTask.dpc = newDPC;
        
        for (SNSSatelliteAntenna *antenna in self.antennas) {
            if (antenna.type == SNSSatelliteAntennaFunctionTypeSendData) {
                [antenna addSendingTransmissionTask:newTask];
                break;
            }
        }
    }
    
    for (SNSSatelliteAntenna *antenna in self.antennas) {
        [antenna continueAction];
    }
    
}

- (void)antenna:(SNSSatelliteAntenna *)antenna sendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize -= dataPackageCollection.size;
    [self recordSendingData:dataPackageCollection];
}

- (BOOL)antenna:(SNSSatelliteAntenna *)antenna requestConnectionForDpct:(SNSSGDPCTTaskExecution *)dpctTaskExecution
{
    return [self.flowTransportDelegate schedualDPCTransmission:dpctTaskExecution forSatellite:self];
}

- (SNSSGDPBufferedQueue *)dataPackageBufferedQueue
{
    if (!_dataPackageBufferedQueue) {
        _dataPackageBufferedQueue = [[SNSSGDPBufferedQueue alloc] init];
    }
    
    return _dataPackageBufferedQueue;
}

- (void)recordTaskExecution:(SNSSatelliteGraphicTaskExecution *)taskExecuted
{
    NSString *log = [NSString stringWithFormat:@"satellite-%ld execute task-%ld and produced %lf MB data at time %lf", self.uniqueID, taskExecuted.task.uniqueID, taskExecuted.dataProduced, SYSTEM_TIME];
    fprintf(self.taskExecutionLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)recordSendingData:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%ld send %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    fprintf(self.dataSendingLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (FILE *)taskExecutionLog
{
    if (_taskExecutionLog == NULL) {
        NSString *taskExecutionLogFilePath = [NSString stringWithFormat:@"/Users/zkey/Desktop/science/sns_output/detail_detect_satellite_%03ld_task_execution_log.txt", self.uniqueID];
        _taskExecutionLog = fopen([taskExecutionLogFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_taskExecutionLog != NULL);
    }
    
    return _taskExecutionLog;
}

- (FILE *)dataSendingLog
{
    if (_dataSendingLog == NULL) {
        NSString *dataSendingLogFilePath = [NSString stringWithFormat:@"/Users/zkey/Desktop/science/sns_output/detail_detect_satellite_%03ld_data_sending_log.txt", self.uniqueID];
        _dataSendingLog = fopen([dataSendingLogFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_dataSendingLog != NULL);
    }
    
    return _dataSendingLog;
}

- (SNSSGTaskExecutionQueue *)taskExecutionQueue
{
    if (_taskExecutionQueue == nil) {
        _taskExecutionQueue = [[SNSSGTaskExecutionQueue alloc] init];
    }
    
    return _taskExecutionQueue;
}

- (void)dealloc
{
    fclose(self.taskExecutionLog);
    fclose(self.dataSendingLog);
}

@end
