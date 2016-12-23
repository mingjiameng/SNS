//
//  SNSMath.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/23.
//  Copyright © 2016年 overcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNSSpacePoint.h"
#import "SNSSatellite.h"

@interface SNSMath : NSObject

+ (unsigned int)randomIntegerBetween:(unsigned int)baseFactor and:(unsigned int)modifyFactor;

+ (SNSSpacePoint *)spacePointWithSatelliteOrbit:(SNSSatelliteOrbit)orbit andCurrentPosition:(SNSAngle)theta;

@end
