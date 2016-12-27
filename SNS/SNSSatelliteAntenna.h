//
//  SNSSatelliteAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSGDPCTTaskExecutionQueue.h"
#import "SNSSGDPCTTaskExecution.h"

@class SNSSatellite;
@class SNSSatelliteAntenna;
@class SNSSGDataPackgeCollection;

typedef NS_ENUM(NSInteger, SNSSatelliteAntennaFunctionType) {
    SNSSatelliteAntennaFunctionTypeSendData = 1,
    SNSSatelliteAntennaFunctionTypeReceiveData,
    SNSSatelliteAntennaFunctionTypeSendAndReceiveData
};



@protocol SNSSatelliteAntennaDelegate <NSObject>

@optional
- (void)antenna:(nonnull SNSSatelliteAntenna *)antenna receiveDataPackageCollection:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection;
- (void)antenna:(nonnull SNSSatelliteAntenna *)antenna sendDataPackageCollection:(nonnull SNSSGDataPackgeCollection *)dataPackageCollection;
- (BOOL)antenna:(nonnull SNSSatelliteAntenna *)antenna confirmConnectionWithAntenna:(nonnull SNSSatelliteAntenna *)anotherAntenna;
- (BOOL)antenna:(nonnull SNSSatelliteAntenna *)antenna requestConnectionForDpct:(nonnull SNSSGDPCTTaskExecution *)dpctTaskExecution;
- (BOOL)antenna:(nonnull SNSSatelliteAntenna *)antenna scheduleConnectionWithAntenna:(nonnull SNSSatelliteAntenna *)anotherAntenna forDpct:(nonnull SNSSGDPCTTaskExecution *)dpctTaskExecution;

@end



@interface SNSSatelliteAntenna : NSObject

@property (nonatomic) SNSAntennaTag uniqueID;
@property (nonatomic) SNSNetworkFlowSize bandWidth;
@property (nonatomic) SNSSatelliteAntennaFunctionType type;
@property (nonatomic, weak, nullable) SNSSatellite *owner;
@property (nonatomic, weak, nullable) id<SNSSatelliteAntennaDelegate> delegate;

@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecutionQueue *dpcSendingTaskQueue;
@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecution *dpcSending;

@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecutionQueue *dpcReceivingTaskQueue;
@property (nonatomic, strong, nullable) SNSSGDPCTTaskExecution *dpcReceiving;

// automatically behave
- (void)continueAction;

// choose according to SNSSatelliteAntennaFunctionType
- (void)sendDataBehavior;
- (void)receiveDataBehavior;


// task management
- (void)addSendingTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)task;

@end
