//
//  SNSUserSatellite.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatellite.h"

@class SNSUserSatellite;
@class SNSSatelliteGraphicTaskExecution;

@class SNSDataTransmissionTask;


@protocol SNSUserSatelliteFlowTransportDelegate <NSObject> // 流量传输代理

- (BOOL)schedualDataTransmission:(nonnull SNSDataTransmissionTask *)dataTransmissionTask forSatellite:(nonnull SNSUserSatellite *)userSatellite;

@end


@protocol SNSUserSatelliteTaskQueueDataSource <NSObject>

- (nonnull NSArray<SNSSatelliteGraphicTaskExecution *> *)newTaskExecutionQueueForSatellite:(nonnull SNSUserSatellite *)userSatellite;

@end


@interface SNSUserSatellite : SNSSatellite

// 事务代理
@property (nonatomic, weak, nullable) id<SNSUserSatelliteTaskQueueDataSource> taskQueueDataSource;
@property (nonatomic, weak, nullable) id<SNSUserSatelliteFlowTransportDelegate> flowTransportDelegate;


@end
