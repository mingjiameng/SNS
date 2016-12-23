//
//  SNSDelaySatellite.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDelaySatellite.h"

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


@end
