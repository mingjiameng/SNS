//
//  SNSSatelliteGraphicTaskExecution.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSGDetailDetectTask.h"
#import "SNSSatelliteAction.h"

@class SNSDetailDetectSatellite;

typedef NS_ENUM(NSInteger, SNSSatelliteGraphicTaskExecutionState) {
    SNSSatelliteGraphicTaskExecutionStateQueueing = 1, // 排队中
    SNSSatelliteGraphicTaskExecutionStateAdjusting, // 执行中，卫星调整姿态
    SNSSatelliteGraphicTaskExecutionStateImaging, // 执行中，卫星成像中
    SNSSatelliteGraphicTaskExecutionStateCompleted // 执行完毕
};



@interface SNSSatelliteGraphicTaskExecution : NSObject

@property (nonatomic) SNSTaskExecutionTag uniqueID;

@property (nonatomic) SNSSatelliteGraphicTaskExecutionState state;
@property (nonatomic) SNSNetworkFlowSize dataProduced;

@property (nonatomic, strong, nonnull) SNSSGDetailDetectTask *task;
@property (nonatomic, weak, nullable) SNSDetailDetectSatellite *executor;
@property (nonatomic, strong, nonnull) SNSSatelliteAction *imageAction;

- (void)continueAction; // 继续执行任务，为时1秒

@end
