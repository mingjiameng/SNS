//
//  SNSGroundStationAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2017/1/2.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import "SNSGroundStationAntenna.h"

#import "SNSSGDPCTTaskExecution.h"
#import "SNSSGDPCTTaskExecutionQueue.h"
#import "SNSGroundStation.h"

@implementation SNSGroundStationAntenna

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

@end
