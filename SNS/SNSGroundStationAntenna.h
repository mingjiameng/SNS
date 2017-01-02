//
//  SNSGroundStationAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2017/1/2.
//  Copyright © 2017年 overcode. All rights reserved.
//

#import "SNSAntenna.h"

@class SNSGroundStation;
@class SNSGroundStationAntenna;

@protocol SNSGroundStationAntennaDelegate <SNSAntennaDelegate>
@required
- (BOOL)antenna:(nonnull SNSGroundStationAntenna *)antenna confirmConnectionWithAntenna:(nonnull SNSAntenna *)anotherAntenna;


@end


@interface SNSGroundStationAntenna : SNSAntenna

@property (nonatomic, weak, nullable) SNSGroundStation *owner;

@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecutionQueue *dpcReceivingTaskQueue;
@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecution *dpcReceiving;

@property (nonatomic, weak, nullable) id<SNSGroundStationAntennaDelegate> delegate;

// 从中继星接收数据
- (BOOL)schedualDataReceiving:(nonnull SNSSGDPCTTaskExecution *)dataReceivingTask;


@end
