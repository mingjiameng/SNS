//
//  SNSUserSatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSUserSatellite.h"
#import "SNSSGDPBufferedQueue.h"

@implementation SNSUserSatellite

- (FILE *)taskExecutionLog
{
    if (_taskExecutionLog == NULL) {
        NSString *taskExecutionLogFilePath = [NSString stringWithFormat:@"/Users/zkey/Desktop/science/sns_output/detail_detect_satellite_%03d_task_execution_log.txt", self.uniqueID];
        _taskExecutionLog = fopen([taskExecutionLogFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_taskExecutionLog != NULL);
    }
    
    return _taskExecutionLog;
}

- (FILE *)dataSendingLog
{
    if (_dataSendingLog == NULL) {
        NSString *dataSendingLogFilePath = [NSString stringWithFormat:@"/Users/zkey/Desktop/science/sns_output/detail_detect_satellite_%03d_data_sending_log.txt", self.uniqueID];
        _dataSendingLog = fopen([dataSendingLogFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_dataSendingLog != NULL);
    }
    
    return _dataSendingLog;
}

- (void)recordTaskExecution:(SNSSatelliteGraphicTaskExecution *)taskExecuted
{
    NSString *log = [NSString stringWithFormat:@"satellite-%d execute task-%ld and produced %lf MB data at time %lf", self.uniqueID, taskExecuted.task.uniqueID, taskExecuted.dataProduced, SYSTEM_TIME];
    fprintf(self.taskExecutionLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)recordSendingData:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%d send %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    
    fprintf(self.dataSendingLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)antenna:(SNSSatelliteAntenna *)antenna didSendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize -= dataPackageCollection.size;
    [self recordSendingData:dataPackageCollection];
}

- (void)antenna:(SNSSatelliteAntenna *)antenna failToSendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    [self.dataPackageBufferedQueue insertDataPackage:dataPackageCollection.dataPackageCollection];
}

- (SNSSGDPBufferedQueue *)dataPackageBufferedQueue
{
    if (!_dataPackageBufferedQueue) {
        _dataPackageBufferedQueue = [[SNSSGDPBufferedQueue alloc] init];
    }
    
    return _dataPackageBufferedQueue;
}

- (void)stop
{
    fclose(self.taskExecutionLog);
    fclose(self.dataSendingLog);
}

@end
