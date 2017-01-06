//
//  SNSUserSatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSUserSatellite.h"
#import "SNSSGDPBufferedQueue.h"
#import "SNSSGDataPackgeCollection.h"

@implementation SNSUserSatellite

- (void)updateState
{
    [super updateState];
    
    [self executeTaskBehavior];
    [self sendDataBehavior];
}

- (void)executeTaskBehavior
{
    
}

- (void)sendDataBehavior
{
    
}

- (FILE *)taskExecutionLog
{
    if (_taskExecutionLog == NULL) {
        NSString *path = [NSString stringWithFormat:@"%@detail_detect_satellite_%03d_task_execution_log.txt", FILE_OUTPUT_PATH_PREFIX_STRING, self.uniqueID];
        _taskExecutionLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_taskExecutionLog != NULL);
    }
    
    return _taskExecutionLog;
}

- (FILE *)dataSendingLog
{
    if (_dataSendingLog == NULL) {
        NSString *path = [NSString stringWithFormat:@"%@detail_detect_satellite_%03d_data_sending_log.txt", FILE_OUTPUT_PATH_PREFIX_STRING, self.uniqueID];
        _dataSendingLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_dataSendingLog != NULL);
    }
    
    return _dataSendingLog;
}

- (void)recordTaskExecution:(SNSSatelliteGraphicTaskExecution *)taskExecuted
{
    NSString *log = [NSString stringWithFormat:@"satellite-%d execute task-%d and produced %lf MB data at time %lf", self.uniqueID, taskExecuted.task.uniqueID, taskExecuted.dataProduced, SYSTEM_TIME];
    fprintf(self.taskExecutionLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)recordSendingData:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%d send %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    
    fprintf(self.dataSendingLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)antenna:(SNSSatelliteAntenna *)antenna didSendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    [self.flowTransportDelegate satellite:self didSendPackageCollection:dataPackageCollection];
    
    self.bufferedDataSize -= dataPackageCollection.size;
    [self recordSendingData:dataPackageCollection];
}

- (void)antenna:(SNSSatelliteAntenna *)antenna didFailToSendDataPackageCollection:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection
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

- (SNSNetworkFlowSize)dataCanBeSendedInTime:(SNSSatelliteTime)time
{
    SNSUserSatelliteAntenna *sendingAntenna = nil;
    for (SNSUserSatelliteAntenna *antenna in self.antennas) {
        if (antenna.functionType == SNSAntennaFunctionTypeSendData) {
            sendingAntenna = antenna;
            break;
        }
    }
    
    if (sendingAntenna == nil) {
        return -1;
    }
    
    SNSNetworkFlowSize limitedFlowSize = time * sendingAntenna.bandWidth;
    return [self.dataPackageBufferedQueue dataCanBePackagedWithInLimit:limitedFlowSize];
}

- (SNSSGDataPackgeCollection *)produceDpcCanBeSendedInTime:(SNSSatelliteTime)time
{
    SNSUserSatelliteAntenna *sendingAntenna = nil;
    for (SNSUserSatelliteAntenna *antenna in self.antennas) {
        if (antenna.functionType == SNSAntennaFunctionTypeSendData) {
            sendingAntenna = antenna;
            break;
        }
    }
    
    if (sendingAntenna == nil) {
        return nil;
    }
    
    SNSNetworkFlowSize limitedFlowSize = time * sendingAntenna.bandWidth;
    return [self.dataPackageBufferedQueue produceDpcWithInLimit:limitedFlowSize];
}

- (void)stop
{
    fclose(self.taskExecutionLog);
    fclose(self.dataSendingLog);
}

@end
