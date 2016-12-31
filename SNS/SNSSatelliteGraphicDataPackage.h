//
//  SNSSatelliteGraphicDataPackage.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatelliteGraphicTaskExecution.h"

@interface SNSSatelliteGraphicDataPackage : NSObject

@property (nonatomic) SNSDataPackageTag uniqueID; // ID从网络管理中心获得
@property (nonatomic) SNSNetworkFlowSize size;
@property (nonatomic, strong, nonnull) SNSSatelliteGraphicTaskExecution *taskExecution;

@end
