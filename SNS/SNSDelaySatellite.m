//
//  SNSDelaySatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDelaySatellite.h"

#import "SNSMath.h"
#import "SNSSGDataPackgeCollection.h"
#import "SNSSGDPCTTaskExecution.h"
#import "SNSGroundStationAntenna.h"

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

- (void)antenna:(SNSAntenna *)antenna didSendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize -= dataPackageCollection.size;
    [self recordDataSend:dataPackageCollection];
}

- (void)antenna:(SNSAntenna *)antenna didReceiveDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize += dataPackageCollection.size;
    [self recordDataReceive:dataPackageCollection];
    
    for (SNSDelaySatelliteAntenna *antennaSending in self.antennas) {
        if (antennaSending.functionType == SNSAntennaFunctionTypeSendData) {
            SNSSGDPCTTaskExecution *dpctTaskExecution = [[SNSSGDPCTTaskExecution alloc] init];
            dpctTaskExecution.dpc = dataPackageCollection;
            [antennaSending addSendingTransmissionTask:dpctTaskExecution];
            break;
        }
    }
}

- (BOOL)antenna:(SNSSatelliteAntenna *)antenna confirmConnectionWithAntenna:(SNSSatelliteAntenna *)anotherAntenna
{
    // 有固定连接
    if ([antenna isKindOfClass:[SNSDelaySatelliteAntenna class]] && [anotherAntenna isKindOfClass:[SNSDelaySatelliteAntenna class]]) {
        SNSDelaySatelliteAntenna *from = (SNSDelaySatelliteAntenna *)anotherAntenna;
        if (from.sideHop == antenna) {
            return YES;
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

- (BOOL)antenna:(SNSDelaySatelliteAntenna *)antenna scheduleConnectionWithAntenna:(SNSAntenna *)anotherAntenna forDpct:(SNSSGDPCTTaskExecution *)dpctTaskExecution
{
    if ([anotherAntenna isKindOfClass:[SNSDelaySatelliteAntenna class]]) {
        return [(SNSDelaySatelliteAntenna *)anotherAntenna schedualDataReceiving:dpctTaskExecution];
    }
    else if ([anotherAntenna isKindOfClass:[SNSGroundStationAntenna class]]) {
        return [(SNSGroundStationAntenna *)anotherAntenna schedualDataReceiving:dpctTaskExecution];
    }
    
    return NO;
}

- (void)recordDataSend:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%d send %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    fprintf(self.dataSendLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)recordDataReceive:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    NSString *log = [NSString stringWithFormat:@"satellite-%d receive %lf MB data at time %lf", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME];
    fprintf(self.dataReceiveLog, "%s\n", [log cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (FILE *)dataReceiveLog
{
    if (_dataReceiveLog == NULL) {
        NSString *path = [NSString stringWithFormat:@"%@delay_satellite_%03d_data_receive_log.txt",FILE_OUTPUT_PATH_PREFIX_STRING, self.uniqueID];
        _dataReceiveLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        assert(_dataReceiveLog != NULL);
    }
    
    return _dataReceiveLog;
}

- (FILE *)dataSendLog
{
    if (_dataSendLog) {
        NSString *path = [NSString stringWithFormat:@"%@detail_detect_satellite_%03d_task_execution_log.txt", FILE_OUTPUT_PATH_PREFIX_STRING, self.uniqueID];
        _dataSendLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w+");
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
