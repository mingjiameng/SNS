//
//  SNSDelaySatelliteAntenna.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/22.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import "SNSSatelliteAntenna.h"

@interface SNSDelaySatelliteAntenna : SNSSatelliteAntenna

@property (nonatomic, weak, nullable) SNSSatelliteAntenna *nextHop; // 下一跳

@end
