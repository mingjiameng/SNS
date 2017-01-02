//
//  SNSDelaySatellite.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSatellite.h"
#import "SNSDelaySatelliteAntenna.h"

@interface SNSDelaySatellite : SNSSatellite <SNSDelaySatelliteAntennaDelegate>

@end
