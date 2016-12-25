//
//  SNSDelaySatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDelaySatellite.h"

#import "SNSMath.h"

@implementation SNSDelaySatellite



- (void)updateState
{
    [super updateState];
    
    for (SNSSatelliteAntenna *antenna in self.antennas) {
        [antenna continueAction];
    }
}

- (void)antenna:(SNSSatelliteAntenna *)antenna sendDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize -= dataPackageCollection.size;
}

- (void)antenna:(SNSSatelliteAntenna *)antenna receiveDataPackageCollection:(SNSSGDataPackgeCollection *)dataPackageCollection
{
    self.bufferedDataSize += dataPackageCollection.size;
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
    SNSSatelliteTime time = SYSTEM_TIME;
    
    return [SNSMath isVisibleBeteenBetweenUserSatellite:antenna.owner andGeoSatellite:(SNSDelaySatellite *)anotherAntenna.owner fromTime:time];
}

// TODO
- (BOOL)antenna:(SNSSatelliteAntenna *)antenna scheduleConnectionWithAntenna:(SNSSatelliteAntenna *)anotherAntenna forDpct:(SNSSGDPCTTaskExecution *)dpctTaskExecution
{
    SNSSatelliteAction *transportAction = [[SNSSatelliteAction alloc] init];
    transportAction.ExpectedStartTime = [anotherAntenna.dpcReceivingTaskQueue expectedEndTime] + 2.0f;
    transportAction.expectedTimeCost = dpctTaskExecution.dpc.size / antenna.bandWidth;
    [anotherAntenna.dpcReceivingTaskQueue addTransmissionTask:dpctTaskExecution];
    
    return TRUE;
}

@end
