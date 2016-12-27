//
//  SNSUserSatelliteAntenna.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSUserSatelliteAntenna.h"

@implementation SNSUserSatelliteAntenna

- (void)sendDataBehavior
{
    [super sendDataBehavior];
    
    //NSLog(@"user sending data");
    
    
    
    if (self.dpcSending == nil) {
        self.dpcSending = [self.dpcSendingTaskQueue pop];
        if (self.dpcSending != nil) {
            self.dpcSending.fromAntenna = self;
        }
    }
    else {
//        if (self.uniqueID == 1) {
//            NSLog(@"dpc state:%ld", self.dpcSending.state);
//        }
        if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateCompleted) {
            [self.delegate antenna:self sendDataPackageCollection:self.dpcSending.dpc];
            self.dpcSending = [self.dpcSendingTaskQueue pop];
        }
        else if (self.dpcSending.state == SNSSGDPCTTaskExecutionStateRequesting) {
            if ([self.delegate antenna:self requestConnectionForDpct:self.dpcSending]) {
                self.dpcSending.state = SNSSGDPCTTaskExecutionStateAdjusting;
            }
            else {
                self.dpcSending.state = SNSSGDPCTTaskExecutionStateQueueing;
//                if (self.uniqueID == 1) {
//                    NSLog(@"fail to request network connect");
//                }
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

@end
