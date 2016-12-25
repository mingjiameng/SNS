//
//  SNSDelaySatelliteAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDelaySatelliteAntenna.h"

#import "SNSMath.h"

@interface SNSDelaySatelliteAntenna ()

@end


@implementation SNSDelaySatelliteAntenna

- (void)sendDataBehavior
{
    if (self.dpcSending == nil) {
        self.dpcSending = [self.dpcSendingTaskQueue pop];
        if (self.dpcSending != nil) {
            self.dpcSending.fromAntenna = self;
            self.dpcSending.toAntenna = self.nextHop;
        }
    }
    else {
        if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateCompleted) {
            [self.delegate antenna:self sendDataPackageCollection:self.dpcSending.dpc];
            self.dpcSending = [self.dpcSendingTaskQueue pop];
        }
        else if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateRequesting) {
            if ([self.delegate antenna:self scheduleConnectionWithAntenna:self.nextHop forDpct:self.dpcSending]) {
                self.dpcSending.state = SNSSGDPCTTaskExecutionStateTransporting;
            }
            else {
                self.dpcSending.state = SNSSGDPCTTaskExecutionStateQueueing;
            }
        }
        else if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateConnectionFailed) {
            self.dpcSending.state = SNSSGDPCTTaskExecutionStateQueueing;
        }
        else {
            [self.dpcSending continueSend];
        }
    }
}

- (void)receiveDataBehavior
{
    if (self.dpcReceiving == nil) {
        self.dpcReceiving = [self.dpcReceivingTaskQueue pop];
    }
    else {
        if (self.dpcReceiving.state == SNSSGDPCTTaskExecutionStateCompleted) {
            [self.delegate antenna:self receiveDataPackageCollection:self.dpcReceiving.dpc];
            self.dpcReceiving = nil;
        }
        else if (self.dpcReceiving.state == SNSSGDPCTTaskExecutionStateConfirming) {
            if ([self.delegate antenna:self confirmConnectionWithAntenna:self.dpcReceiving.fromAntenna]) {
                // 连接成功，传输
                self.dpcReceiving.state = SNSSGDPCTTaskExecutionStateTransporting;
            }
            else {
                // 连接失败，放弃此次传输
                self.dpcReceiving.state = SNSSGDPCTTaskExecutionStateConnectionFailed;
                self.dpcReceiving = nil;
            }
        }
        else {
            [self.dpcReceiving continueReceive];
        }
    }
}

- (SNSSatelliteTime)timeCostToUndertakenDataTransmissionTask:(SNSSGDPCTTaskExecution *)dataTransmissionTask
{
    SNSSatelliteTime time = SYSTEM_TIME;
    SNSTimeRange visibleTimeRange = [SNSMath nextVisibleTimeRangeBetweenUserSatellite:dataTransmissionTask.fromAntenna.owner andGeoSatellite:(SNSDelaySatellite *)self.owner fromTime:time];
    
    SNSSatelliteTime expectedEndTime = [self.dpcReceivingTaskQueue expectedEndTime];
    expectedEndTime += 300;
    if (expectedEndTime < visibleTimeRange.beginAt) {
        return -1;
    }

    return visibleTimeRange.beginAt - expectedEndTime;
}

- (BOOL)schedualDataTransmissionTask:(SNSSGDPCTTaskExecution *)dataTransmissionTask
{
    SNSSatelliteTime time = SYSTEM_TIME;
    SNSTimeRange visibleTimeRange = [SNSMath nextVisibleTimeRangeBetweenUserSatellite:dataTransmissionTask.fromAntenna.owner andGeoSatellite:(SNSDelaySatellite *)self.owner fromTime:time];
    
    SNSSatelliteTime expectedEndTime = [self.dpcReceivingTaskQueue expectedEndTime];
    expectedEndTime += 300;
    if (expectedEndTime < visibleTimeRange.beginAt) {
        return NO;
    }
    
    SNSSatelliteAction *transportAction = [[SNSSatelliteAction alloc] init];
    transportAction.expectedTimeCost = 10;
    transportAction.ExpectedStartTime = expectedEndTime;
    
    return YES;
}

@end
