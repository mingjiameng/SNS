//
//  SNSUserSatelliteAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSUserSatelliteAntenna.h"

#import "SNSRouteRecord.h"
#import "SNSSatellite.h"
#import "SNSSGDPCTTaskExecution.h"
#import "SNSSGDataPackgeCollection.h"

@implementation SNSUserSatelliteAntenna

- (void)schedualSendingTransmissionTask:(SNSSGDPCTTaskExecution *)task
{
    SNSRouteRecord *routeRecord = [[SNSRouteRecord alloc] init];
    routeRecord.timeStamp = SYSTEM_TIME;
    routeRecord.routerID = self.owner.uniqueID;
    
    [task.dpc clearRouteRecord];
    [task.dpc addRouteRecord:routeRecord];
    
    self.dpcSending = task;
    self.sending = YES;
}

- (void)sendDataBehavior
{
    [super sendDataBehavior];
    
    if (self.dpcSending == nil) {
        self.sending =  NO;
    }
    else {
        // dpcSending的初始状态就是adjusting
        if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateCompleted) {
            [self.delegate antenna:self didSendDataPackageCollection:self.dpcSending.dpc];
            [self stopSending];
        }
        else if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateConnectionFailed) {
            [self.delegate antenna:self didFailToSendDataPackageCollection:self.dpcSending.dpc];
            [self stopSending];
        }
        else {
            [self.dpcSending continueSend];
        }
    }
}

- (void)stopSending
{
    self.sending = NO;
    self.dpcSending = nil;
}

@end
