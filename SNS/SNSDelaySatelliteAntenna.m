//
//  SNSDelaySatelliteAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSDelaySatelliteAntenna.h"

#import "SNSMath.h"
#import "SNSSGDPCTTaskExecution.h"
#import "SNSSGDPCTTaskExecutionQueue.h"
#import "SNSRouteRecord.h"

@interface SNSDelaySatelliteAntenna ()

@end


@implementation SNSDelaySatelliteAntenna

- (void)sendDataBehavior
{
    if (self.dpcSending == nil) {
        self.dpcSending = [self.dpcSendingTaskQueue pop];
        if (self.dpcSending != nil) {
            self.dpcSending.fromAntenna = self;
            self.dpcSending.toAntenna = self.sideHop;
        }
    }
    else {
        if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateCompleted) {
            [self.delegate antenna:self didSendDataPackageCollection:self.dpcSending.dpc];
            self.dpcSending = [self.dpcSendingTaskQueue pop];
        }
        else if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateRequesting) {
            if ([self.delegate antenna:self scheduleConnectionWithAntenna:self.sideHop forDpct:self.dpcSending]) {
                self.dpcSending.state = SNSSGDPCTTaskExecutionStateAdjusting;
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
            SNSRouteRecord *routeRecord = [[SNSRouteRecord alloc] init];
            routeRecord.timeStamp = SYSTEM_TIME;
            routeRecord.routerID = self.owner.uniqueID;
            [self.dpcReceiving.dpc addRouteRecord:routeRecord];
            [self.delegate antenna:self didReceiveDataPackageCollection:self.dpcReceiving.dpc];
            self.dpcReceiving = nil;
        }
        else if (self.dpcReceiving.state == SNSSGDPCTTaskExecutionStateConfirming) {
            if ([self.delegate antenna:self confirmConnectionWithAntenna:self.dpcReceiving.fromAntenna]) {
                // 连接成功，传输
                self.dpcReceiving.state = SNSSGDPCTTaskExecutionStateTransporting;
                self.dpcReceiving.transportAction.startTime = SYSTEM_TIME;
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
    SNSSatelliteAntenna *fromAntenna = (SNSSatelliteAntenna *)dataTransmissionTask.fromAntenna;
    SNSTimeRange visibleTimeRange = [SNSMath nextVisibleTimeRangeBetweenUserSatellite:fromAntenna.owner andGeoSatellite:(SNSDelaySatellite *)self.owner fromTime:time];
    
    SNSSatelliteTime expectedEndTime = [self.dpcReceivingTaskQueue expectedEndTime];
    if (expectedEndTime + 300 >= visibleTimeRange.beginAt + visibleTimeRange.length) {
        return -1;
    }
    
    return MAX(0, visibleTimeRange.beginAt - expectedEndTime);
}

- (BOOL)schedualDataTransmissionTask:(SNSSGDPCTTaskExecution *)dataTransmissionTask
{
    SNSSatelliteTime time = SYSTEM_TIME;
    SNSSatelliteAntenna *fromAntenna = (SNSSatelliteAntenna *)dataTransmissionTask.fromAntenna;
    SNSTimeRange visibleTimeRange = [SNSMath nextVisibleTimeRangeBetweenUserSatellite:fromAntenna.owner andGeoSatellite:(SNSDelaySatellite *)self.owner fromTime:time];
    
    SNSSatelliteTime expectedEndTime = [self.dpcReceivingTaskQueue expectedEndTime];
    expectedEndTime += 300;
    if (expectedEndTime > visibleTimeRange.beginAt + visibleTimeRange.length) {
        return NO;
    }
    
    SNSSatelliteAction *transportAction = [[SNSSatelliteAction alloc] init];
    transportAction.expectedTimeCost = dataTransmissionTask.dpc.size / dataTransmissionTask.fromAntenna.bandWidth;
    transportAction.ExpectedStartTime = expectedEndTime;
    dataTransmissionTask.transportAction = transportAction;
    dataTransmissionTask.toAntenna = self;
    [self.dpcReceivingTaskQueue addTransmissionTask:dataTransmissionTask];
    
    return YES;
}

- (BOOL)schedualDataReceiving:(SNSSGDPCTTaskExecution *)dataReceivingTask
{
    SNSSatelliteTime expectedEndTime = [self.dpcReceivingTaskQueue expectedEndTime];
    
    SNSSatelliteAction *transportAction = [[SNSSatelliteAction alloc] init];
    transportAction.ExpectedStartTime = expectedEndTime + 3.0;
    transportAction.expectedTimeCost = dataReceivingTask.dpc.size / dataReceivingTask.fromAntenna.bandWidth;
    dataReceivingTask.transportAction = transportAction;
    
    [self.dpcReceivingTaskQueue addTransmissionTask:dataReceivingTask];
    
    return YES;
}

- (void)addSendingTransmissionTask:(SNSSGDPCTTaskExecution *)dpctTaskExecution
{
    dpctTaskExecution.state = SNSSGDPCTTaskExecutionStateQueueing;
    [self.dpcSendingTaskQueue addTransmissionTask:dpctTaskExecution];
}

@end
