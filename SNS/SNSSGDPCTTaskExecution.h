//
//  SNSSGDPCTTaskExecution.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatelliteGraphicDataPackage.h"
#import "SNSSatelliteAction.h"
#import "SNSSGDataPackgeCollection.h"

@class SNSSatelliteAntenna;
@class SNSSGDPCTTaskExecution;

typedef NS_ENUM(NSInteger, SNSSGDPCTTaskExecutionState) {
    SNSSGDPCTTaskExecutionStateQueueing = 1,
    SNSSGDPCTTaskExecutionStateRequesting,
    SNSSGDPCTTaskExecutionStateAdjusting,
    SNSSGDPCTTaskExecutionStateConfirming,
    SNSSGDPCTTaskExecutionStateConnectionFailed,
    SNSSGDPCTTaskExecutionStateTransporting,
    SNSSGDPCTTaskExecutionStateCompleted
};

//typedef NS_ENUM(NSInteger, SNSSGDPCTTaskExecutionType) {
//    SNSSGDPCTTaskExecutionTypeSend = 1,
//    SNSSGDPCTTaskExecutionTypeReceive
//};


//@protocol SNSSGDPCTTaskExecutionDelegate <NSObject>
//
//- (BOOL)confirmNetworkConnection:(nonnull SNSSGDPCTTaskExecution *)taskExecution;
//- (void)completeSendingDpc:(nonnull SNSSGDPCTTaskExecution *)taskExecution;
//- (void)completeReceivingDpc:(nonnull SNSSGDPCTTaskExecution *)taskExecution;
//
//@end


@interface SNSSGDPCTTaskExecution : NSObject

@property (nonatomic) SNSSGDPCTTaskExecutionState state;
//@property (nonatomic) SNSSGDPCTTaskExecutionType type;

//@property (nonatomic, strong, nonnull) NSArray<SNSSatelliteGraphicDataPackage *> *dataPackageCollection;
@property (nonatomic, strong, nonnull) SNSSGDataPackgeCollection *dpc;

//@property (nonatomic, weak, nullable) id<SNSSGDPCTTaskExecutionDelegate> delegate;

@property (nonatomic, weak, nullable) SNSSatelliteAntenna *fromAntenna;
@property (nonatomic, weak, nullable) SNSSatelliteAntenna *toAntenna;

@property (nonatomic, strong, nonnull) SNSSatelliteAction *transportAction;

- (void)continueSend;
- (void)continueReceive;

@end
