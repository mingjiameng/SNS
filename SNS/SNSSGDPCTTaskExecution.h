//
//  SNSSGDPCTTaskExecution.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatelliteGraphicDataPackage.h"

typedef NS_ENUM(NSInteger, SNSSGDPCTTaskExecutionState) {
    SNSSGDPCTTaskExecutionStateQueueing = 1,
    SNSSGDPCTTaskExecutionStateRequesting,
    SNSSGDPCTTaskExecutionStateAdjusting,
    SNSSGDPCTTaskExecutionStateTransporting,
    SNSSGDPCTTaskExecutionStateCompleted
};


@interface SNSSGDPCTTaskExecution : NSObject

@property (nonatomic) SNSSGDPCTTaskExecutionState state;
@property (nonatomic, strong, nonnull) NSArray<SNSSatelliteGraphicDataPackage *> *dataPackageCollection;

- (void)continueAction;

@end
