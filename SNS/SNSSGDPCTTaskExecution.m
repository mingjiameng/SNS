//
//  SNSSGDPCTTaskExecution.m
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSGDPCTTaskExecution.h"

@implementation SNSSGDPCTTaskExecution

//- (void)continueAction
//{
//    if (self.type == SNSSGDPCTTaskExecutionTypeSend) {
//        [self continueSend];
//    }
//    else if (self.type == SNSSGDPCTTaskExecutionTypeReceive) {
//        [self continueReceive];
//    }
//    
//}

- (void)continueSend
{
    if (self.state == SNSSGDPCTTaskExecutionStateQueueing) {
        self.state = SNSSGDPCTTaskExecutionStateRequesting;
    } // 由任务执行者通过申请connection将task的状态从requesting置为adjusting
    else if (self.state == SNSSGDPCTTaskExecutionStateAdjusting) {

    } // 由数据接收者将task的状态从adjusting置为transporting
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
