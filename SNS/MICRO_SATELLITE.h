//
//  MICRO_SATELLITE.h
//  SNS
//
//  Created by 梁志鹏 on 2016/12/21.
//  Copyright © 2016年 overcode. All rights reserved.
//

#ifndef MICRO_SATELLITE_h
#define MICRO_SATELLITE_h

@class SNSSatelliteGraphicDataPackage;

typedef double SNSSatelliteTime; // 单位:秒
typedef double SNSMobility; // 单位:秒
typedef double SNSRadian; // 单位:弧度
typedef double SNSNetworkFlowSize; // 单位:MB
typedef double SNSResolutionLevel; // 单位:米
typedef double SNSScanWidth; // 单位:米
typedef int SNSPriorityLevel;
typedef int SNSSatelliteTag;
typedef int  SNSAntennaTag;

typedef struct _SNSTimeRange {
    SNSSatelliteTime beginAt;
    SNSSatelliteTime length;
} SNSTimeRange;

#import "SNSCoreCenter.h"

#define SYSTEM_TIME [[SNSCoreCenter sharedCoreCenter] systemTime]

#define MINIMUM_DATA_PACKAGE_COLLECTION_SIZE 7000

#define EARTH_AUTO_ROTATION_ANGLE_SPEED 4.167e-3 // 自转角速度 单位：角度

#define EXPECTED_SIMULATION_TIME 86400 // 单位：秒，1d * 24h * 60min * 60sec
#define SIMULATION_TIME_STEP 1 // 仿真时间步长

#define EPS_ZERO 1e-10

#define KEPLER_STATIC 3.9861e5

#define SNS_TASK_LOWEST_PRIORITY 1

#endif /* MICRO_SATELLITE_h */
