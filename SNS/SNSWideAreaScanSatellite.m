//
//  SNSWideAreaScanSatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/30.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSWideAreaScanSatellite.h"

#import "SNSSGDataPackgeCollection.h"
#import "SNSSGDPBufferedQueue.h"
#import "SNSUserSatelliteAntenna.h"
#import "SNSSGDPCTTaskExecution.h"

@interface SNSWideAreaScanSatellite ()

@end


@implementation SNSWideAreaScanSatellite
{
    SNSSatelliteTime _disasterDetectAlarmClock;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _disasterDetectAlarmClock = DISASTER_DETECT_PEROID;
    }
    
    return self;
}

- (void)executeTaskBehavior
{
    // 每60秒询问是否有灾害发生
    if (_disasterDetectAlarmClock > 0) {
        --_disasterDetectAlarmClock;
    }
    
    SNSSatelliteGraphicDataPackage *dp = [self.taskQueueDataSource newDisasterDpcForSatellite:self];
    if (dp != nil) {
        [self.dataPackageBufferedQueue addDataPackage:dp];
        self.bufferedDataSize += dp.size;
    }
    
    _disasterDetectAlarmClock = DISASTER_DETECT_PEROID;
}

- (void)sendDataBehavior
{
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
    else if (self.dataPackageBufferedQueue.bufferedFlowSize > EPS_ZERO) {
        SNSSGDPCTTaskExecution *dpct = [self.flowTransportDelegate schedualDataTransmissionForSatellite:self withSendingAntenna:sendingAntenna];
        if (dpct != nil) {
            [self.dataPackageBufferedQueue removeDataPackageIn:dpct.dpc.dataPackageCollection];
            [sendingAntenna schedualSendingTransmissionTask:dpct];
        }
    }
}

@end
