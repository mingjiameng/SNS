//
//  SNSUserSatelliteAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatelliteAntenna.h"

@interface SNSUserSatelliteAntenna : SNSSatelliteAntenna

@property (nonatomic, weak, nullable) id<SNSAntennaDelegate> delegate;


- (void)schedualSendingTransmissionTask:(nonnull SNSSGDPCTTaskExecution *)task;

@end
