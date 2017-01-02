//
//  SNSNetworkManageCenter.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSUserSatellite.h"
#import "SNSDelaySatellite.h"

@interface SNSNetworkManageCenter : NSObject <SNSUserSatelliteFlowTransportDelegate>

@property (nonatomic, weak, nullable) NSArray<SNSDelaySatellite *> *delaySatellites;

+ (nonnull instancetype)sharedNetworkManageCenter;

- (BOOL)schedualDPCTransmission:(nonnull SNSSGDPCTTaskExecution *)dataTransmissionTask forSatellite:(nonnull SNSUserSatellite *)userSatellite;
- (void)satellite:(SNSUserSatellite *)userSatellite didSendPackageCollection:(SNSSGDataPackgeCollection *)dpc;

@end
