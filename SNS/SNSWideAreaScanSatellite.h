//
//  SNSWideAreaScanSatellite.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/30.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSUserSatellite.h"

#import "SNSUserSatelliteAntenna.h"

@class SNSSGDPBufferedQueue;

@interface SNSWideAreaScanSatellite : SNSUserSatellite <SNSAntennaDelegate>

@end
