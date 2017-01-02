//
//  SNSSGDPCTTaskExecution.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDPCTTaskExecution.h"

@implementation SNSSGDPCTTaskExecution

- (void)continueSend
{
    if (self.state == SNSSGDPCTTaskExecutionStateQueueing) {
        self.state = SNSSGDPCTTaskExecutionStateRequesting;
    }
    else if (self.state == SNSSGDPCTTaskExecutionStateTransporting) {
        if (SYSTEM_TIME >= self.transportAction.startTime + self.transportAction.expectedTimeCost) {
            self.state = SNSSGDPCTTaskExecutionStateCompleted;
        }
    }
}

- (void)continueReceive
{
    if (self.state == SNSSGDPCTTaskExecutionStateQueueing) {
        self.state = SNSSGDPCTTaskExecutionStateAdjusting;
    }
    else if (self.state == SNSSGDPCTTaskExecutionStateAdjusting) {
        if (SYSTEM_TIME >= self.transportAction.ExpectedStartTime) {
            self.state = SNSSGDPCTTaskExecutionStateConfirming;
        }
    } // 由任务所属天线将task的状态从confirming置为transporting
    else if (self.state == SNSSGDPCTTaskExecutionStateTransporting) {
        // 由数据发送者计时
        //            if (SYSTEM_TIME >= self.transportAction.ExpectedStartTime + self.transportAction.expectedTimeCost) {
        //                self.state = SNSSGDPCTTaskExecutionStateCompleted;
        //            }
    }
}

@end
