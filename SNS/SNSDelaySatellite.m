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
            dpctTaskExecution.fromAntenna = antenna;
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
        if (from.sideHop.uniqueID == antenna.uniqueID) {
            return YES;
        }
    }
    else if ([antenna isKindOfClass:[SNSDelaySatelliteAntenna class]] && [anotherAntenna isKindOfClass:[SNSUserSatelliteAntenna class]]) {
        SNSSatelliteTime time = SYSTEM_TIME;
        if ([SNSMath isVisibleBeteenBetweenUserSatellite:(SNSUserSatellite *)anotherAntenna.owner andGeoSatellite:(SNSDelaySatellite *)antenna.owner fromTime:time]) {
            //NSLog(@"success confirm connection between %@ and %@", [antenna class], [anotherAntenna class]);
            return YES;
        }
    }
    
#ifdef DEBUG
    //NSLog(@"fail to confirm connection from %@-%d to %@-%d", [antenna class], antenna.uniqueID, [anotherAntenna class], anotherAntenna.uniqueID);
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
    fprintf(self.dataSendLog, "satellite-%d send %lf MB data at time %lf\n", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME);
}

- (void)recordDataReceive:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    fprintf(self.dataReceiveLog, "satellite-%d receive %lf MB data at time %lf\n", self.uniqueID, dataPackageCollection.size, SYSTEM_TIME);
}

- (FILE *)dataReceiveLog
{
    if (_dataReceiveLog == NULL) {
        NSString *path = [NSString stringWithFormat:@"%@delay_satellite_%03d_data_receive_log.txt",FILE_OUTPUT_PATH_PREFIX_STRING, self.uniqueID];
        _dataReceiveLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        assert(_dataReceiveLog != NULL);
    }
    
    return _dataReceiveLog;
}

- (FILE *)dataSendLog
{
    if (_dataSendLog == NULL) {
        NSString *path = [NSString stringWithFormat:@"%@detail_detect_satellite_%03d_data_send_log.txt", FILE_OUTPUT_PATH_PREFIX_STRING, self.uniqueID];
        _dataSendLog = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
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
