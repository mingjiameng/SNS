//
//  SNSUserSatellite.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatellite.h"
#import "SNSUserSatelliteAntenna.h"

@class SNSUserSatellite;
@class SNSSatelliteGraphicTaskExecution;
@class SNSSGDPCTTaskExecution;
@class SNSSGDPBufferedQueue;

@protocol SNSUserSatelliteFlowTransportDelegate <NSObject> // 流量传输代理
@optional
- (nullable SNSSGDPCTTaskExecution *)schedualDataTransmissionForSatellite:(nonnull SNSUserSatellite *)userSatellite withSendingAntenna:(nonnull SNSUserSatelliteAntenna *)sendingAntenna;
- (void)satellite:(nonnull SNSUserSatellite *)userSatellite didSendPackageCollection:(nonnull SNSSGDataPackgeCollection *)dpc;
- (SNSDataPackageTag)newDpTag;

@end


@protocol SNSUserSatelliteTaskQueueDataSource <NSObject>
@optional
// 详查星任务队列
- (nonnull NSArray<SNSSatelliteGraphicTaskExecution *> *)newTaskExecutionQueueForSatellite:(nonnull SNSUserSatellite *)userSatellite;

// 普查星DPC数据源
- (nullable SNSSatelliteGraphicDataPackage *)newDisasterDpcForSatellite:(nonnull SNSUserSatellite *)userSatellite;

@end


@interface SNSUserSatellite : SNSSatellite <SNSAntennaDelegate>

// 事务代理
@property (nonatomic, weak, nullable) id<SNSUserSatelliteTaskQueueDataSource> taskQueueDataSource;
@property (nonatomic, weak, nullable) id<SNSUserSatelliteFlowTransportDelegate> flowTransportDelegate;

@property (nonatomic, strong, nonnull) SNSSGDPBufferedQueue *dataPackageBufferedQueue;

@property (nonatomic) SNSResolutionLevel resolution;
@property (nonatomic) SNSScanWidth scanWidth;

@property (nonatomic, nonnull) FILE *taskExecutionLog;
@property (nonatomic, nonnull) FILE *dataSendingLog;

- (void)recordTaskExecution:(nonnull SNSSatelliteGraphicTaskExecution *)taskExecuted;
- (void)recordSendingData:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection;

- (void)executeTaskBehavior;
- (void)sendDataBehavior;

- (SNSNetworkFlowSize)dataCanBeSendedInTime:(SNSSatelliteTime)time;
- (nullable SNSSGDataPackgeCollection *)produceDpcCanBeSendedInTime:(SNSSatelliteTime)time;

@end
