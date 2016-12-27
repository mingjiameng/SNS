//
//  SNSDelaySatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDelaySatellite.h"

#import "SNSMath.h"
#import "SNSDelaySatelliteAntenna.h"

@interface SNSDelaySatellite ()

@property (nonatomic) FILE *dataReceiveLog;
@property (nonatomic) FILE *dataSendLog;

@end



@implementation SNSDelaySatellite

- (void)updateState
{
    [super updateState];
    
    //NSLog(@"satellite-%ld buffered data %lf MB", self.uniqueID, self.bufferedDataSize);
    
    for (SNSSatelliteAntenna *antenna in self.antennas) {
        [antenna continueAction];
    }
}

- (void)antenna:(SNSSatelliteAntenna *)antenna sendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize -= dataPackageCollection.size;
    [self recordDataSend:dataPackageCollection];
}

- (void)antenna:(SNSSatelliteAntenna *)antenna receiveDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize += dataPackageCollection.size;
    [self recordDataReceive:dataPackageCollection];
    for (SNSSatelliteAntenna *antennaSending in self.antennas) {
        if (antennaSending.type == SNSSatelliteAntennaFunctionTypeSendData) {
            SNSSGDPCTTaskExecution *dpctTaskExecution = [[SNSSGDPCTTaskExecution alloc] init];
            dpctTaskExecution.dpc = dataPackageCollection;
            [antennaSending addSendingTransmissionTask:dpctTaskExecution];
        }
    }
}

- (BOOL)antenna:(SNSSatelliteAntenna *)antenna confirmConnectionWithAntenna:(SNSSatelliteAntenna *)anotherAntenna
{
    // 有固定连接
    if ([antenna isKindOfClass:[SNSDelaySatelliteAntenna class]] && [anotherAntenna isKindOfClass:[SNSDelaySatelliteAntenna class]]) {
        SNSDelaySatelliteAntenna *from = (SNSDelaySatelliteAntenna *)anotherAntenna;
        if (from.sideHop == antenna) {
            return TRUE;
        }
    }
    
    // 可视
    if ([antenna isKindOfClass:[SNSDelaySatelliteAntenna class]] && [anotherAntenna.owner isKindOfClass:[SNSUserSatellite class]]) {
        SNSSatelliteTime time = SYSTEM_TIME;
        return [SNSMath isVisibleBeteenBetweenUserSatellite:(SNSUserSatellite *)anotherAntenna.owner andGeoSatellite:(SNSDelaySatellite *)antenna.owner fromTime:time];
    }
    
#ifdef DEBUG
    NSLog(@"fail to confirm connection");
#endif
    
    return NO;
}


- (BOOL)antenna:(SNSSatelliteAntenna *)antenna scheduleConnectionWithAntenna:(SNSSatelliteAntenna *)anotherAntenna forDpct:(SNSSGDPCTTaskExecution *)dpctTaskExecution
{
    SNSDelaySatelliteAntenna *to = (SNSDelaySatelliteAntenna *)anotherAntenna;
    
    return [to schedualDataReceiving:dpctTaskExecution];
}

- (void)recordDataSend:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%ld send %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    fprintf(self.dataSendLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)recordDataReceive:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%ld receive %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    fprintf(self.dataReceiveLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (FILE *)dataReceiveLog
{
    if (_dataReceiveLog == NULL) {
        NSString *filePath = [NSString stringWithFormat:@"/Users/zkey/Desktop/science/sns_output/delay_satellite_%03ld_data_receive_log.txt", self.uniqueID];
        _dataReceiveLog = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_dataReceiveLog != NULL);
    }
    
    return _dataReceiveLog;
}

- (FILE *)dataSendLog
{
    if (_dataSendLog) {
        NSString *filePath = [NSString stringWithFormat:@"/Users/zkey/Desktop/science/sns_output/detail_detect_satellite_%03ld_task_execution_log.txt", self.uniqueID];
        _dataSendLog = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_dataSendLog != NULL);
    }
    
    return _dataSendLog;
}

- (void)stop
{
    fclose(self.dataSendLog);
    fclose(self.dataReceiveLog);
}

@end
