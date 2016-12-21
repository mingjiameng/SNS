//
//  SNSSatelliteGraphicTaskExecution.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNSSatelliteGraphicTaskExecutionState) {
    SNSSatelliteGraphicTaskExecutionStateQueueing = 1, // 排队中
    SNSSatelliteGraphicTaskExecutionStateAdjusting, // 执行中，卫星调整姿态
    SNSSatelliteGraphicTaskExecutionStateImaging, // 执行中，卫星成像中
    SNSSatelliteGraphicTaskExecutionStateCompleted // 执行完毕
};



@interface SNSSatelliteGraphicTaskExecution : NSObject

@property (nonatomic) SNSSatelliteGraphicTaskExecutionState state;

- (void)continueAction; // 继续执行任务，为时1秒

@end
