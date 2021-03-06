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
typedef double SNSAngle;
typedef double SNSNetworkFlowSize; // 单位:MB
typedef double SNSResolutionLevel; // 单位:米
typedef double SNSScanWidth; // 单位:米

typedef int SNSPriorityLevel;
typedef int SNSSatelliteTag;
typedef int  SNSAntennaTag;
typedef int SNSDataPackageTag;
typedef int SNSRouterHopTag;
typedef int SNSTaskExecutionTag;
typedef int SNSGroundStationTag;
typedef int SNSDataPackageTag;

typedef struct _SNSTimeRange {
    SNSSatelliteTime beginAt;
    SNSSatelliteTime length;
}SNSTimeRange;

#define SYSTEM_TIME [[SNSCoreCenter sharedCoreCenter] systemTime]

#define MINIMUM_DATA_PACKAGE_COLLECTION_SIZE 20000 // 20 000 MB = 20GB
#define MAXIMUM_DATA_PACKAGE_COLLECTION_SIZE 50000 // 50 000 MB = 50GB

#define DETAIL_DETECT_TASK_COUNT_PER_ORBIT_PERIOD 4 // 详查型每轨4个任务

#define EARTH_AUTO_ROTATION_ANGLE_SPEED 4.167e-3 // 自转角速度 单位：角度

#define SATELLITE_ANTENNA_MOBILITY 180
#define SATELLITE_IMAGING_MOBILITY 300
#define EXPECTED_SIMULATION_TIME 2592000 // 单位：秒，1d * 24h * 60min * 60sec
#define SIMULATION_TIME_STEP 1.0 // 仿真时间步长
#define NETWORK_CONNECTION_REQUIREMENT_TIME_INTERVEL 60.0
#define DETAIL_DETECT_SATELLITE_VISIBLE_RANGE 0.47831843169

#define EPS_ZERO 1e-10

#define KEPLER_STATIC 3.9861e5

#define SNS_TASK_LOWEST_PRIORITY 1

#define DISASTER_DETECT_PEROID 60 // 详查型卫星每60s识别一次自然灾害

#endif /* MICRO_SATELLITE_h */
