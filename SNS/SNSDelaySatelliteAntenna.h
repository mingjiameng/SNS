//
//  SNSDelaySatelliteAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteAntenna.h"

@class SNSSGDPCTTaskExecution;

@class SNSDelaySatelliteAntenna;
@class SNSSGDPCTTaskExecutionQueue;
@class SNSSGDPCTTaskExecution;
@class SNSUserSatellite;

@protocol SNSDelaySatelliteAntennaDelegate <SNSAntennaDelegate>
@required
// 中继星可能与中继星或者地面站相连

// 中继星发出连接确认
- (BOOL)antenna:(nonnull SNSDelaySatelliteAntenna *)antenna confirmConnectionWithAntenna:(nonnull SNSAntenna *)anotherAntenna;

//
- (BOOL)antenna:(nonnull SNSDelaySatelliteAntenna *)antenna scheduleConnectionWithAntenna:(nonnull SNSAntenna *)anotherAntenna forDpct:(nonnull SNSSGDPCTTaskExecution *)dpctTaskExecution;

@end


@interface SNSDelaySatelliteAntenna : SNSSatelliteAntenna

@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecutionQueue *dpcSendingTaskQueue;

@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecutionQueue *dpcReceivingTaskQueue;
@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecution *dpcReceiving;

@property (nonatomic, weak, nullable) SNSAntenna *sideHop; // 邻接点
@property (nonatomic, weak, nullable) id<SNSDelaySatelliteAntennaDelegate> delegate;

// 从业务星接收数据
- (SNSSatelliteTime)timeCostToUndertakenDataTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)dataTransmissionTask;
- (BOOL)schedualDataTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)dataTransmissionTask;

- (double)costPerformanceToSchedualTransmissionForUserSatellite:(nonnull SNSUserSatellite *)userSatellite withSendingAntenna:(nonnull SNSAntenna *)sendingAntenna;
- (nonnull SNSSGDPCTTaskExecution *)schedualTransmissionForUserSatellite:(nonnull SNSUserSatellite *)userSatellite withSendingAntenna:(nonnull SNSAntenna *)sendingAntenna;

// 从中继星接收数据
- (BOOL)schedualDataReceiving:(nonnull SNSSGDPCTTaskExecution *)dataReceivingTask;

// 中继星将收到的DPC放入发送队列中
- (void)addSendingTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)dpctTaskExecution;


@end
