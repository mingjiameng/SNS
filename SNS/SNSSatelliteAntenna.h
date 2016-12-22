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

typedef NS_ENUM(NSInteger, SNSSatelliteAntennaFunctionType) {
    SNSSatelliteAntennaFunctionTypeSendData = 1,
    SNSSatelliteAntennaFunctionTypeReceiveData,
    SNSSatelliteAntennaFunctionTypeSendAndReceiveData
};



@protocol SNSSatelliteAntennaDelegate <NSObject>

- (void)antenna:(nonnull SNSSatelliteAntenna *)antenna receiveDataPackageCollection:(nonnull NSArray < SNSSatelliteGraphicDataPackage *> *)dataPackageCollection;
- (void)antenna:(nonnull SNSSatelliteAntenna *)antenna sendDataPackageCollection:(nonnull NSArray < SNSSatelliteGraphicDataPackage *> *)dataPackageCollection;

- (BOOL)antenna:(nonnull SNSSatelliteAntenna *)antenna confirmConnectionWithAntenna:(nonnull SNSSatelliteAntenna *)anotherAntenna;
- (BOOL)antenna:(nonnull SNSSatelliteAntenna *)antenna requestConnectionForDpct:(nonnull SNSSGDPCTTaskExecution *)dpctTaskExecution;
- (BOOL)antenna:(nonnull SNSSatelliteAntenna *)antenna scheduleConnectionWithAntenna:(nonnull SNSSatelliteAntenna *)anotherAntenna forDpct:(nonnull SNSSGDPCTTaskExecution *)dpctTaskExecution;

@end



@interface SNSSatelliteAntenna : NSObject

@property (nonatomic) NSUInteger uniqueID;
@property (nonatomic) SNSSatelliteAntennaFunctionType type;
@property (nonatomic, weak, nullable) SNSSatellite *owner;
@property (nonatomic, weak, nullable) id<SNSSatelliteAntennaDelegate> delegate;

@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecutionQueue *dpcSendingTaskQueue;
@property (nonatomic, strong, nonnull) SNSSGDPCTTaskExecution *dpcSending;

@property (nonatomic, weak, nullable) SNSSGDPCTTaskExecutionQueue *dpcReceivingTaskQueue;
@property (nonatomic, weak, nullable) SNSSGDPCTTaskExecution *dpcReceiving;

// automatically behave
- (void)continueAction;

// choose according to SNSSatelliteAntennaFunctionType
- (void)sendDataBehavior;
- (void)receiveDataBehavior;


// task management
- (void)addSendingTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)task;

@end