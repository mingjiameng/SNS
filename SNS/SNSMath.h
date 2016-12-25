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
#import "SNSDelaySatellite.h"
#import "SNSEarthPoint.h"
#import "SNSHotArea.h"

@interface SNSMath : NSObject

+ (unsigned int)randomIntegerBetween:(unsigned int)baseFactor and:(unsigned int)modifyFactor;

+ (nonnull SNSSpacePoint *)spacePointOfSatellite:(nonnull SNSSatellite *)satellite;



// 星下点算法
+ (nonnull SNSEarthPoint *)subSatellitePoint:(nonnull SNSSatellite *)satellite atTime:(SNSSatelliteTime)time;

//+ (void)satelliteOrbit:(SNSSatelliteOrbit)orbit period:(SNSSatelliteTime &)period orbitAngleSpeed:(SNSRadian &)angleSpeed;

// 轨道周期算法
+ (SNSSatelliteTime)orbitPeriodOfSatelliteOrbit:(SNSSatelliteOrbit)orbit;

// 热点区域对业务星在指定时间段内是否可见，及可见时间段算法
+ (SNSTimeRange)visibleTimeRangeBetweenSatellite:(nonnull SNSSatellite *)satellite andHotArea:(nonnull SNSHotArea *)hotArea inTimeRange:(SNSTimeRange)theTimeRange;

// 中继星对业务星下一可见时间段算法
+ (SNSTimeRange)nextVisibleTimeRangeBetweenUserSatellite:(nonnull SNSSatellite *)userSatellite andGeoSatellite:(nonnull SNSDelaySatellite *)geoSatellite fromTime:(SNSSatelliteTime)time;

@end
