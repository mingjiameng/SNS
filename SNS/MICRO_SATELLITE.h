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
typedef double SNSAngle; // 单位:弧度
typedef double SNSNetworkFlowSize; // 单位:MB
typedef double SNSResulotionLevel; // 单位:米
typedef double SNSScanWidth; // 单位:米
typedef int SNSPriorityLevel;


#define MINIMUM_DATA_PACKAGE_COLLECTION_SIZE 7000

#define EXPECTED_SIMULATION_TIME 86400 // 单位：秒，1d * 24h * 60min * 60sec
#define SIMULATION_TIME_STEP 1 // 仿真时间步长


#define EPS_ZERO 1e-10

#define SNS_TASK_LOWEST_PRIORITY 1

#endif /* MICRO_SATELLITE_h */
