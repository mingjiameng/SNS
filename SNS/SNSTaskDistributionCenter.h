//
//  SNSTaskDistributionCenter.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSUserSatellite.h"

@interface SNSTaskDistributionCenter : NSObject <SNSUserSatelliteTaskQueueDataSource>

+ (nonnull instancetype)sharedTaskDistributionCenter;

- (nonnull NSArray<SNSSatelliteGraphicTaskExecution *> *)newTaskExecutionQueueForSatellite:(nonnull SNSDetailDetectSatellite *)userSatellite;

@end
